# 🌐 Korean Together (KOTO)

**AI Instructor–Driven Metaverse Korean Learning Platform**

AI 강사가 메타버스 공간에서 학습자와 "함께 존재하며" 실시간 상호작용하는 혁신적인 한국어 학습 플랫폼

---

## 📖 프로젝트 개요

### 핵심 특징
- 🤖 **AI 튜터 시스템**: Gemini 1.5 기반 평가 및 피드백
- 🎮 **메타버스 환경**: Unity 기반 몰입형 학습 공간
- 🗣️ **음성 중심 학습**: STT/TTS 실시간 음성 처리
- 🌍 **다국가 지원**: 언어팩 구조로 글로벌 확장
- 📊 **학습 분석**: 개인화된 진도 및 오류 패턴 분석

### 타겟 사용자
- 외국인 한국어 학습자 (초기: 인도네시아)
- 언어 중립적 엔진으로 전 세계 확장 가능

---

## 🏗️ 아키텍처

```
Unity Client → Caddy (HTTPS) → API Server (Node.js)
                                      ↓
                           ┌──────────┼──────────┐
                           ↓          ↓          ↓
                      PostgreSQL   Redis    AI Service (Python)
                                               ↓
                                     ┌─────────┼─────────┐
                                     ↓         ↓         ↓
                                  Gemini    STT/TTS   MinIO
```

**상세 아키텍처**: [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)

---

## 🚀 Quick Start

### 필수 요구사항
- Node.js v24+
- Python 3.12+
- Docker & Docker Compose
- PostgreSQL 16
- Redis 7
- MinIO (Object Storage)

### 30분 안에 시작하기

```bash
# 1. 저장소 클론
git clone https://github.com/jongjean/koto
cd koto

# 2. 데이터베이스 생성
docker exec -it uconai-app_postgres_1 psql -U uconai_admin -d postgres -c "CREATE DATABASE koto;"

# 3. MinIO 버킷 생성
mc mb myminio/koto-audio myminio/koto-content

# 4. API 서버 시작
cd api
npm install
npm run dev

# 5. AI 서비스 시작
cd ../ai
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
python main.py
```

**전체 가이드**: [QUICK_START.md](QUICK_START.md)

---

## 📂 프로젝트 구조

```
koto/
├── api/                    # Node.js API 서버 (Express)
│   ├── src/
│   │   ├── routes/        # API 라우트
│   │   ├── controllers/   # 비즈니스 로직
│   │   ├── services/      # 레슨 엔진
│   │   └── models/        # 데이터 모델
│   └── tests/
├── ai/                     # Python AI 서비스 (FastAPI)
│   ├── services/          # STT/TTS/평가
│   ├── models/            # AI 모델 관리
│   └── utils/
├── unity/                  # Unity 클라이언트
│   └── Assets/
├── infrastructure/
│   ├── docker/            # Docker Compose
│   └── scripts/           # 배포/백업 스크립트
├── db/
│   └── migrations/        # DB 스키마
└── docs/                   # 문서
    ├── ARCHITECTURE.md
    ├── API.md
    └── DEPLOYMENT.md
```

---

## 🛠️ 기술 스택

### Backend
- **API Server**: Node.js, Express.js, Socket.IO
- **AI Service**: Python, FastAPI, Uvicorn
- **Database**: PostgreSQL 16, Redis 7
- **Storage**: MinIO (S3-compatible)

### AI & ML
- **LLM**: Google Gemini 1.5 Pro
- **STT**: Google Speech-to-Text / Whisper
- **TTS**: Google Text-to-Speech / VITS

### Frontend
- **Client**: Unity 2022.3 LTS
- **Protocol**: WebSocket, REST API

### DevOps
- **Containerization**: Docker, Docker Compose
- **Reverse Proxy**: Caddy (Auto HTTPS)
- **Process Manager**: PM2
- **CI/CD**: GitHub Actions (예정)

---

## 📅 개발 로드맵

| Phase | 기간 | 목표 | 상태 |
|-------|------|------|------|
| **S1** | Week 1-3 | 기초 엔진 구축 (텍스트 기반) | 🔵 Ready |
| **S2** | Week 4-6 | AI 튜터 연동 (Gemini, STT/TTS) | ⚪ Planned |
| **S3** | Week 7-10 | Unity 메타버스 연동 | ⚪ Planned |
| **S4** | Week 11-14 | 인도네시아어 언어팩 | ⚪ Planned |
| **S5** | Week 15-18 | 상용화 안정화 | ⚪ Planned |

**상세 계획**: [MASTER_PLAN.md](MASTER_PLAN.md)

---

## 📊 핵심 문서

1. **[MASTER_PLAN.md](MASTER_PLAN.md)** - 전체 개발 마스터플랜 (18주)
2. **[서버_인프라_조사_보고서.md](서버_인프라_조사_보고서.md)** - 서버 환경 분석
3. **[QUICK_START.md](QUICK_START.md)** - 30분 개발 환경 구축
4. **[docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)** - 시스템 아키텍처

---

## 🌍 다국가 지원 전략

### 언어팩 구조
```json
{
  "code": "ko-id",
  "instruction_lang": "id",  // 인도네시아어 안내
  "target_lang": "ko",       // 한국어 학습
  "feedback_templates": { ... },
  "error_patterns": { ... }
}
```

### Regional Deployment
- 🇰🇷 **한국** (개발): ko-en (영어 안내)
- 🇮🇩 **인도네시아** (1차 상용): ko-id
- 🇻🇳 **베트남** (예정): ko-vi
- 🇹🇭 **태국** (예정): ko-th

---

## 🔒 보안

- ✅ HTTPS 자동화 (Let's Encrypt)
- ✅ JWT 기반 인증
- ✅ Database Localhost Only
- ✅ API Rate Limiting
- ✅ 환경변수 분리 (.env)

---

## 📈 시스템 요구사항

### 개발 서버 (Phase H1)
- CPU: 8+ cores
- RAM: 16GB+ (권장: 32GB)
- Storage: 100GB+ SSD
- GPU: Optional (NVIDIA 3GB+ for local STT/TTS)

### 상용 서버 (Phase H2)
- Load Balancer + API Servers (2-3대)
- Database Server (PostgreSQL Master-Slave)
- AI Server (GPU 전용)
- CDN (Static Assets)

---

## 🤝 기여 가이드

### 브랜치 전략
- `main`: 프로덕션 코드
- `develop`: 개발 브랜치
- `feature/*`: 기능 개발
- `hotfix/*`: 긴급 수정

### 커밋 컨벤션
```
feat: 새로운 기능
fix: 버그 수정
docs: 문서 수정
style: 코드 포맷팅
refactor: 리팩토링
test: 테스트 추가
chore: 빌드/설정 변경
```

---

## 📞 Contact

- **Organization**: UCON Creative Co., Ltd.
- **Email**: uconcreative@gmail.com
- **Repository**: [github.com/jongjean/koto](https://github.com/jongjean/koto)
- **Server**: uconcreative.ddns.net

---

## 📄 License

Copyright © 2026 UCON Creative Co., Ltd. All rights reserved.

---

## 📌 프로젝트 정보

```
개발 폴더: /home/ucon/koto
배포 폴더: /var/www/koto
API 포트: 5000 (localhost)
AI 포트: 8000 (localhost)
Public URL: https://uconcreative.ddns.net/koto
생성일: 2026-01-15
```

---

**Status**: 🔵 Planning Phase  
**Version**: 0.1.0-alpha  
**Last Updated**: 2026-01-15
