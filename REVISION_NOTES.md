# 🔄 Korean Together 설계 개선안 (Revision Notes)

**작성일**: 2026-01-15  
**버전**: 2.0 (Optimized MVP-first)  
**기반**: 초기 설계 비판적 검토 반영

---

## 📌 핵심 설계 원칙 변경

### AS-IS (초기 설계)
- ❌ 마이크로서비스 전제 (API/AI/WS 완전 분리)
- ❌ 풀스택 인프라 (Prometheus, Grafana, 멀티리전)
- ❌ 복잡한 AI 공급자 혼합 (로컬 + 클라우드 동시)
- ❌ WebSocket 음성 스트리밍
- ❌ PM2 + Docker 혼용

### TO-BE (최적화 설계)
- ✅ **모듈러 모놀리스** (배포는 단일, 코드는 분리)
- ✅ **단계별 인프라** (MVP → 상용 → 글로벌)
- ✅ **단일 공급자 원칙** (초기: 클라우드만, 이후 로컬 전환)
- ✅ **HTTP 업로드 + WS 이벤트**
- ✅ **Docker 표준화** (PM2는 개발용만)

---

## 🎯 MVP 단계 재정의 (v0 → v1 → v2)

### v0: Core Loop Validation (Week 1-6)
**목표**: "한국어 학습 루프 1회"가 완전히 동작하는 최소 버전

#### 범위
- ✅ 단일 배포 (Docker Compose 1개 스택)
- ✅ 텍스트 입력 + TTS 출력 (STT 제외)
- ✅ Gemini API만 사용 (평가/피드백)
- ✅ Google TTS만 사용 (음성 출력)
- ✅ PostgreSQL 단일 DB (koto 전용 계정/스키마)
- ✅ Unity WebGL 최소 씬 1개 (카페)
- ✅ 로그 + 헬스체크만 (모니터링 스택 없음)

#### 배제
- ❌ 음성 입력 (STT)
- ❌ 로컬 GPU 모델
- ❌ 멀티리전/언어팩
- ❌ Prometheus/Grafana
- ❌ 백업 자동화

#### 기술 스택
```yaml
Runtime:
  - Node.js: v20 LTS (v24.x → 변경)
  - Python: 3.11 (3.12 → 변경, 더 안정적)

Services (단일 Compose):
  - koto-app: Node.js + Python 통합 컨테이너
  - postgres: 16
  - redis: 7
  - minio: latest (내부 전용)

External APIs:
  - Gemini 1.5 Pro: 평가/피드백
  - Google TTS: 음성 생성
```

---

### v1: Production-Ready (Week 7-12)
**목표**: 실제 학습자 50-100명 수용 가능

#### 추가 기능
- ✅ STT 도입 (Google Speech API)
- ✅ Unity 씬 확장 (공항, 편의점)
- ✅ 진도 추적 + 학습 분석
- ✅ 백업 자동화 (Cron)
- ✅ 기본 모니터링 (로그 집계)

#### 아키텍처 변경
- API/AI 서비스 물리적 분리 (여전히 단일 서버)
- MinIO presigned URL 전환
- WS Gateway 분리 검토

---

### v2: Scale & Optimize (Week 13-18)
**목표**: 다국가 확장 + 비용 최적화

#### 추가 기능
- ✅ 로컬 GPU 모델 (Whisper, VITS)
- ✅ 인도네시아 언어팩 (ko-id)
- ✅ 리전별 서버 준비
- ✅ Prometheus + Grafana
- ✅ CDN 도입

---

## 🏗️ 아키텍처 변경 사항

### 1. AI Service 구조 개선 (P0)

#### AS-IS (문제)
```python
# ai/main.py - 모든 AI 기능이 한 파일
@app.post("/stt")
async def speech_to_text(): ...

@app.post("/tts")
async def text_to_speech(): ...

@app.post("/evaluate")
async def evaluate(): ...
```

**문제점**:
- STT 장애 → TTS까지 영향
- 스케일링 비효율 (부하 분산 불가)
- 공급자 교체 시 전체 영향

