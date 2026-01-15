# 🚀 KOTO 프로젝트 Quick Start Guide

**Korean Together - AI 메타버스 한국어 학습 플랫폼**

---

## 📚 필수 문서

시작하기 전에 다음 문서를 확인하세요:

1. **서버_인프라_조사_보고서.md** - 서버 환경 상세 분석
2. **MASTER_PLAN.md** - 전체 개발 로드맵 (18주)
3. **docs/ARCHITECTURE.md** - 시스템 아키텍처

---

## ⚡ 30분 안에 시작하기

### Step 1: Git 저장소 초기화 (5분)

```bash
cd /home/ucon/koto

# Git 초기화
git init
git branch -M main
git remote add origin https://github.com/jongjean/koto

# .gitignore 생성
cat > .gitignore << 'EOF'
# Dependencies
node_modules/
__pycache__/
*.pyc
venv/
.env

# Logs
*.log
logs/

# OS
.DS_Store
Thumbs.db

# IDE
.vscode/
.idea/

# Build
dist/
build/
*.tmp
EOF

# 첫 커밋
git add .
git commit -m "chore: initial project setup with master plan"
git push -u origin main
```

### Step 2: 디렉토리 구조 생성 (3분)

```bash
# 프로젝트 구조 생성
mkdir -p api/{src,tests,config}
mkdir -p api/src/{routes,controllers,services,models,middleware}
mkdir -p ai/{models,services,utils,config}
mkdir -p unity/{Assets,ProjectSettings}
mkdir -p infrastructure/{docker,scripts,monitoring}
mkdir -p db/migrations
mkdir -p docs/{api,guides,diagrams}
mkdir -p shared/{types,constants}

# 확인
tree -L 2 -d
```

### Step 3: 데이터베이스 생성 (2분)

```bash
# PostgreSQL DB 생성
docker exec -it uconai-app_postgres_1 psql -U uconai_admin -d postgres << EOF
CREATE DATABASE koto;
\c koto
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
\q
EOF

# 확인
docker exec -it uconai-app_postgres_1 psql -U uconai_admin -c "\l" | grep koto
```

### Step 4: MinIO 버킷 생성 (3분)

```bash
# MinIO 클라이언트 설정 (이미 되어 있다면 스킵)
mc alias set myminio http://localhost:9000 uconai_minio_key CHANGE_ME_MINIO_SECRET

# KOTO 전용 버킷 생성
mc mb myminio/koto-audio
mc mb myminio/koto-content
mc mb myminio/koto-temp

# 공개 다운로드 허용
mc policy set download myminio/koto-audio
mc policy set download myminio/koto-content

# 확인
mc ls myminio/ | grep koto
```

### Step 5: API 서버 Scaffold (10분)

```bash
cd /home/ucon/koto/api

# package.json 생성
npm init -y

# 필수 패키지 설치
npm install express cors dotenv pg redis socket.io winston helmet
npm install -D nodemon

# 환경변수 템플릿
cat > .env.example << 'EOF'
NODE_ENV=development
PORT=5000

DATABASE_URL=postgresql://uconai_admin:PASSWORD@localhost:5432/koto
REDIS_URL=redis://localhost:6379

AI_SERVICE_URL=http://localhost:8000
MINIO_ENDPOINT=localhost:9000
MINIO_ACCESS_KEY=uconai_minio_key
MINIO_SECRET_KEY=CHANGE_ME_MINIO_SECRET

JWT_SECRET=your_jwt_secret_here
LOG_LEVEL=debug
EOF

# 실제 .env 복사 (나중에 비밀번호 입력)
cp .env.example .env

# 기본 서버 파일
cat > src/index.js << 'EOF'
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 5000;

// Middleware
app.use(helmet());
app.use(cors());
app.use(express.json());

// Health check
app.get('/health', (req, res) => {
  res.json({ 
    status: 'OK', 
    service: 'KOTO API',
    timestamp: new Date().toISOString()
  });
});

// Routes placeholder
app.get('/api/v1/lessons', (req, res) => {
  res.json({ message: 'Lessons endpoint - Coming soon' });
});

app.listen(PORT, () => {
  console.log(`🚀 KOTO API Server running on port ${PORT}`);
});
EOF

# package.json scripts 업데이트
npm pkg set scripts.start="node src/index.js"
npm pkg set scripts.dev="nodemon src/index.js"

# 테스트 실행
npm run dev &
sleep 2
curl http://localhost:5000/health
pkill -f "node src/index.js"
```

### Step 6: AI 서비스 Scaffold (7분)

