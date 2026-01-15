# Korean Together - 프로젝트 요약

**프로젝트명**: Korean Together (KOTO)  
**버전**: 0.1.0-alpha  
**진행률**: 75%  
**상태**: 개발 진행 중

---

## 📊 프로젝트 개요

AI 강사가 메타버스 환경에서 학습자와 함께 있으며 실시간으로 상호작용하는 혁신적인 한국어 학습 플랫폼

### 핵심 기술
- **AI 평가**: Google Gemini Pro
- **음성 생성**: Google Text-to-Speech
- **Database**: PostgreSQL 16
- **Backend**: Node.js (API) + Python (AI)
- **Frontend**: Unity 2022.3 LTS (예정)

---

## 🎯 ver0.1 현황

### 완료 (75%)
```
✅ Database (7 tables + Lesson 1)
✅ API Server (Express + Session API)
✅ Gemini Evaluator (테스트 성공)
✅ Google TTS Provider (구현 완료)
✅ Provider 패턴 (확장 가능)
✅ 통합 테스트 스크립트
✅ Lesson 1: 인사하기 (5 activities)
```

### 남은 작업 (25%)
```
⏳ Google Cloud Service Account
⏳ MinIO 설정
⏳ 최종 통합 테스트
```

---

## 📁 프로젝트 구조

```
koto/
├── api/                    # Node.js API 서버
│   ├── src/
│   │   ├── routes/        # Session API
│   │   ├── utils/         # Database, Logger
│   │   └── middleware/    # Error Handler
│   └── package.json
│
├── ai/                     # Python AI 서비스
│   ├── providers/         # ⭐ Provider 패턴
│   │   ├── base.py        # ABC
│   │   ├── eval/          # Gemini
│   │   └── tts/           # Google TTS
│   ├── services/          # Service 레이어
│   ├── routes/            # API 엔드포인트
│   └── main.py
│
├── db/
│   ├── migrations/        # Schema (7 tables)
│   └── seeds/             # Lesson 1 데이터
│
├── docs/                  # 문서
│   ├── AI_POLICY.md       # ⭐ AI 정책
│   ├── ARCHITECTURE.md
│   └── SCALING_CHECKPOINTS.md
│
├── test_integration.sh    # ⭐ 통합 테스트
└── NEXT_STEPS.md          # ⭐ 다음 할 일
```

---

## 🚀 실행 방법

### 1. API 서버
```bash
cd api
npm run dev
# http://localhost:5000
```

### 2. AI 서비스
```bash
cd ai
source venv/bin/activate
GEMINI_API_KEY=<your-key> python main.py
# http://localhost:8000
```

### 3. 테스트
```bash
./test_integration.sh
```

---

## 📊 통계

```
파일: 28개
코드: 7,694줄
커밋: 11개
문서: 10개

Database:
  - 테이블: 7개
  - Lesson: 1개 (인사하기)
  - Activities: 5개

API:
  - 엔드포인트: 3개

AI Service:
  - 엔드포인트: 3개
  - Providers: 2개 (Gemini, TTS)
```

---

## 🎓 레슨 데이터

**Lesson 1: 인사하기 (Greetings) - A1 Level**

1. 안녕하세요
2. 반갑습니다
3. 처음 뵙겠습니다
4. 잘 부탁드립니다
5. 안녕히 가세요

---

## 📝 주요 문서

1. **NEXT_STEPS.md** - 다음 세션 가이드
2. **SESSION_END_DAY1.md** - Day 1 요약
3. **docs/AI_POLICY.md** - AI 서비스 정책
4. **PHASE1_MILESTONES.md** - 전체 로드맵

---

## 🎯 다음 단계

1. Google Cloud Service Account 설정
2. MinIO 버킷 생성
3. 최종 통합 테스트
4. ver0.1 완료 (예상: 1-2시간)

---

**개발 시작**: 2026-01-15  
**소요 시간**: 3시간  
**앞당긴 기간**: 13.9일  
**상태**: 순조롭게 진행 중 🚀