#### TO-BE (개선)
```python
# ai/providers/stt_provider.py
class STTProvider(ABC):
    @abstractmethod
    async def transcribe(self, audio: bytes) -> str:
        pass

class GoogleSTTProvider(STTProvider):
    async def transcribe(self, audio: bytes) -> str:
        # Google Speech API
        pass

class WhisperSTTProvider(STTProvider):
    async def transcribe(self, audio: bytes) -> str:
        # 로컬 Whisper 모델
        pass

# ai/services/stt_service.py
class STTService:
    def __init__(self):
        # 환경 변수로 Provider 선택
        provider = os.getenv("STT_PROVIDER", "google")
        self.provider = self._get_provider(provider)
    
    async def transcribe(self, audio: bytes) -> TranscriptionResult:
        try:
            text = await self.provider.transcribe(audio)
            return TranscriptionResult(text=text, provider="google")
        except Exception as e:
            # 폴백 로직 (명확한 정책)
            if self.fallback:
                return await self.fallback.transcribe(audio)
            raise
```

**디렉토리 구조**:
```
ai/
├── providers/
│   ├── __init__.py
│   ├── stt_provider.py      # ABC
│   ├── google_stt.py        # Google 구현
│   ├── whisper_stt.py       # Whisper 구현
│   ├── tts_provider.py      # ABC
│   ├── google_tts.py
│   ├── vits_tts.py
│   ├── eval_provider.py     # ABC
│   └── gemini_eval.py
├── services/
│   ├── stt_service.py       # 비즈니스 로직
│   ├── tts_service.py
│   └── eval_service.py
├── routes/
│   ├── stt.py               # FastAPI 라우트
│   ├── tts.py
│   └── eval.py
└── main.py                  # FastAPI 앱
```

**장점**:
- ✅ Provider 교체 = 1줄 변경 (환경변수)
- ✅ 폴백 정책 명확화
- ✅ 테스트 용이 (Mock Provider)
- ✅ 향후 서비스 분리 용이

---

### 2. 음성 처리 흐름 개선 (P0)

#### AS-IS (문제)
```javascript
// Unity → WebSocket → base64 audio
ws.send({
  type: "user_input",
  audio: "base64encodedaudiodata..." // 수 MB
});
```

**문제점**:
- WS 메시지 크기 폭증 (메모리/CPU 소모)
- 네트워크 단절 시 재전송 어려움
- 디버깅 복잡 (바이너리 데이터)

#### TO-BE (개선)
```javascript
// 1. Unity: HTTP로 음성 업로드
const formData = new FormData();
formData.append('audio', audioBlob);
const uploadResponse = await fetch('/koto-api/audio/upload', {
  method: 'POST',
  body: formData
});
const { audio_id } = await uploadResponse.json();

// 2. WebSocket: 이벤트만 전송
ws.send({
  type: "audio_uploaded",
  audio_id: audio_id,
  session_id: "sess_123"
});

// 3. 서버: 비동기 처리
// → STT 처리
// → 평가
// → TTS 생성
// → WS로 결과 전송 (audio_url만)
```

**API 설계**:
```javascript
// POST /koto-api/audio/upload
{
  "audio_id": "aud_xyz",
  "status": "processing"
}

// WS ← Server
{
  "type": "evaluation_complete",
  "audio_id": "aud_xyz",
  "transcript": "안녕하세요",
  "score": 85,
  "feedback": "좋아요!",
  "tts_url": "https://minio/koto-audio/resp_xyz.mp3"
}
```

**장점**:
- ✅ WS 메시지 가벼움 (< 1KB)
- ✅ HTTP 재전송/재개 가능
- ✅ MinIO presigned URL로 보안 강화
- ✅ 디버깅 용이 (파일 저장됨)

---

### 3. Docker 표준화 (P1)

#### AS-IS (문제)
- API: PM2 또는 Docker
- AI: PM2 또는 systemd
- DB: Docker

**문제점**: 배포 일관성 저하, 로그 분산

