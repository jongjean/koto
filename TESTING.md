# 🧪 Korean Together - 테스트 가이드

## 📋 테스트 방법

### 1. 종합 테스트 (자동)
```bash
cd /home/ucon/koto
./test_complete.sh
```

**테스트 항목**:
- ✅ Database (15 lessons, 72 activities)
- ✅ API 서버 health
- ✅ AI 서비스 health
- ✅ Session 생성
- ✅ Gemini 평가 (ko-en, ko-id)
- ✅ TTS Mock 모드
- ✅ 언어팩 검증

---

### 2. 개별 테스트 (수동)

#### 2.1 Database 확인
```bash
# 레슨 수
docker exec uconai-app_postgres_1 psql -U uconai_admin -d koto -c "SELECT COUNT(*) FROM lessons;"

# 레벨별 통계
docker exec uconai-app_postgres_1 psql -U uconai_admin -d koto -c "
SELECT 
  level,
  COUNT(*) as lessons,
  (SELECT COUNT(*) FROM activities a 
   JOIN stages s ON a.stage_id = s.id 
   JOIN lessons l2 ON s.lesson_id = l2.id 
   WHERE l2.level = l.level) as activities
FROM lessons l
GROUP BY level
ORDER BY level;"
```

#### 2.2 API 서버 테스트
```bash
# Health Check
curl http://localhost:5000/health | jq

# Session 생성
curl -X POST http://localhost:5000/api/v1/sessions \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": "00000000-0000-0000-0000-000000000001",
    "lesson_id": "00000000-0000-0000-0000-000000000001"
  }' | jq

# Session 조회
curl http://localhost:5000/api/v1/sessions/[SESSION_ID] | jq
```

#### 2.3 Gemini 평가 테스트
```bash
# 한국어-영어 (완벽)
curl -X POST http://localhost:8000/api/v1/evaluate \
  -H "Content-Type: application/json" \
  -d '{
    "user_text": "안녕하세요",
    "expected_pattern": "안녕하세요",
    "context": {"lang_pack": "ko-en"}
  }' | jq

# 한국어-영어 (오류 있음)
curl -X POST http://localhost:8000/api/v1/evaluate \
  -H "Content-Type: application/json" \
  -d '{
    "user_text": "나 학교 가요",
    "expected_pattern": "나는 학교에 가요",
    "context": {"lang_pack": "ko-en"},
    "use_rules": false
  }' | jq

# 한국어-인도네시아어 (인니 학습자)
curl -X POST http://localhost:8000/api/v1/evaluate \
  -H "Content-Type: application/json" \
  -d '{
    "user_text": "선생님이 왔어",
    "expected_pattern": "선생님이 오셨어요",
    "context": {"lang_pack": "ko-id", "difficulty": 2},
    "use_rules": false
  }' | jq
```

#### 2.4 TTS 테스트
```bash
# Mock 모드
curl -X POST http://localhost:8000/api/v1/tts \
  -H "Content-Type: application/json" \
  -d '{
    "text": "안녕하세요. 한국어를 배웁시다.",
    "language": "ko-KR",
    "save_to_minio": false
  }' | jq
```

---

### 3. 전체 플로우 테스트

#### 시나리오: 완전한 학습 루프
```bash
#!/bin/bash

# 1. 세션 생성
SESSION=$(curl -s -X POST http://localhost:5000/api/v1/sessions \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": "00000000-0000-0000-0000-000000000001",
    "lesson_id": "00000000-0000-0000-0000-000000000001"
  }')

SESSION_ID=$(echo "$SESSION" | jq -r '.session_id')
echo "Session ID: $SESSION_ID"

# 2. 사용자 입력 평가
EVAL=$(curl -s -X POST http://localhost:8000/api/v1/evaluate \
  -H "Content-Type: application/json" \
  -d '{
    "user_text": "안녕하세요",
    "expected_pattern": "안녕하세요",
    "context": {"lang_pack": "ko-en", "difficulty": 1}
  }')

echo "평가 결과:"
echo "$EVAL" | jq '{score, feedback, source}'

# 3. TTS 피드백 생성
FEEDBACK_TEXT=$(echo "$EVAL" | jq -r '.feedback')
TTS=$(curl -s -X POST http://localhost:8000/api/v1/tts \
  -H "Content-Type: application/json" \
  -d "{
    \"text\": \"$FEEDBACK_TEXT\",
    \"language\": \"ko-KR\",
    \"save_to_minio\": false
  }")

echo "TTS 생성:"
echo "$TTS" | jq '{provider, duration_ms, voice}'

echo ""
echo "✅ 전체 플로우 완료!"
```

---

## 🎯 성능 테스트

### Latency 측정
```bash
# API 응답 시간
time curl -s http://localhost:5000/health > /dev/null

# Gemini 평가 시간
time curl -s -X POST http://localhost:8000/api/v1/evaluate \
  -H "Content-Type: application/json" \
  -d '{
    "user_text": "안녕하세요",
    "expected_pattern": "안녕하세요",
    "context": {"lang_pack": "ko-en"}
  }' > /dev/null
```

### 부하 테스트 (간단)
```bash
# 10번 연속 요청
for i in {1..10}; do
  curl -s -X POST http://localhost:8000/api/v1/evaluate \
    -H "Content-Type: application/json" \
    -d '{
      "user_text": "안녕하세요",
      "expected_pattern": "안녕하세요",
      "context": {"lang_pack": "ko-en"}
    }' | jq -r '.latency_ms'
done
```

---

## 📝 테스트 결과 예상치

### Database
- Lessons: 15
- Activities: 72
- 초급 (A1): 5 lessons, ~39 activities
- 중급 (A2-B1): 5 lessons, ~20 activities
- 고급 (B2-C1): 5 lessons, ~13 activities

### API
- Health check: < 50ms
- Session 생성: < 100ms

### AI
- 규칙 기반 평가: < 10ms
- Gemini 평가: 1-3초
- TTS Mock: < 10ms

---

## 🐛 문제 해결

### API 서버가 응답하지 않음
```bash
# 서버 시작
cd /home/ucon/koto/api
npm run dev
```

### AI 서비스가 응답하지 않음
```bash
# AI 서비스 시작
cd /home/ucon/koto/ai
source venv/bin/activate
TTS_MOCK_MODE=true USE_MINIO=false GEMINI_API_KEY=AIzaSyAzbsDatSul4rlTtSoTSrhcWrxikaoSf28 python main.py
```

### Database 연결 오류
```bash
# PostgreSQL 상태 확인
docker ps | grep postgres

# Database 존재 확인
docker exec uconai-app_postgres_1 psql -U uconai_admin -l
```

---

**작성**: Antigravity AI  
**테스트 스크립트**: `test_complete.sh`  
**사용법**: `./test_complete.sh`
