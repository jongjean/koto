# 🎯 Korean Together - 직접 테스트하기

## 📝 준비 사항

1. **터미널 3개 준비**
   - 터미널 1: API 서버
   - 터미널 2: AI 서비스
   - 터미널 3: 테스트 명령어

---

## 🚀 Step 1: API 서버 시작

### 터미널 1에서 실행:
```bash
cd /home/ucon/koto/api
npm run dev
```

**확인 메시지**:
```
Server running on port 5000
Database connected
```

**문제 발생 시**:
```bash
# node_modules가 없다면
npm install

# 다시 시작
npm run dev
```

---

## 🤖 Step 2: AI 서비스 시작

### 터미널 2에서 실행:
```bash
cd /home/ucon/koto/ai
source venv/bin/activate

# Mock 모드로 시작 (Google Cloud 없이)
TTS_MOCK_MODE=true USE_MINIO=false GEMINI_API_KEY=AIzaSyAzbsDatSul4rlTtSoTSrhcWrxikaoSf28 python main.py
```

**확인 메시지**:
```
INFO:     Started server process
INFO:     Uvicorn running on http://0.0.0.0:8000
⚠️ TTS Mock Mode: Google Cloud 인증 없이 작동 중
```

---

## 🧪 Step 3: 기본 테스트 (터미널 3)

### 3.1 서버 작동 확인
```bash
# API 서버
curl http://localhost:5000/health | jq

# 예상 결과:
# {
#   "status": "OK",
#   "service": "KOTO API",
#   "version": "0.1.0"
# }

# AI 서비스
curl http://localhost:8000/health | jq

# 예상 결과:
# {
#   "status": "OK",
#   "service": "KOTO AI Service",
#   "gemini_configured": true
# }
```

---

## 🎓 Step 4: 실제 학습 시나리오 테스트

### 시나리오: "안녕하세요" 배우기

#### 4.1 세션 시작
```bash
# 인사하기 레슨으로 세션 시작
curl -X POST http://localhost:5000/api/v1/sessions \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": "00000000-0000-0000-0000-000000000001",
    "lesson_id": "00000000-0000-0000-0000-000000000001"
  }' | jq

# 결과에서 session_id 복사하기!
# 예: "session_id": "abc-123-def"
```

#### 4.2 사용자 답변 평가 (완벽한 답)
```bash
curl -X POST http://localhost:8000/api/v1/evaluate \
  -H "Content-Type: application/json" \
  -d '{
    "user_text": "안녕하세요",
    "expected_pattern": "안녕하세요",
    "context": {
      "lang_pack": "ko-en",
      "difficulty": 1
    }
  }' | jq

# 예상 결과:
# {
#   "score": 100,
#   "feedback": "Perfect!",
#   "source": "rule"
# }
```

#### 4.3 사용자 답변 평가 (오류 있음)
```bash
curl -X POST http://localhost:8000/api/v1/evaluate \
  -H "Content-Type: application/json" \
  -d '{
    "user_text": "나 학교 가요",
    "expected_pattern": "나는 학교에 가요",
    "context": {
      "lang_pack": "ko-en",
      "difficulty": 1
    },
    "use_rules": false
  }' | jq

# Gemini가 오류를 분석합니다!
# 파티클 누락 등을 지적
```

#### 4.4 TTS 피드백 생성
```bash
curl -X POST http://localhost:8000/api/v1/tts \
  -H "Content-Type: application/json" \
  -d '{
    "text": "완벽해요! 다음 문제로 넘어가볼까요?",
    "language": "ko-KR",
    "save_to_minio": false
  }' | jq

# Mock 모드에서는 가상 URL 반환
# {
#   "audio_id": "...",
#   "audio_url": "http://localhost:8000/mock/audio/...mp3",
#   "provider": "mock_tts"
# }
```

---

## 🇮🇩 Step 5: 인도네시아어 학습자 테스트

### 5.1 인도네시아어 피드백 (파티클 오류)
```bash
curl -X POST http://localhost:8000/api/v1/evaluate \
  -H "Content-Type: application/json" \
  -d '{
    "user_text": "나 학교 가요",
    "expected_pattern": "나는 학교에 가요",
    "context": {
      "lang_pack": "ko-id",
      "difficulty": 1
    },
    "use_rules": false
  }' | jq

# Gemini가 인도네시아어로 설명!
# "Tambahkan partikel '는' ..."
```

### 5.2 인도네시아어 높임말 오류
```bash
curl -X POST http://localhost:8000/api/v1/evaluate \
  -H "Content-Type: application/json" \
  -d '{
    "user_text": "선생님이 왔어",
    "expected_pattern": "선생님이 오셨어요",
    "context": {
      "lang_pack": "ko-id",
      "difficulty": 2
    },
    "use_rules": false
  }' | jq

# "Gunakan bentuk hormat '오시다' ..."
```

---

## 📊 Step 6: Database 데이터 확인

### 6.1 전체 레슨 목록
```bash
docker exec uconai-app_postgres_1 psql -U uconai_admin -d koto -c "
SELECT code, title_ko, title_en, level 
FROM lessons 
ORDER BY sequence;"
```