#### TO-BE (개선)
```yaml
# docker-compose.yml (v0 MVP)
version: '3.8'

services:
  koto-app:
    build: ./app
    image: koto-app:${VERSION:-latest}
    container_name: koto-app
    restart: unless-stopped
    environment:
      NODE_ENV: production
      DATABASE_URL: postgresql://koto_user:${DB_PASSWORD}@postgres:5432/koto
      REDIS_URL: redis://redis:6379
      GEMINI_API_KEY: ${GEMINI_API_KEY}
      GOOGLE_APPLICATION_CREDENTIALS: /app/secrets/gcp-sa.json
    ports:
      - "127.0.0.1:5000:5000"
    depends_on:
      - postgres
      - redis
    volumes:
      - ./secrets:/app/secrets:ro
      - app-logs:/app/logs
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:5000/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  postgres:
    image: postgres:16
    container_name: koto-postgres
    restart: unless-stopped
    environment:
      POSTGRES_USER: koto_user
      POSTGRES_PASSWORD: ${DB_PASSWORD}
      POSTGRES_DB: koto
    ports:
      - "127.0.0.1:5433:5432"  # 기존 5432와 충돌 방지
    volumes:
      - /data/db/koto-postgres:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U koto_user -d koto"]
      interval: 10s
      timeout: 5s
      retries: 5

  redis:
    image: redis:7-alpine
    container_name: koto-redis
    restart: unless-stopped
    command: ["redis-server", "--appendonly", "yes"]
    ports:
      - "127.0.0.1:6380:6379"  # 기존 6379와 충돌 방지
    volumes:
      - /data/db/koto-redis:/data

  minio:
    image: minio/minio:latest
    container_name: koto-minio
    restart: unless-stopped
    command: server --console-address ":9001" /data
    environment:
      MINIO_ROOT_USER: koto_minio
      MINIO_ROOT_PASSWORD: ${MINIO_PASSWORD}
    ports:
      - "127.0.0.1:9002:9000"   # API (내부 전용)
      - "127.0.0.1:9003:9001"   # Console (내부 전용)
    volumes:
      - /data/db/koto-minio:/data

volumes:
  app-logs:

networks:
  default:
    name: koto-network
```

**koto-app 컨테이너 내부 구조**:
```dockerfile
# app/Dockerfile
FROM node:20-bullseye-slim

# Python 추가 (AI 서비스용)
RUN apt-get update && apt-get install -y \
    python3.11 python3-pip \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Node.js dependencies
COPY api/package*.json ./api/
RUN cd api && npm ci --production

# Python dependencies
COPY ai/requirements.txt ./ai/
RUN cd ai && pip3 install --no-cache-dir -r requirements.txt

# 소스 코드
COPY api/ ./api/
COPY ai/ ./ai/
COPY shared/ ./shared/

# 실행 스크립트
COPY app/start.sh ./
RUN chmod +x start.sh

EXPOSE 5000
CMD ["./start.sh"]
```

```bash
# app/start.sh
#!/bin/bash
set -e

# AI 서비스 백그라운드 실행
cd /app/ai
python3 -m uvicorn main:app --host 0.0.0.0 --port 8000 &
AI_PID=$!

# API 서버 실행
cd /app/api
node src/index.js &
API_PID=$!

# 헬스체크 대기
wait $API_PID $AI_PID
```

**PM2 사용 규칙**:
```bash
# 개발 환경만 PM2 사용
# /home/ucon/koto/에서 로컬 개발 시
pm2 start ecosystem.config.js --only koto-api-dev

# 운영 환경은 Docker Compose만 사용
cd /home/ucon/koto
docker-compose up -d
```

---

### 4. MinIO 보안 강화 (P0)

#### AS-IS (문제)
- 9000-9001 Public 노출
- `mc policy set download` (누구나 다운로드)

#### TO-BE (개선)

**1. Caddy 설정 변경**:
```caddyfile
# MinIO 직접 노출 제거
# handle /minio/* { ... }  ← 삭제

# API를 통한 presigned URL만 제공
handle /koto-api/audio/download/* {
    reverse_proxy 127.0.0.1:5000
}
```

