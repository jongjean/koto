# 🎯 Korean Together (KOTO) 개발 마스터플랜

**작성일**: 2026-01-15  
**프로젝트명**: Korean Together (koto)  
**성격**: AI 기반 메타버스 한국어 학습 플랫폼  
**개발 환경**: Linux Server + Docker + Unity  
**Git Repository**: https://github.com/jongjean/koto

---

## 📋 목차

1. [환경 조사 결과 요약](#1-환경-조사-결과-요약)
2. [아키텍처 설계](#2-아키텍처-설계)
3. [기술 스택 선정](#3-기술-스택-선정)
4. [포트 할당 전략](#4-포트-할당-전략)
5. [개발 마일스톤 상세](#5-개발-마일스톤-상세)
6. [다국가 확장 전략](#6-다국가-확장-전략)
7. [보안 및 운영 전략](#7-보안-및-운영-전략)
8. [즉시 실행 가능한 액션 아이템](#8-즉시-실행-가능한-액션-아이템)

---

## 1. 환경 조사 결과 요약

### 1.1 하드웨어 현황

```
CPU: Intel Core i7-10700F (8 cores, 16 threads @ 2.90GHz)
RAM: 32GB (사용 중 5GB, 여유 26GB)
Storage: 
  - /dev/sda5: 218GB (사용 77GB, 여유 130GB)
  - /data/db: 916GB (사용 128MB, 여유 870GB) ⭐ 메인 데이터 저장소
GPU: NVIDIA GeForce GTX 1060 3GB (현재 사용 141MB)
  - CUDA 12.2 지원
  - 현재 GUI만 사용 중 (Xorg, gnome-shell)
  - AI 추론에 활용 가능
```

**판단**: 
- ✅ Phase H1 (개발 서버) 충분한 스펙
- ✅ GPU 활용 가능 (STT/TTS 추론 최적화)
- ⚠️ RAM 32GB는 충분하나, 대규모 LLM 모델 로딩 시 고려 필요
- ⚠️ 상용 서버는 별도 IDC 또는 클라우드 권장

### 1.2 소프트웨어 환경

```
OS: Ubuntu 24.04.3 LTS (Noble Numbat)
Docker: 28.5.2
Docker Compose: 1.29.2
Node.js: v24.11.1
npm: 11.6.2
Python: 3.12.3
PM2: 설치됨 (프로세스 관리)
Caddy: 2.x (웹 서버, HTTPS 자동화)
PostgreSQL: 16 (Docker 컨테이너)
Redis: 7 (Docker 컨테이너)
MinIO: latest (Object Storage)
```

### 1.3 현재 실행 중인 서비스

#### Docker 컨테이너
```
starverse-app        (8083 → 80)    - 메타버스 프로젝트
mongolia-gallery     (8080 → 80)    - 갤러리 앱
uconai-app_postgres  (5432)         - PostgreSQL ⭐
uconai-app_redis     (6379)         - Redis ⭐
uconai-app_minio     (9000-9001)    - MinIO ⭐
```

#### PM2 프로세스
```
gonggu-ai-server  (PID: 2933682, 828MB) - AI 서버
gonggu-api-v2     (PID: 3013259, 106MB) - Gonggu API (포트 4000)
uconai-api        (PID: 3168289, 83MB)  - UCONAI API (포트 4400)
```

#### Systemd 서비스
```
caddy.service                - 웹 서버 (80, 443)
postgresql@16-main.service   - 호스트 PostgreSQL (사용 안 함)
uconai-iso-backend.service   - ISO Backend (4400)
uconai-admin.service         - 관리 API
uconai-diskbot.service       - Discord 봇
```

### 1.4 포트 사용 현황

| 포트 | 서비스 | 용도 | 접근 |
|------|--------|------|------|
| 80 | Caddy | HTTP → HTTPS 리다이렉트 | Public |
| 443 | Caddy | HTTPS (uconcreative.ddns.net) | Public |
| 4000 | Gonggu API | Backend API | Localhost |
| 4400 | UCONAI API | ISO Backend API | Localhost |
| 5432 | PostgreSQL | Database | Localhost (Docker) |
| 6379 | Redis | Cache/Session | Localhost (Docker) |
| 8080 | Mongolia Gallery | Static Web | Localhost (Caddy Proxy) |
| 8083 | Starverse | Static Web | Localhost (Caddy Proxy) |
| 9000-9001 | MinIO | Object Storage | Public (파일 서빙) |

**사용 가능 포트**: 3000, 5000, 5001, 8081, 8082, 8084-8099

### 1.5 데이터베이스 현황

**PostgreSQL 16 (Docker: uconai-app_postgres_1)**
```
사용자: uconai_admin
데이터베이스:
  - uconai        (UCONAI 프로젝트)
  - uconai_core   (Core 시스템)
  - gonggu        (사용자: gonggu)
  - postgres      (기본 DB)
```

**판단**: 
- ✅ `uconai_admin` 사용자로 새 DB 생성 가능
- ✅ `koto` 전용 DB 생성 권장
- ✅ 또는 별도 Docker PostgreSQL 컨테이너 생성 가능

### 1.6 Caddy 리버스 프록시 구조

Caddy는 현재 **동적 프로젝트 라우팅** 지원:
- `/koto/*` → `/var/www/koto` (이미 등록됨 ✅)
- 자동 HTTPS 인증서
- CORS 설정 완료
- API 프록시 가능

### 1.7 Git 상태

```bash
Repository: /home/ucon/koto
Status: Git 초기화 안 됨 (❌)
GitHub: https://github.com/jongjean/koto
```

**즉시 필요한 작업**:
1. Git 초기화 및 GitHub 연동
2. `.gitignore` 설정 (환경변수, Docker 볼륨 제외)
3. 기본 프로젝트 구조 커밋

---

## 2. 아키텍처 설계

### 2.1 전체 시스템 구성도

```
┌─────────────────────────────────────────────────────────────┐
│                    INTERNET (HTTPS)                          │
│              uconcreative.ddns.net/koto                      │
└────────────────────────┬────────────────────────────────────┘
                         │
                    ┌────▼────┐
                    │  Caddy  │ :80, :443
                    │ (Nginx) │
                    └────┬────┘
                         │
        ┌────────────────┼────────────────┐
        │                │                │
   ┌────▼─────┐    ┌────▼──────┐   ┌────▼─────┐
   │  Unity   │    │   Koto    │   │  MinIO   │
   │  Client  │    │  API      │   │  Files   │
   │(Browser) │    │(Node/Py)  │   │  :9000   │
   └──────────┘    └─────┬─────┘   └──────────┘
                         │
        ┌────────────────┼────────────────┐
        │                │                │
   ┌────▼────┐     ┌────▼────┐     ┌────▼────┐
   │ PostgreSQL│     │  Redis   │     │   AI    │
   │  :5432   │     │  :6379   │     │  Layer  │
   │(Lesson DB)│     │(Session) │     │(LLM/TTS)│
   └──────────┘     └──────────┘     └──────────┘
```

### 2.2 서비스 계층 분리 (Docker Compose)

```yaml
# /home/ucon/koto/docker-compose.yml (예시)

services:
  # 1. Lesson Engine API (핵심)
  koto-api:
    build: ./api
    ports:
      - "127.0.0.1:5000:5000"
    environment:
      - DATABASE_URL=postgresql://uconai_admin:***@postgres:5432/koto
      - REDIS_URL=redis://redis:6379
      - AI_SERVICE_URL=http://koto-ai:8000
    depends_on:
      - postgres
      - redis

  # 2. AI Service Layer (STT/TTS/LLM)
  koto-ai:
    build: ./ai
    ports:
      - "127.0.0.1:8000:8000"
    environment:
      - GEMINI_API_KEY=${GEMINI_API_KEY}
      - USE_GPU=true
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: 1
              capabilities: [gpu]

  # 3. PostgreSQL (기존 컨테이너 재사용 또는 별도)
  postgres:
    image: postgres:16
    volumes:
      - /data/db/koto-postgres:/var/lib/postgresql/data
    environment:
      - POSTGRES_USER=koto_admin
      - POSTGRES_PASSWORD=${DB_PASSWORD}
      - POSTGRES_DB=koto

  # 4. Redis (기존 재사용)
  redis:
    image: redis:7
    command: ["redis-server", "--appendonly", "yes"]
    volumes:
      - /data/db/koto-redis:/data

  # 5. MinIO (기존 재사용 - 음성/콘텐츠)
  # 별도 버킷 생성: koto-audio, koto-content
```

### 2.3 API 구조 (RESTful + WebSocket)

#### REST API (세션 관리, 진도)
```
POST   /api/v1/sessions              - 세션 시작
GET    /api/v1/sessions/:id          - 세션 조회
POST   /api/v1/sessions/:id/event    - 학습 이벤트 전송
GET    /api/v1/lessons               - 레슨 목록
GET    /api/v1/lessons/:id/stages    - 스테이지 목록
```

#### WebSocket (실시간 튜터 상호작용)
```
ws://localhost:5000/ws/session/:id
→ Client: { type: "user_input", audio: "base64..." }
← Server: { type: "tutor_response", text: "...", audio_url: "..." }
```

---

## 3. 기술 스택 선정

### 3.1 Backend (Lesson Engine API)

**선택1: Node.js + Express (추천 ⭐)**
- 기존 서버의 PM2 인프라 활용
- gonggu-api와 동일한 스택 (유지보수 용이)
- 빠른 개발 속도
- WebSocket 지원 우수

**선택2: Python + FastAPI**
- AI 서비스와 통합 용이
- 비동기 처리 강력
- 타입 힌트로 안정성

**최종 권장**: **Node.js (Express)** + Python (AI만)

### 3.2 AI Layer

**구성**:
```python
# /home/ucon/koto/ai/main.py
from fastapi import FastAPI
from transformers import pipeline
import google.generativeai as genai

app = FastAPI()

@app.post("/stt")
async def speech_to_text(audio: bytes):
    # Whisper 또는 Google Speech API
    pass

@app.post("/tutor/evaluate")
async def evaluate_response(text: str, context: dict):
    # Gemini API 호출
    # 오류 분석, 피드백 생성
    pass

@app.post("/tts")
async def text_to_speech(text: str, voice: str):
    # Google TTS 또는 로컬 모델
    pass
```

**AI 모델 전략**:
1. **LLM**: Gemini 1.5 Pro (외부 API) - 평가/피드백
2. **STT**: Google Speech-to-Text API (초기) → Whisper (로컬 GPU, 추후)
3. **TTS**: Google TTS API (초기) → VITS (로컬 GPU, 추후)

### 3.3 Database Schema (PostgreSQL)

```sql
-- 레슨/스테이지/액티비티 (콘텐츠)
CREATE TABLE lessons (
  id UUID PRIMARY KEY,
  title_ko VARCHAR(200),
  title_en VARCHAR(200),
  level VARCHAR(20),
  instruction_lang VARCHAR(10),
  target_lang VARCHAR(10),
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE stages (
  id UUID PRIMARY KEY,
  lesson_id UUID REFERENCES lessons(id),
  sequence INT,
  scene_type VARCHAR(50), -- 'cafe', 'airport', 'office'
  objective_ko TEXT,
  objective_en TEXT
);

CREATE TABLE activities (
  id UUID PRIMARY KEY,
  stage_id UUID REFERENCES stages(id),
  sequence INT,
  activity_type VARCHAR(50), -- 'dialogue', 'choice', 'repeat'
  prompt_template TEXT,
  expected_patterns JSONB,
  difficulty INT
);

-- 세션/이벤트 (학습 기록)
CREATE TABLE sessions (
  id UUID PRIMARY KEY,
  user_id UUID,
  lesson_id UUID REFERENCES lessons(id),
  started_at TIMESTAMP DEFAULT NOW(),
  ended_at TIMESTAMP,
  current_stage_id UUID,
  status VARCHAR(20) DEFAULT 'active'
);

CREATE TABLE session_events (
  id UUID PRIMARY KEY,
  session_id UUID REFERENCES sessions(id),
  activity_id UUID REFERENCES activities(id),
  event_type VARCHAR(50), -- 'user_input', 'tutor_response'
  user_input TEXT,
  tutor_response TEXT,
  evaluation JSONB, -- { score, errors: [...], feedback }
  timestamp TIMESTAMP DEFAULT NOW()
);

-- 언어팩
CREATE TABLE lang_packs (
  id UUID PRIMARY KEY,
  code VARCHAR(10) UNIQUE, -- 'ko-en', 'ko-id'
  feedback_templates JSONB,
  error_patterns JSONB,
  version VARCHAR(20)
);
```

### 3.4 Unity Client 연동

**통신 방식**:
- HTTP/HTTPS (세션 초기화, 진도 조회)
- WebSocket (실시간 음성 입력/튜터 응답)

**Unity Packages**:
- **Native WebSocket**: `com.endel.nativewebsocket`
- **UnityWebRequest**: HTTP 통신
- **Microphone**: 음성 녹음
- **AudioClip**: TTS 재생

**구현 예시** (Unity C#):
```csharp
// SessionManager.cs
public class SessionManager : MonoBehaviour
{
    private WebSocket ws;
    
    async void StartSession(string lessonId)
    {
        var sessionId = await CreateSession(lessonId);
        ws = new WebSocket($"wss://uconcreative.ddns.net/koto/ws/session/{sessionId}");
        
        ws.OnMessage += OnTutorMessage;
        await ws.Connect();
    }
    
    void OnTutorMessage(byte[] data)
    {
        var response = JsonUtility.FromJson<TutorResponse>(Encoding.UTF8.GetString(data));
        DisplaySubtitle(response.text);
        PlayAudio(response.audio_url);
    }
}
```

---

## 4. 포트 할당 전략

### 4.1 Koto 프로젝트 전용 포트

| 서비스 | 포트 | 접근 | 비고 |
|--------|------|------|------|
| Koto API | 5000 | localhost | Caddy → `/koto-api/*` |
| Koto AI | 8000 | localhost | Internal only |
| Koto WebSocket | 5000 | localhost | `/ws/session/*` |
| Koto Admin | 9090 | localhost | 관리자 콘솔 (옵션) |

### 4.2 Caddy 설정 추가

```caddyfile
# /etc/caddy/Caddyfile에 추가

# Koto API
handle /koto-api/* {
    uri strip_prefix /koto-api
    reverse_proxy 127.0.0.1:5000
}

# Koto WebSocket
handle /koto/ws/* {
    reverse_proxy 127.0.0.1:5000
}

# Koto Unity Client (SPA)
handle_path /koto/* {
    root * /var/www/koto
    try_files {path} /index.html
    file_server
}
```

---

## 5. 개발 마일스톤 상세

### Phase S1: 기초 엔진 구축 (Week 1-3)

**목표**: 텍스트 기반 레슨 실행 + DB 스키마 완성

#### S1.1 - 프로젝트 초기화 (Day 1-2)
```bash
# 액션 아이템
1. Git 저장소 초기화 및 GitHub 연동
2. Docker Compose 파일 작성
3. 기본 디렉토리 구조 생성
   - /api (Node.js)
   - /ai (Python FastAPI)
   - /unity (Unity 클라이언트)
   - /docs (문서)
   - /db (마이그레이션)
4. 환경변수 템플릿 (.env.example)
5. README.md 작성
```

#### S1.2 - Database 설정 (Day 3-4)
```bash
1. PostgreSQL DB 생성 (koto)
2. 스키마 마이그레이션 도구 선택 (Prisma/Sequelize/TypeORM)
3. 초기 테이블 생성 (lessons, stages, activities)
4. 샘플 데이터 삽입 (레슨 1개, 스테이지 3개)
```

#### S1.3 - API 서버 개발 (Day 5-10)
```javascript
// 구현 항목
- POST /api/v1/sessions (세션 시작)
- GET /api/v1/lessons (레슨 목록)
- GET /api/v1/lessons/:id/stages
- POST /api/v1/sessions/:id/event (이벤트 기록)
- GET /api/v1/sessions/:id (세션 상태 조회)
```

#### S1.4 - 레슨 실행 엔진 (Day 11-15)
```javascript
// LessonOrchestrator 클래스
class LessonOrchestrator {
  async startLesson(lessonId, userId) {
    // 세션 생성
    // Stage 1 로드
    // Activity 1 프롬프트 반환
  }
  
  async processUserInput(sessionId, input) {
    // Activity 평가 (규칙 기반)
    // 다음 Activity 또는 Stage로 진행
    // 이벤트 로그
  }
}
```

#### S1.5 - 테스트 환경 (Day 16-21)
```bash
1. Postman/Thunder Client로 API 테스트
2. 로컬 Docker 컨테이너 실행
3. PM2로 프로세스 관리 설정
4. 로그 시스템 구축 (Winston/Pino)
```

---

### Phase S2: AI 튜터 연동 (Week 4-6)

**목표**: Gemini API 기반 평가 + 피드백 + 음성 처리

#### S2.1 - AI 서비스 구축 (Day 22-28)
```python
# FastAPI AI 서버
@app.post("/evaluate")
async def evaluate_korean_response(
    user_text: str,
    expected_pattern: str,
    context: dict
) -> EvaluationResult:
    prompt = f"""
    학습자 응답: {user_text}
    기대 패턴: {expected_pattern}
    맥락: {context}
    
    다음을 분석하세요:
    1. 문법 오류
    2. 어휘 선택
    3. 자연스러움
    4. 교정 제안 (한국어)
    """
    
    result = gemini_model.generate_content(prompt)
    return parse_evaluation(result.text)
```

#### S2.2 - STT/TTS 연동 (Day 29-35)
```python
# Google Cloud Speech-to-Text
@app.post("/stt")
async def transcribe_audio(audio: UploadFile):
    client = speech.SpeechClient()
    audio_content = await audio.read()
    
    config = speech.RecognitionConfig(
        encoding=speech.RecognitionConfig.AudioEncoding.WEBM_OPUS,
        sample_rate_hertz=48000,
        language_code="ko-KR",
    )
    
    response = client.recognize(config=config, audio=audio_content)
    return {"text": response.results[0].alternatives[0].transcript}

# Google Cloud Text-to-Speech
@app.post("/tts")
async def synthesize_speech(text: str, voice: str = "ko-KR-Wavenet-A"):
    client = texttospeech.TextToSpeechClient()
    synthesis_input = texttospeech.SynthesisInput(text=text)
    
    voice_params = texttospeech.VoiceSelectionParams(
        language_code="ko-KR",
        name=voice
    )
    
    audio_config = texttospeech.AudioConfig(
        audio_encoding=texttospeech.AudioEncoding.MP3
    )
    
    response = client.synthesize_speech(
        input=synthesis_input, voice=voice_params, audio_config=audio_config
    )
    
    # MinIO에 저장
    audio_url = upload_to_minio(response.audio_content)
    return {"audio_url": audio_url}
```

#### S2.3 - 하이브리드 평가 시스템 (Day 36-42)
```javascript
// 규칙 기반 + AI 혼합
async function evaluateResponse(userInput, activity) {
  // 1단계: 규칙 기반 (빠른 판정)
  const ruleResult = evaluateByRules(userInput, activity.expected_patterns);
  
  if (ruleResult.confidence > 0.9) {
    return ruleResult; // 확실하면 AI 호출 생략
  }
  
  // 2단계: AI 평가 (정교한 분석)
  const aiResult = await aiService.evaluate({
    user_text: userInput,
    expected: activity.expected_patterns,
    context: activity.context
  });
  
  return aiResult;
}
```

---

### Phase S3: Unity 연동 (Week 7-10)

**목표**: 메타버스 공간에서 실제 수업 진행

#### S3.1 - 최소 메타버스 공간 (Day 43-56)
```
Unity 씬 구성:
1. Cafe Scene (카페에서 주문하기)
   - NPC 점원 (AI 튜터 아바타)
   - 학습자 아바타
   - 인터랙션 포인트 (카운터, 테이블)
   
2. Airport Scene (공항 체크인)
   - NPC 직원
   - 체크인 카운터
   - 안내판
```

#### S3.2 - Unity-API 통신 (Day 57-63)
```csharp
public class KotoAPIClient : MonoBehaviour
{
    private WebSocket ws;
    private string sessionId;
    
    public async Task<SessionData> StartLesson(string lessonId)
    {
        var url = "https://uconcreative.ddns.net/koto-api/sessions";
        var json = $"{{\"lesson_id\":\"{lessonId}\",\"user_id\":\"test123\"}}";
        
        using var request = UnityWebRequest.Post(url, json, "application/json");
        await request.SendWebRequest();
        
        var response = JsonUtility.FromJson<SessionData>(request.downloadHandler.text);
        sessionId = response.id;
        
        // WebSocket 연결
        await ConnectWebSocket(sessionId);
        return response;
    }
    
    private async Task ConnectWebSocket(string sessionId)
    {
        ws = new WebSocket($"wss://uconcreative.ddns.net/koto/ws/session/{sessionId}");
        ws.OnMessage += HandleTutorMessage;
        await ws.Connect();
    }
    
    private void HandleTutorMessage(byte[] data)
    {
        var msg = JsonUtility.FromJson<TutorMessage>(Encoding.UTF8.GetString(data));
        
        // UI 업데이트
        subtitleUI.SetText(msg.text);
        
        // TTS 오디오 재생
        if (!string.IsNullOrEmpty(msg.audio_url))
        {
            StartCoroutine(PlayAudioFromURL(msg.audio_url));
        }
        
        // NPC 립싱크
        npcController.PlayLipSync(msg.duration);
    }
}
```

#### S3.3 - 음성 입력/출력 (Day 64-70)
```csharp
public class VoiceInputManager : MonoBehaviour
{
    private AudioClip recording;
    
    public void StartRecording()
    {
        recording = Microphone.Start(null, false, 10, 44100);
    }
    
    public async void StopRecordingAndSend()
    {
        Microphone.End(null);
        
        // WAV → Base64
        var audioData = WavUtility.FromAudioClip(recording);
        var base64 = Convert.ToBase64String(audioData);
        
        // WebSocket 전송
        var message = new {
            type = "user_input",
            audio = base64
        };
        
        ws.Send(JsonUtility.ToJson(message));
    }
}
```

---

### Phase S4: ID–KO 언어팩 적용 (Week 11-14)

**목표**: 인도네시아어 학습자 대응

#### S4.1 - 언어팩 구조 (Day 71-77)
```json
// lang_packs/ko-id.json
{
  "code": "ko-id",
  "instruction_lang": "id",
  "target_lang": "ko",
  "feedback_templates": {
    "grammar_error": "Tata bahasa salah. Seharusnya: {correct}",
    "vocab_error": "Kata yang lebih baik: {suggestion}",
    "good_job": "Bagus sekali! {detail}"
  },
  "error_patterns": {
    "korean_common_errors_for_indonesian": [
      {
        "pattern": "은/는 confusion",
        "explanation_id": "Gunakan '은' setelah konsonan, '는' setelah vokal"
      }
    ]
  },
  "prompts": {
    "welcome": "Selamat datang di Korean Together!",
    "lesson_complete": "Pelajaran selesai! Skor Anda: {score}"
  }
}
```

#### S4.2 - 다국어 지원 API (Day 78-84)
```javascript
// LangPackManager.js
class LangPackManager {
  constructor() {
    this.packs = {};
  }
  
  async loadPack(code) {
    const pack = await db.query('SELECT * FROM lang_packs WHERE code = $1', [code]);
    this.packs[code] = pack.feedback_templates;
  }
  
  getFeedback(code, key, params) {
    const template = this.packs[code][key];
    return template.replace(/\{(\w+)\}/g, (_, k) => params[k]);
  }
}

// 사용 예시
const feedback = langPackManager.getFeedback('ko-id', 'grammar_error', {
  correct: '저는 학생입니다'
});
// → "Tata bahasa salah. Seharusnya: 저는 학생입니다"
```

#### S4.3 - 인도네시아 학습자 오류 모델 (Day 85-98)
```python
# 인도네시아어 모국어 화자의 한국어 오류 패턴
INDONESIAN_ERROR_PATTERNS = {
    "particle_omission": {
        "reason": "인도네시아어는 조사가 없음",
        "examples": [
            "나 학교 가요 (X) → 나는 학교에 가요 (O)"
        ]
    },
    "honorific_confusion": {
        "reason": "인도네시아어 존댓말 체계 다름",
        "examples": [
            "선생님이 왔어 (X) → 선생님이 오셨어요 (O)"
        ]
    }
}

# Gemini 프롬프트에 반영
def create_evaluation_prompt(user_input, native_lang="id"):
    base_prompt = f"학습자 응답: {user_input}\n"
    
    if native_lang == "id":
        base_prompt += """
        학습자는 인도네시아어 모국어 화자입니다.
        다음 오류 패턴에 주의하여 평가하세요:
        - 조사 누락 (은/는/이/가/을/를)
        - 높임말 오류
        - 시제 표현 혼동
        
        피드백은 인도네시아어로 제공하세요.
        """
    
    return base_prompt
```

---

### Phase S5: 상용화 안정화 (Week 15-18)

**목표**: 운영 환경 구축 + 모니터링 + 배포 자동화

#### S5.1 - 로그/모니터링 (Day 99-105)
```yaml
# docker-compose.yml에 추가
services:
  prometheus:
    image: prom/prometheus
    volumes:
      - ./monitoring/prometheus.yml:/etc/prometheus/prometheus.yml
    ports:
      - "9091:9090"
  
  grafana:
    image: grafana/grafana
    ports:
      - "3001:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
```

#### S5.2 - 백업 전략 (Day 106-112)
```bash
# /home/ucon/koto/scripts/backup.sh
#!/bin/bash

DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/data/db/koto-backups"

# 1. PostgreSQL 백업
docker exec uconai-app_postgres_1 pg_dump -U uconai_admin koto > \
  $BACKUP_DIR/koto_db_$DATE.sql

# 2. Redis 백업 (RDB)
docker exec uconai-app_redis_1 redis-cli SAVE
cp /data/db/koto-redis/dump.rdb $BACKUP_DIR/redis_$DATE.rdb

# 3. MinIO 버킷 백업
mc mirror myminio/koto-audio $BACKUP_DIR/audio_$DATE/
mc mirror myminio/koto-content $BACKUP_DIR/content_$DATE/

# 4. 7일 이상 백업 삭제
find $BACKUP_DIR -name "*.sql" -mtime +7 -delete
```

#### S5.3 - CI/CD Pipeline (Day 113-126)
```yaml
# .github/workflows/deploy.yml
name: Deploy to Dev Server

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Deploy to Server
        uses: appleboy/ssh-action@master
        with:
          host: ${{ secrets.SERVER_HOST }}
          username: ucon
          key: ${{ secrets.SSH_PRIVATE_KEY }}
          script: |
            cd /home/ucon/koto
            git pull origin main
            docker-compose down
            docker-compose up -d --build
            pm2 restart koto-api
```

---

## 6. 다국가 확장 전략

### 6.1 Region 기반 배포 구조

```
[인도네시아 서버 - ID Region]
- koto-id.example.com
- Database: koto_id
- 언어팩: ko-id
- 법적 준수: 인도네시아 개인정보보호법

[베트남 서버 - VN Region]
- koto-vn.example.com
- Database: koto_vn
- 언어팩: ko-vi
- 법적 준수: 베트남 Cybersecurity Law

[중앙 관리]
- 콘텐츠 동기화 (lessons, stages)
- 모델 업데이트 배포
- 사용자 통계 집계
```

### 6.2 환경 변수 Region 설정

```bash
# .env
REGION=ID
INSTRUCTION_LANG=id
TARGET_LANG=ko
EVALUATION_LANG=en

DATABASE_URL=postgresql://koto_id:***@localhost:5432/koto_id
GEMINI_API_KEY=AIza***
STORAGE_BUCKET=koto-id-storage
```

---

## 7. 보안 및 운영 전략

### 7.1 API 인증

```javascript
// JWT 기반 인증
const jwt = require('jsonwebtoken');

app.post('/api/v1/auth/login', async (req, res) => {
  const { username, password } = req.body;
  
  // 사용자 검증 (향후 OAuth 연동)
  const user = await db.users.findOne({ username });
  
  if (user && bcrypt.compare(password, user.password_hash)) {
    const token = jwt.sign(
      { user_id: user.id, region: 'KR' },
      process.env.JWT_SECRET,
      { expiresIn: '7d' }
    );
    
    res.json({ token });
  }
});

// 미들웨어
function authenticateToken(req, res, next) {
  const token = req.headers['authorization']?.split(' ')[1];
  
  if (!token) return res.sendStatus(401);
  
  jwt.verify(token, process.env.JWT_SECRET, (err, user) => {
    if (err) return res.sendStatus(403);
    req.user = user;
    next();
  });
}
```

### 7.2 Rate Limiting

```javascript
const rateLimit = require('express-rate-limit');

const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15분
  max: 100, // IP당 100 요청
  message: 'Too many requests from this IP'
});

app.use('/api/', limiter);
```

### 7.3 환경변수 관리

```bash
# .env.example (Git에 커밋)
DATABASE_URL=postgresql://user:password@localhost:5432/koto
REDIS_URL=redis://localhost:6379
GEMINI_API_KEY=your_api_key_here
JWT_SECRET=your_secret_here
MINIO_ENDPOINT=localhost:9000
MINIO_ACCESS_KEY=your_access_key
MINIO_SECRET_KEY=your_secret_key

# .env (Git에서 제외, .gitignore에 추가)
# 실제 값 저장
```

---

## 8. 즉시 실행 가능한 액션 아이템

### 우선순위 1 (시작 전 필수)

✅ **A1. Git 저장소 초기화**
```bash
cd /home/ucon/koto
git init
git remote add origin https://github.com/jongjean/koto
git add README.md
git commit -m "Initial commit"
git push -u origin main
```

✅ **A2. 프로젝트 구조 생성**
```bash
mkdir -p api/{src,tests,config}
mkdir -p ai/{models,services,utils}
mkdir -p unity/{Assets,ProjectSettings}
mkdir -p docs/{api,architecture,guides}
mkdir -p db/migrations
mkdir -p infrastructure/{docker,scripts}
mkdir -p shared/{types,constants}
```

✅ **A3. Docker Compose 파일 작성**
```yaml
# docker-compose.yml (초기 버전)
services:
  koto-postgres:
    image: postgres:16
    environment:
      POSTGRES_USER: koto_admin
      POSTGRES_PASSWORD: ${DB_PASSWORD}
      POSTGRES_DB: koto
    volumes:
      - /data/db/koto-postgres:/var/lib/postgresql/data
    ports:
      - "127.0.0.1:5433:5432"
  
  koto-redis:
    image: redis:7
    command: ["redis-server", "--appendonly", "yes"]
    volumes:
      - /data/db/koto-redis:/data
    ports:
      - "127.0.0.1:6380:6379"
```

✅ **A4. 기본 문서 작성**
```bash
# README.md, CONTRIBUTING.md, LICENSE
# API 문서 템플릿
# 아키텍처 다이어그램
```

### 우선순위 2 (개발 시작)

🔹 **A5. API 서버 Scaffold**
```bash
cd api
npm init -y
npm install express cors dotenv pg redis socket.io winston
npm install -D nodemon typescript @types/node @types/express
```

🔹 **A6. AI 서버 Scaffold**
```bash
cd ai
python3 -m venv venv
source venv/bin/activate
pip install fastapi uvicorn google-generativeai google-cloud-speech google-cloud-texttospeech
```

🔹 **A7. Database 스키마 생성**
```sql
-- db/migrations/001_initial_schema.sql
-- 위 3.3 항목 스키마 실행
```

### 우선순위 3 (인프라)

🔧 **A8. PM2 설정**
```json
// ecosystem.config.js
module.exports = {
  apps: [{
    name: 'koto-api',
    script: './api/src/index.js',
    env: {
      NODE_ENV: 'production',
      PORT: 5000
    }
  }, {
    name: 'koto-ai',
    script: 'python3',
    args: '-m uvicorn ai.main:app --host 0.0.0.0 --port 8000',
    cwd: '/home/ucon/koto'
  }]
};
```

🔧 **A9. Caddy 설정 업데이트**
```bash
# /etc/caddy/Caddyfile에 추가 (위 4.2 참조)
sudo systemctl reload caddy
```

🔧 **A10. MinIO 버킷 생성**
```bash
# MinIO 클라이언트 설정
mc alias set myminio http://localhost:9000 uconai_minio_key CHANGE_ME_MINIO_SECRET

# 버킷 생성
mc mb myminio/koto-audio
mc mb myminio/koto-content
mc policy set download myminio/koto-audio
mc policy set download myminio/koto-content
```

---

## 📊 예상 리소스 사용량

### Phase S1-S2 (개발)
- CPU: 10-30% (Node.js API + Python AI)
- RAM: +2GB (API + AI 서비스)
- Disk: +5GB (모델 캐시, DB)
- Network: 최소 (로컬 개발)

### Phase S3-S4 (Unity 테스트)
- CPU: 20-40% (WebSocket 연결 증가)
- RAM: +3GB (동시 세션 10개 가정)
- Disk: +10GB (음성 파일 저장)
- Network: 중간 (TTS/STT API 호출)

### Phase S5 (상용 준비)
- CPU: 30-60% (모니터링 추가)
- RAM: +5GB (Prometheus, Grafana)
- Disk: +50GB (로그, 백업)
- Network: 높음 (외부 사용자 접속)

---

## 🎯 성공 지표 (KPI)

### 기술적 지표
- API 응답 시간: < 500ms (95th percentile)
- AI 평가 시간: < 2초
- WebSocket 레이턴시: < 100ms
- 시스템 가동률: > 99.5%

### 학습 효과 지표
- 레슨 완료율: > 70%
- 평균 세션 시간: 15-30분
- 오류 교정 정확도: > 85%
- 학습자 만족도: > 4.2/5.0

---

## 📝 다음 단계

**이 마스터플랜 승인 후 즉시 실행할 작업**:
1. ✅ Git 저장소 초기화 (A1)
2. ✅ 프로젝트 구조 생성 (A2)
3. ✅ Docker Compose 작성 및 테스트 (A3)
4. ✅ PostgreSQL DB 생성 및 스키마 적용 (A7)
5. ✅ API 서버 기본 구조 코딩 시작 (A5)

**질문사항**:
- [ ] 초기 타겟 언어팩: KO-EN 개발 후 KO-ID 적용 맞나요?
- [ ] GPU 활용: STT/TTS 로컬 모델을 처음부터 도입할까요, 아니면 Phase S2에서 외부 API로 시작?
- [ ] Unity 클라이언트: WebGL 빌드 (브라우저) vs. Standalone (다운로드) 우선순위?
- [ ] 사용자 인증: 초기에는 간단한 JWT → 추후 OAuth (Google/Facebook) 도입?

---

**작성자**: Antigravity AI  
**검토 필요**: @jongjean  
**버전**: 1.0.0  
**최종 업데이트**: 2026-01-15T20:15:00+09:00