### 6.2 특정 레슨의 활동들
```bash
# Lesson 1 (인사하기) 활동들
docker exec uconai-app_postgres_1 psql -U uconai_admin -d koto -c "
SELECT 
  a.code,
  a.prompt_en,
  a.expected_patterns->>'primary' as expected_answer
FROM activities a
JOIN stages s ON a.stage_id = s.id
JOIN lessons l ON s.lesson_id = l.id
WHERE l.code = 'les_greeting_001'
ORDER BY a.sequence;"
```

### 6.3 레벨별 통계
```bash
docker exec uconai-app_postgres_1 psql -U uconai_admin -d koto -c "
SELECT 
  CASE 
    WHEN level = 'A1' THEN '초급'
    WHEN level IN ('A2', 'B1') THEN '중급'
    ELSE '고급'
  END as 레벨,
  COUNT(DISTINCT l.id) as 레슨수,
  COUNT(a.id) as 활동수
FROM lessons l
LEFT JOIN stages s ON l.id = s.lesson_id
LEFT JOIN activities a ON s.id = a.stage_id
GROUP BY CASE WHEN level = 'A1' THEN '초급' WHEN level IN ('A2', 'B1') THEN '중급' ELSE '고급' END;"
```

---

## 🎯 Step 7: 전체 플로우 한번에 테스트

### 간단한 학습 루프 스크립트
```bash
#!/bin/bash
# save as: test_flow.sh

echo "=== Korean Together 학습 루프 테스트 ==="
echo ""

# 1. 세션 생성
echo "1️⃣ 세션 생성..."
SESSION=$(curl -s -X POST http://localhost:5000/api/v1/sessions \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": "00000000-0000-0000-0000-000000000001",
    "lesson_id": "00000000-0000-0000-0000-000000000001"
  }')

SESSION_ID=$(echo "$SESSION" | jq -r '.session_id')
echo "   Session ID: $SESSION_ID"
echo ""

# 2. 평가
echo "2️⃣ 사용자 답변 평가..."
EVAL=$(curl -s -X POST http://localhost:8000/api/v1/evaluate \
  -H "Content-Type: application/json" \
  -d '{
    "user_text": "안녕하세요",
    "expected_pattern": "안녕하세요",
    "context": {"lang_pack": "ko-en"}
  }')

SCORE=$(echo "$EVAL" | jq -r '.score')
FEEDBACK=$(echo "$EVAL" | jq -r '.feedback')

echo "   점수: $SCORE"
echo "   피드백: $FEEDBACK"
echo ""

# 3. TTS
echo "3️⃣ 음성 피드백 생성..."
TTS=$(curl -s -X POST http://localhost:8000/api/v1/tts \
  -H "Content-Type: application/json" \
  -d "{
    \"text\": \"$FEEDBACK\",
    \"language\": \"ko-KR\",
    \"save_to_minio\": false
  }")

AUDIO_URL=$(echo "$TTS" | jq -r '.audio_url')
echo "   오디오 URL: $AUDIO_URL"
echo ""

echo "✅ 전체 플로우 완료!"
```

**실행**:
```bash
chmod +x test_flow.sh
./test_flow.sh
```

---

## 🐛 문제 해결

### API 서버가 안 떠요
```bash
# 포트 확인
lsof -i :5000

# 프로세스 종료
pkill -f "node src/index.js"

# 재시작
cd /home/ucon/koto/api && npm run dev
```

### AI 서비스가 안 떠요
```bash
# 가상환경 확인
cd /home/ucon/koto/ai
source venv/bin/activate
which python  # /home/ucon/koto/ai/venv/bin/python 이어야 함

# 패키지 재설치
pip install -r requirements.txt

# 재시작
TTS_MOCK_MODE=true GEMINI_API_KEY=AIzaSyAzbsDatSul4rlTtSoTSrhcWrxikaoSf28 python main.py
```

### Database 연결 안됨
```bash
# PostgreSQL 상태
docker ps | grep postgres

# Database 존재 확인
docker exec uconai-app_postgres_1 psql -U uconai_admin -l | grep koto
```

---

## 📝 체크리스트

**테스트 전**:
- [ ] PostgreSQL 컨테이너 실행 중
- [ ] `koto` Database 존재
- [ ] 15개 레슨 데이터 삽입됨

**테스트 중**:
- [ ] API 서버 실행 (터미널 1)
- [ ] AI 서비스 실행 (터미널 2)
- [ ] 테스트 명령어 실행 (터미널 3)

**확인 사항**:
- [ ] Health check 성공
- [ ] Session 생성 성공
- [ ] Gemini 평가 작동
- [ ] TTS Mock 작동
- [ ] 인니어 피드백 작동

---

## 🎉 성공 기준

모든 API가 정상 응답하면 성공!

```bash
# 종합 테스트 실행
./test_complete.sh

# 모두 PASS면 성공! ✅
```

---

**준비되셨나요? 터미널 3개를 열고 시작하세요!** 🚀