**2. API에서 presigned URL 생성**:
```javascript
// api/src/services/storage.js
const Minio = require('minio');

const minioClient = new Minio.Client({
  endPoint: 'localhost',
  port: 9002,
  useSSL: false,
  accessKey: process.env.MINIO_ACCESS_KEY,
  secretKey: process.env.MINIO_SECRET_KEY
});

async function getPresignedUrl(objectName) {
  // 1시간 유효한 URL
  const url = await minioClient.presignedGetObject(
    'koto-audio-private',  // 버킷 private으로 변경
    objectName,
    60 * 60  // 1시간
  );
  
  // localhost를 실제 도메인으로 변경
  return url.replace('localhost:9002', 'uconcreative.ddns.net/koto-api/audio/proxy');
}

// GET /koto-api/audio/download/:id
app.get('/audio/download/:id', authenticateToken, async (req, res) => {
  const { id } = req.params;
  
  // 사용자 권한 확인
  const audio = await db.query('SELECT * FROM audio_files WHERE id = $1', [id]);
  if (!audio || audio.session.user_id !== req.user.id) {
    return res.status(403).json({ error: 'Forbidden' });
  }
  
  // presigned URL 반환 또는 프록시
  const url = await getPresignedUrl(audio.object_name);
  res.redirect(url);
  
  // 또는 직접 스트리밍
  // const stream = await minioClient.getObject('koto-audio-private', audio.object_name);
  // stream.pipe(res);
});
```

**3. MinIO 포트 변경** (docker-compose.yml에 이미 반영):
```yaml
minio:
  ports:
    - "127.0.0.1:9002:9000"   # localhost만
    - "127.0.0.1:9003:9001"   # localhost만
```

---

### 5. Database 격리 전략 (P1)

#### AS-IS (문제)
- 기존 `uconai-app_postgres_1` 컨테이너에 DB 추가
- 프로젝트 간 장애 전파 위험

#### TO-BE (개선)

**옵션 A: 논리적 분리 (초기 권장)**
```bash
# 전용 사용자 생성
docker exec -it uconai-app_postgres_1 psql -U uconai_admin -d postgres << EOF
CREATE USER koto_user WITH PASSWORD 'STRONG_PASSWORD';
CREATE DATABASE koto OWNER koto_user;
\c koto
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";  -- 텍스트 검색용

-- 권한 제한 (다른 DB 접근 불가)
REVOKE ALL ON DATABASE uconai FROM koto_user;
REVOKE ALL ON DATABASE gonggu FROM koto_user;
EOF

# 백업 스크립트 분리
# /home/ucon/koto/infrastructure/scripts/backup-db.sh
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
docker exec uconai-app_postgres_1 pg_dump -U koto_user koto | \
  gzip > /data/db/koto-backups/koto_${DATE}.sql.gz

# 7일 이상 백업 삭제
find /data/db/koto-backups -name "*.sql.gz" -mtime +7 -delete
```

**옵션 B: 물리적 분리 (상용화 준비)**
```yaml
# docker-compose.yml - 별도 컨테이너
services:
  postgres:
    image: postgres:16
    container_name: koto-postgres
    # ... (위 섹션 3 참조)
```

**연결 문자열 관리**:
```bash
# .env
DATABASE_URL=postgresql://koto_user:PASSWORD@localhost:5433/koto

# app/config/database.js
const { Pool } = require('pg');
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  max: 20,  // 연결 풀 크기
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
});
```

---

### 6. Docker Compose GPU 설정 명확화 (P1)

#### AS-IS (문제)
```yaml
# 동작 안 함 (비-Swarm 환경)
deploy:
  resources:
    reservations:
      devices:
        - driver: nvidia
          count: 1
          capabilities: [gpu]
```

#### TO-BE (개선)

**1. nvidia-container-toolkit 설치 확인**:
```bash
# 설치 여부 확인
docker run --rm --gpus all nvidia/cuda:12.2.0-base-ubuntu22.04 nvidia-smi

# 설치 안 되어 있다면
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | \
  sudo tee /etc/apt/sources.list.d/nvidia-docker.list

sudo apt-get update && sudo apt-get install -y nvidia-container-toolkit
sudo systemctl restart docker
```