```bash
cd /home/ucon/koto/ai

# Python 가상환경
python3 -m venv venv
source venv/bin/activate

# requirements.txt 생성
cat > requirements.txt << 'EOF'
fastapi==0.115.0
uvicorn[standard]==0.34.0
python-dotenv==1.0.0
google-generativeai==0.8.3
google-cloud-speech==2.27.0
google-cloud-texttospeech==2.18.0
pydantic==2.10.5
redis==5.2.1
psycopg2-binary==2.9.10
httpx==0.28.1
EOF

# 패키지 설치
pip install -r requirements.txt

# 환경변수
cat > .env.example << 'EOF'
GEMINI_API_KEY=your_gemini_api_key
GOOGLE_APPLICATION_CREDENTIALS=/path/to/service-account.json
REDIS_URL=redis://localhost:6379
MINIO_ENDPOINT=localhost:9000
EOF

cp .env.example .env

# 기본 AI 서버
cat > main.py << 'EOF'
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import os
from dotenv import load_dotenv

load_dotenv()

app = FastAPI(title="KOTO AI Service", version="0.1.0")

class EvaluationRequest(BaseModel):
    user_text: str
    expected_pattern: str
    context: dict = {}

@app.get("/health")
async def health_check():
    return {
        "status": "OK",
        "service": "KOTO AI Service",
        "gemini_configured": bool(os.getenv("GEMINI_API_KEY"))
    }

@app.post("/api/v1/evaluate")
async def evaluate_response(request: EvaluationRequest):
    # TODO: Gemini API 연동
    return {
        "score": 85,
        "feedback": "평가 엔진 개발 중...",
        "errors": []
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
EOF

# 테스트 실행
python main.py &
sleep 3
curl http://localhost:8000/health
pkill -f "python main.py"

deactivate
```

---

## 🎯 다음 단계

### 즉시 시작 가능한 작업 (우선순위순)

#### Week 1: Database Schema
```bash
# 1. Migration 도구 선택 (Sequelize/Prisma)
cd /home/ucon/koto/api
npm install sequelize sequelize-cli pg pg-hstore

# 2. 스키마 정의 (MASTER_PLAN.md 섹션 3.3 참조)
# 3. 마이그레이션 실행
```

#### Week 2: API Endpoints
```javascript
// 구현 목표:
POST   /api/v1/sessions              // 세션 시작
GET    /api/v1/lessons               // 레슨 목록
GET    /api/v1/lessons/:id/stages    // 스테이지 조회
POST   /api/v1/sessions/:id/event    // 이벤트 기록
```

#### Week 3: AI Integration
```python
# Gemini API 연동
# STT/TTS 기본 구현
# 평가 로직 개발
```

---

## 📋 체크리스트

### Phase 0 완료 확인

- [ ] Git 저장소 초기화 및 원격 연결
- [ ] 디렉토리 구조 생성
- [ ] PostgreSQL `koto` 데이터베이스 생성
- [ ] MinIO 버킷 생성 (`koto-audio`, `koto-content`)
- [ ] API 서버 기본 구조 (Express)
- [ ] AI 서버 기본 구조 (FastAPI)
- [ ] 환경변수 설정 (`.env`)
- [ ] 헬스체크 엔드포인트 동작 확인

### Phase S1 시작 전 준비

- [ ] Database Migration 도구 설정
- [ ] 로그 시스템 구축 (Winston)
- [ ] API 문서화 도구 (Swagger/OpenAPI)
- [ ] 테스트 프레임워크 (Jest/Mocha)

---

## 🔧 유용한 명령어

### Docker 관리
```bash
# PostgreSQL 접속
docker exec -it uconai-app_postgres_1 psql -U uconai_admin -d koto

# Redis 접속
docker exec -it uconai-app_redis_1 redis-cli

# 로그 확인
docker logs -f uconai-app_postgres_1
```

### PM2 프로세스 관리
```bash
# API 서버 시작
cd /home/ucon/koto/api
pm2 start src/index.js --name koto-api

# AI 서버 시작
cd /home/ucon/koto/ai
pm2 start "python3 main.py" --name koto-ai

# 상태 확인
pm2 list
pm2 logs koto-api
```

### Git Workflow
```bash
# 브랜치 생성
git checkout -b feature/lesson-engine

# 커밋
git add .
git commit -m "feat: add lesson orchestrator"

# 푸시
git push origin feature/lesson-engine
```

---

## 📞 문제 해결

### Q1: PostgreSQL 접속 실패
```bash
# 컨테이너 상태 확인
docker ps | grep postgres

# 재시작
docker restart uconai-app_postgres_1
```

### Q2: 포트 충돌 (5000)
```bash
# 사용 중인 프로세스 확인
sudo lsof -i :5000

# 종료 또는 포트 변경 (.env에서 PORT=5001)
```

### Q3: MinIO 접속 안 됨
```bash
# MinIO 컨테이너 확인
docker logs uconai-app_minio_1

# 웹 콘솔 접속
# http://localhost:9001
```

---

## 📚 참고 자료

### 내부 문서
- `/home/ucon/koto/MASTER_PLAN.md` - 전체 로드맵
- `/home/ucon/koto/서버_인프라_조사_보고서.md` - 인프라 분석
- `/home/ucon/koto/docs/ARCHITECTURE.md` - 아키텍처

### 외부 링크
- Express.js: https://expressjs.com/
- FastAPI: https://fastapi.tiangolo.com/
- PostgreSQL: https://www.postgresql.org/docs/
- Gemini API: https://ai.google.dev/
- Unity WebSocket: https://docs.unity3d.com/

---

## ✅ 다음 주 목표

1. Database 스키마 완성 (lessons, stages, activities)
2. 샘플 레슨 1개 삽입
3. POST /api/v1/sessions 엔드포인트 구현
4. Gemini API 연동 테스트

---

**문서 버전**: 1.0.0  
**최종 업데이트**: 2026-01-15  
**예상 소요 시간**: 30분 (Step 1-6 전체)
