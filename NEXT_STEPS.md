# 🚀 Korean Together - Next Steps

**현재 상태**: ver0.1 75% 완료  
**날짜**: 2026-01-15  
**다음 세션**: Google Cloud 인증 및 최종 테스트

---

## ✅ 지금까지 완료된 것

### 핵심 기능 (75%)
- ✅ Database (7 tables + Lesson 1 data)
- ✅ API Server (Express + Session API)
- ✅ Gemini Evaluator (테스트 성공)
- ✅ Google TTS Provider (코드 완성)
- ✅ Provider 패턴 (확장 가능)
- ✅ 통합 테스트 스크립트

---

## 📝 다음 세션에서 할 일

### 1. Google Cloud 설정 (30분)

#### Step 1: Service Account 생성
```bash
# 1. Google Cloud Console 접속
https://console.cloud.google.com/

# 2. 프로젝트 생성 또는 선택
# 프로젝트 이름: korean-together

# 3. IAM & Admin → Service Accounts
# Create Service Account
# 이름: koto-tts-service
# 역할: Cloud Text-to-Speech API User

# 4. JSON 키 생성 및 다운로드
# → koto-tts-service.json
```

#### Step 2: 파일 저장
```bash
# 다운로드한 JSON을 secrets 폴더로 복사
cp ~/Downloads/koto-tts-service.json /home/ucon/koto/secrets/gcp-sa.json

# 권한 설정
chmod 600 /home/ucon/koto/secrets/gcp-sa.json
```

#### Step 3: 환경변수 업데이트
```bash
# .env 파일 편집
cd /home/ucon/koto
nano .env

# 다음 라인 확인
GOOGLE_APPLICATION_CREDENTIALS=./secrets/gcp-sa.json
```

---

### 2. MinIO 설정 (15분)

#### MinIO 버킷 생성
```bash
# MinIO 클라이언트로 버킷 생성
mc mb myminio/koto-audio

# 정책 설정 (private)
mc policy set none myminio/koto-audio

# 확인
mc ls myminio/
```

#### .env 업데이트
```bash
# MinIO 설정 확인
MINIO_ACCESS_KEY=your_actual_access_key
MINIO_SECRET_KEY=your_actual_secret_key
```

---

### 3. 서버 실행 및 테스트 (15분)

#### Terminal 1: API Server
```bash
cd /home/ucon/koto/api
npm run dev
```

#### Terminal 2: AI Service
```bash
cd /home/ucon/koto/ai
source venv/bin/activate
GEMINI_API_KEY=AIzaSyAzbsDatSul4rlTtSoTSrhcWrxikaoSf28 python main.py
```

#### Terminal 3: 통합 테스트
```bash
cd /home/ucon/koto
./test_integration.sh
```

---

### 4. TTS 테스트 (10분)

```bash
# TTS API 테스트
curl -X POST http://localhost:8000/api/v1/tts \
  -H "Content-Type: application/json" \
  -d '{
    "text": "안녕하세요. 한국어를 배웁시다.",
    "language": "ko-KR"
  }' | jq

# 응답 예상:
# {
#   "audio_id": "uuid",
#   "audio_url": "presigned-url",
#   "duration_ms": 3000,
#   "provider": "google_tts"
# }
```

---

### 5. 전체 플로우 테스트 (20분)

#### 시나리오: 완전한 학습 루프

```bash
# 1. 세션 생성
SESSION_ID=$(curl -s -X POST http://localhost:5000/api/v1/sessions \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": "00000000-0000-0000-0000-000000000001",
    "lesson_id": "00000000-0000-0000-0000-000000000001"
  }' | jq -r '.session_id')

echo "Session ID: $SESSION_ID"

# 2. 사용자 입력 평가
EVAL_RESULT=$(curl -s -X POST http://localhost:8000/api/v1/evaluate \
  -H "Content-Type: application/json" \
  -d '{
    "user_text": "안녕하세요",
    "expected_pattern": "안녕하세요",
    "context": {"lang_pack": "ko-en", "difficulty": 1}
  }')

echo "Evaluation: $EVAL_RESULT"

# 3. TTS 피드백 생성
FEEDBACK_AUDIO=$(curl -s -X POST http://localhost:8000/api/v1/tts \
  -H "Content-Type: application/json" \
  -d '{
    "text": "완벽해요! 다음으로 넘어가볼까요?",
    "language": "ko-KR"
  }')

echo "TTS Audio: $FEEDBACK_AUDIO"
```

---

## 🎯 ver0.1 완료 기준

### 필수 (Must Have)
- [x] Database 스키마
- [x] Session API
- [x] Gemini 평가 엔진
- [x] TTS Provider 구현
- [x] Lesson 1 데이터
- [ ] Google Cloud 인증
- [ ] TTS 실제 음성 생성
- [ ] 전체 플로우 1회 완성

### 선택 (Nice to Have)
- [ ] WebSocket 구현
- [ ] MinIO presigned URL 실제 테스트
- [ ] Unity 연동 준비

---

## 🐛 알려진 이슈

### 1. AI Service 시작 시 MinIO 연결
**증상**: AI service 시작 시 MinIO 연결 실패  
**원인**: MinIO 버킷 미생성  
**해결**: `mc mb myminio/koto-audio`

### 2. Google Cloud 인증
**증상**: TTS API 호출 시 401 Unauthorized  
**원인**: Service Account JSON 미설정  
**해결**: 위 Step 1-3 수행

---

## 📚 참고 문서

### 읽어야 할 문서
1. **FINAL_COMPLETION_REPORT.md** - 전체 진행 상황
2. **DAY1_COMPLETE_FINAL.md** - Day 1 성과
3. **docs/AI_POLICY.md** - AI 서비스 정책
4. **PHASE1_MILESTONES.md** - 전체 로드맵

### 유용한 스크립트
- `test_integration.sh` - 통합 테스트
- `db/seeds/001_lesson_greeting.sql` - 레슨 데이터

---

## 🎓 배운 것

### 성공 요인
1. **Provider 패턴**: 유지보수 용이
2. **단계적 개발**: DB → API → AI
3. **즉시 테스트**: 각 단계마다 검증
4. **문서화**: 진행 상황 실시간 기록

### 개선할 점
1. requirements.txt 사전 체크
2. 환경변수 템플릿 명확화
3. 통합 테스트 자동화

---

## 🚀 ver0.2 준비

### 다음 레슨 (Lesson 2: 자기소개)
```sql
-- Lesson 2: 자기소개 (Self-Introduction)
-- Activities:
-- 1. 제 이름은 ~입니다
-- 2. 저는 ~에서 왔어요
-- 3. 저는 ~입니다 (직업)
-- 4. 저는 ~살입니다
-- 5. 저는 ~를 좋아해요 (취미)
```

### Unity 연동 준비
- WebSocket 구현
- Unity C# SDK 설계
- 음성 입출력 통합

---

**작성**: Antigravity AI  
**다음 세션**: Google Cloud 설정부터 시작  
**예상 소요**: 1-2시간으로 ver0.1 100% 완료