**2. Docker Compose 올바른 설정** (v2 플러그인):
```yaml
# docker-compose.gpu.yml (v2 전용)
services:
  koto-ai-gpu:
    build: ./ai-gpu
    runtime: nvidia
    environment:
      - NVIDIA_VISIBLE_DEVICES=all
      - NVIDIA_DRIVER_CAPABILITIES=compute,utility
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: 1
              capabilities: [gpu]
```

**3. 실행 및 검증**:
```bash
# GPU 사용 컨테이너 실행
docker-compose -f docker-compose.yml -f docker-compose.gpu.yml up -d koto-ai-gpu

# GPU 인식 확인
docker exec koto-ai-gpu nvidia-smi
docker exec koto-ai-gpu python3 -c "import torch; print(torch.cuda.is_available())"
```

**4. GPU 필요 시점 명확화**:
```
v0 (MVP): GPU 불필요 (외부 API만)
v1: GPU 불필요 (외부 API만)
v2: GPU 필요 (Whisper, VITS 로컬 모델)
```

---

### 7. 기술 스택 안정화 (P0)

#### AS-IS (문제)
- Node.js v24.x (너무 최신, LTS 아님)
- Python 3.12 (안정성 검증 부족)

#### TO-BE (개선)

| 항목 | 개발 서버 | 운영 환경 |
|------|-----------|-----------|
| **Node.js** | v24.x (테스트용) | **v20 LTS** ⭐ |
| **Python** | 3.12 | **3.11** ⭐ |
| **PostgreSQL** | 16 | **16** (LTS) |
| **Redis** | 7 | **7** |
| **Docker** | 최신 | **28.x+** |
| **Unity** | 2023.x | **2022.3 LTS** ⭐ |

**Dockerfile 고정**:
```dockerfile
# 개발용 (최신)
FROM node:24-bullseye-slim

# 운영용 (LTS)
FROM node:20-bullseye-slim AS production
```

---

## 📊 개선된 Phase 일정

### Phase v0: MVP (Week 1-6)

| Week | 목표 | 산출물 | 완료 기준 |
|------|------|--------|-----------|
| 1 | 인프라 구축 | Docker Compose 완성 | 모든 컨테이너 정상 기동 |
| 2 | DB + API 기본 | 세션/레슨 CRUD | Postman 테스트 통과 |
| 3 | AI Provider 분리 | Gemini/TTS Provider | 평가/TTS 동작 확인 |
| 4 | Unity 최소 씬 | 카페 씬 + NPC | 텍스트 대화 가능 |
| 5 | 통합 테스트 | 전체 플로우 | 1회 학습 루프 완료 |
| 6 | 버그 수정 + 문서화 | API 문서, 배포 가이드 | 외부인 실행 가능 |

**성공 지표**:
- ✅ 사용자가 Unity에서 텍스트 입력 → AI 평가 → TTS 응답 받기 (1분 내)
- ✅ 세션 기록이 DB에 저장됨
- ✅ Docker Compose로 1분 내 완전 재배포 가능

---

### Phase v1: Production-Ready (Week 7-12)

| Week | 목표 |
|------|------|
| 7-8 | STT 통합 (Google Speech API) |
| 9 | 음성 업로드 흐름 (HTTP + WS) |
| 10 | Unity 씬 확장 (공항) |
| 11 | 백업/모니터링 기본 |
| 12 | 부하 테스트 (동시 50 세션) |

---

### Phase v2: Scale (Week 13-18)

| Week | 목표 |
|------|------|
| 13-14 | Whisper/VITS GPU 모델 도입 |
| 15 | 인도네시아 언어팩 |
| 16 | 리전 분리 준비 |
| 17 | Prometheus + Grafana |
| 18 | 상용 런칭 준비 |

---

## 🎯 우선순위별 액션 아이템

### P0 (이번 주 필수, v0 시작 전)

1. **MinIO 보안 강화**
   ```bash
   # 1. 포트 변경 (docker-compose.yml)
   # 2. mc policy를 private으로 변경
   mc policy set none myminio/koto-audio
   # 3. API presigned URL 구현
   ```

2. **AI Provider 인터페이스 분리**
   ```bash
   mkdir -p ai/providers ai/services ai/routes
   # STT/TTS/Eval Provider ABC 작성
   ```

3. **음성 전송 설계 변경**
   ```bash
   # API 문서 작성: POST /audio/upload
   # WS 메시지 스펙 정리
   ```

4. **기술 스택 LTS 고정**
   ```bash
   # Dockerfile에서 Node 20, Python 3.11로 변경
   ```

---

### P1 (v0 완료 전 적용)

5. **Docker 표준화**
   ```bash
   # docker-compose.yml 완성
   # PM2는 ecosystem.config.js에 "dev" 프로파일만
   ```

6. **DB 논리적 분리**
   ```bash
   # koto_user 생성, 전용 백업 스크립트
   ```

7. **GPU 설정 검증**
   ```bash
   # nvidia-container-toolkit 확인
   # 테스트 스크립트 작성
   ```

---

### P2 (v1 이후)

8. **WS Gateway 분리**
9. **멀티리전 준비**
10. **관측 스택 도입**

---

## 📐 최종 아키텍처 (v0 기준)

```
┌─────────────────────────────────────────────────────┐
│              Unity Client (WebGL)                    │
│         uconcreative.ddns.net/koto                  │
└──────────────┬──────────────────────────────────────┘
               │ HTTPS
          ┌────▼────┐
          │  Caddy  │  :80/:443
          │ Reverse │
          │  Proxy  │
          └────┬────┘
               │
        ┌──────┴──────┐
        │             │
    REST API      WebSocket
    /koto-api/*   /koto/ws/*
        │             │
        └──────┬──────┘
               │
        ┌──────▼──────┐
        │  koto-app   │  :5000 (Docker)
        │  Container  │
        ├─────────────┤
        │ Node.js API │ (Express)
        │   +         │
        │ Python AI   │ (FastAPI :8000 internal)
        │   Service   │
        └──────┬──────┘
               │
    ┌──────────┼──────────┐
    ↓          ↓          ↓
┌─────────┐ ┌───────┐ ┌────────┐
│PostgreSQL│ │ Redis │ │ MinIO  │
│  :5433   │ │ :6380 │ │ (내부) │
└─────────┘ └───────┘ └────────┘
                           ↓
                    ┌──────────────┐
                    │ External APIs│
                    ├──────────────┤
                    │ Gemini 1.5   │
                    │ Google TTS   │
                    └──────────────┘
```

**핵심 특징**:
- ✅ 단일 배포 (koto-app 컨테이너 1개)
- ✅ 내부 모듈 분리 (Node + Python)
- ✅ 외부 의존 최소화 (Gemini, TTS만)
- ✅ 보안 강화 (MinIO 내부 전용, presigned URL)

---

## 📝 변경 요약 체크리스트

### 아키텍처
- [x] AI Service → Provider 패턴
- [x] WS 음성 전송 → HTTP 업로드
- [x] 모놀리스 → 모듈러 모놀리스

### 인프라
- [x] PM2 + Docker → Docker 중심
- [x] MinIO Public → presigned URL
- [x] Postgres 공유 → 논리적 분리
- [x] GPU 설정 명확화

### 기술 스택
- [x] Node 24 → Node 20 LTS
- [x] Python 3.12 → Python 3.11
- [x] Unity 2023 → Unity 2022.3 LTS

### 일정
- [x] 18주 → v0(6주) + v1(6주) + v2(6주)
- [x] 과도한 인프라 → 단계별 도입

### 우선순위
- [x] P0/P1/P2 명확화
- [x] MVP 범위 재정의

---

**작성**: Antigravity AI  
**검토 필요**: 즉시 적용 가능한 개선안  
**다음 단계**: P0 액션 아이템 실행 승인 요청

