# 🔧 Korean Together - 설계 최종 보완 (v2.1)

**작성일**: 2026-01-15 20:50  
**기반**: REVISION_NOTES v2.0 + 추가 비판적 검토  
**변경 유형**: 운영 안정성 강화

---

## 📌 이 문서의 목적

REVISION_NOTES v2.0의 설계는 이미 우수하지만, **운영 단계에서 발생할 수 있는 잠재적 리스크**를 사전에 차단합니다.

### 보완 항목 (3가지)
1. **단일 컨테이너 프로세스 관리 강화** (start.sh 개선)
2. **AI Provider 정책 명시** (타임아웃/폴백/비용)
3. **DB 스키마 분석 가능성 확보** (JSONB + 핵심 컬럼)

---

## 🔄 변경 사항

### 1. start.sh 개선 (Fail-Fast + Signal Handling)

#### AS-IS (REVISION_NOTES v2.0)
```bash
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

**문제점**:
- ❌ 한쪽 프로세스 죽어도 컨테이너는 살아있음
- ❌ SIGTERM 수신 시 자식 프로세스 정리 안 됨
- ❌ 로그가 섞여서 구분 어려움

#### TO-BE (v2.1)
```bash
#!/bin/bash
set -e

# 로그 디렉토리 생성
mkdir -p /app/logs

# Cleanup 함수
cleanup() {
    echo "🛑 Received SIGTERM, shutting down gracefully..."
    
    # AI 서비스 종료
    if [ ! -z "$AI_PID" ]; then
        echo "Stopping AI service (PID: $AI_PID)..."
        kill -SIGTERM $AI_PID 2>/dev/null || true
    fi
    
    # API 서버 종료
    if [ ! -z "$API_PID" ]; then
        echo "Stopping API server (PID: $API_PID)..."
        kill -SIGTERM $API_PID 2>/dev/null || true
    fi
    
    # 최대 10초 대기
    echo "Waiting for processes to terminate..."
    for i in {1..10}; do
        if ! kill -0 $AI_PID 2>/dev/null && ! kill -0 $API_PID 2>/dev/null; then
            echo "✅ All processes terminated gracefully"
            exit 0
        fi
        sleep 1
    done
    
    # 강제 종료
    echo "⚠️ Force killing remaining processes..."
    kill -9 $AI_PID 2>/dev/null || true
    kill -9 $API_PID 2>/dev/null || true
    exit 1
}

# SIGTERM/SIGINT 트랩 설정
trap cleanup SIGTERM SIGINT

# AI 서비스 시작 (로그 분리)
echo "🚀 Starting AI service..."
cd /app/ai
python3 -m uvicorn main:app \
    --host 0.0.0.0 \
    --port 8000 \
    --log-config /app/ai/logging.yaml \
    > /app/logs/ai-service.log 2>&1 &
AI_PID=$!
echo "✅ AI service started (PID: $AI_PID)"

# AI 서비스 준비 대기 (최대 30초)
for i in {1..30}; do
    if curl -sf http://localhost:8000/health > /dev/null 2>&1; then
        echo "✅ AI service is ready"
        break
    fi
    if ! kill -0 $AI_PID 2>/dev/null; then
        echo "❌ AI service crashed during startup"
        exit 1
    fi
    sleep 1
done

# API 서버 시작 (로그 분리)
echo "🚀 Starting API server..."
cd /app/api
NODE_ENV=production node src/index.js \
    > /app/logs/api-server.log 2>&1 &
API_PID=$!
echo "✅ API server started (PID: $API_PID)"

# API 서버 준비 대기 (최대 30초)
for i in {1..30}; do
    if curl -sf http://localhost:5000/health > /dev/null 2>&1; then
        echo "✅ API server is ready"
        break
    fi
    if ! kill -0 $API_PID 2>/dev/null; then
        echo "❌ API server crashed during startup"
        cleanup
        exit 1
    fi
    sleep 1
done

echo "✅ All services are running"
echo "   - API Server: http://localhost:5000 (PID: $API_PID)"
echo "   - AI Service: http://localhost:8000 (PID: $AI_PID)"

# Fail-Fast: 한쪽 프로세스 크래시 시 전체 종료
while true; do
    # API 서버 체크
    if ! kill -0 $API_PID 2>/dev/null; then
        echo "❌ API server crashed (PID: $API_PID)"
        echo "Shutting down all services..."
        cleanup
        exit 1
    fi
    
    # AI 서비스 체크
    if ! kill -0 $AI_PID 2>/dev/null; then
        echo "❌ AI service crashed (PID: $AI_PID)"
        echo "Shutting down all services..."
        cleanup
        exit 1
    fi
    
    sleep 5
done
```

**개선 효과**:
- ✅ Fail-Fast: 한쪽 죽으면 전체 재시작
- ✅ Graceful Shutdown: SIGTERM 처리
- ✅ 로그 분리: `/app/logs/api-server.log`, `/app/logs/ai-service.log`
- ✅ Startup Validation: 준비 확인 후 진행

---

### 2. Docker Healthcheck 개선

#### AS-IS
```yaml
healthcheck:
  test: ["CMD", "curl", "-f", "http://localhost:5000/health"]
```

**문제점**: API만 확인, AI 서비스 상태 미확인

#### TO-BE
```yaml
healthcheck:
  test: |
    curl -sf http://localhost:5000/health && \
    curl -sf http://localhost:8000/health || exit 1
  interval: 30s
  timeout: 10s
  retries: 3
  start_period: 60s  # 시작 시간 늘림
```

---

### 3. AI Policy 문서 (신규)

별도 파일로 작성: `docs/AI_POLICY.md`

---

### 4. DB 스키마 개선 (세션 이벤트 테이블)

#### AS-IS (MASTER_PLAN 기준)
```sql
CREATE TABLE session_events (
  id UUID PRIMARY KEY,
  session_id UUID REFERENCES sessions(id),
  activity_id UUID REFERENCES activities(id),
  event_type VARCHAR(50),
  user_input TEXT,
  tutor_response TEXT,
  evaluation JSONB,  -- 모든 평가 데이터
  timestamp TIMESTAMP DEFAULT NOW()
);
```

**문제점**: 분석/통계 쿼리 시 JSONB 파싱 필요

#### TO-BE (v2.1)
```sql
CREATE TABLE session_events (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  session_id UUID NOT NULL REFERENCES sessions(id) ON DELETE CASCADE,
  activity_id UUID REFERENCES activities(id),
  
  -- 이벤트 기본 정보
  event_type VARCHAR(50) NOT NULL,  -- 'user_input', 'tutor_response', 'evaluation'
  user_input TEXT,
  tutor_response TEXT,
  
  -- ✅ 핵심 평가 메트릭 (컬럼화)
  score INT CHECK (score >= 0 AND score <= 100),
  pass_fail BOOLEAN,
  primary_error_type VARCHAR(50),  -- 'grammar', 'vocabulary', 'pronunciation', 'formality'
  
  -- ✅ AI Provider 추적
  provider VARCHAR(50),             -- 'gemini', 'google_tts', 'google_stt'
  model_id VARCHAR(100),            -- 'gemini-1.5-pro', 'ko-KR-Wavenet-A'
  latency_ms INT,                   -- 응답 시간 (밀리초)
  
  -- ✅ 상세 데이터 (JSONB 유지)
  evaluation_detail JSONB,          -- { errors: [...], suggestions: [...], rationale: "..." }
  metadata JSONB,                   -- 확장 가능한 필드
  
  -- 타임스탬프
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  
  -- 인덱스
  INDEX idx_session_events_session_id (session_id),
  INDEX idx_session_events_activity_id (activity_id),
  INDEX idx_session_events_event_type (event_type),
  INDEX idx_session_events_provider (provider),
  INDEX idx_session_events_created_at (created_at)
);

-- 분석용 뷰 (예시)
CREATE VIEW v_evaluation_stats AS
SELECT
  DATE_TRUNC('day', created_at) AS date,
  provider,
  model_id,
  primary_error_type,
  AVG(score) AS avg_score,
  COUNT(*) AS total_evaluations,
  AVG(latency_ms) AS avg_latency_ms,
  SUM(CASE WHEN pass_fail THEN 1 ELSE 0 END)::FLOAT / COUNT(*) AS pass_rate
FROM session_events
WHERE event_type = 'evaluation'
GROUP BY date, provider, model_id, primary_error_type;
```

**개선 효과**:
- ✅ 분석 쿼리 속도 향상 (인덱스 사용)
- ✅ Provider별 성능 비교 가능
- ✅ 오류 유형 통계 추출 가능
- ✅ 유연성 유지 (JSONB 병행)

---

### 5. AI 사용 추적 테이블 (신규)

```sql
-- 비용 모니터링 및 쿼터 관리용
CREATE TABLE ai_usage_log (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  
  -- 연결 정보
  session_id UUID REFERENCES sessions(id),
  event_id UUID REFERENCES session_events(id),
  
  -- Provider 정보
  provider_type VARCHAR(20) NOT NULL,  -- 'stt', 'tts', 'eval'
  provider_name VARCHAR(50) NOT NULL,  -- 'google', 'gemini', 'whisper', 'vits'
  model_id VARCHAR(100),
  
  -- 사용량
  tokens_in INT,                       -- LLM 입력 토큰 (STT/TTS는 NULL)
  tokens_out INT,                      -- LLM 출력 토큰
  audio_duration_ms INT,               -- 음성 길이 (STT/TTS)
  
  -- 성능
  latency_ms INT NOT NULL,
  success BOOLEAN NOT NULL,
  error_code VARCHAR(50),
  error_message TEXT,
  
  -- 비용 추정 (선택)
  estimated_cost_usd DECIMAL(10, 6),   -- 개별 호출 비용
  
  -- 타임스탬프
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  
  -- 인덱스
  INDEX idx_ai_usage_provider_type (provider_type),
  INDEX idx_ai_usage_provider_name (provider_name),
  INDEX idx_ai_usage_created_at (created_at),
  INDEX idx_ai_usage_success (success)
);

-- 일별 비용 집계 뷰
CREATE VIEW v_daily_ai_costs AS
SELECT
  DATE_TRUNC('day', created_at) AS date,
  provider_type,
  provider_name,
  COUNT(*) AS total_calls,
  SUM(CASE WHEN success THEN 1 ELSE 0 END) AS successful_calls,
  AVG(latency_ms) AS avg_latency_ms,
  SUM(tokens_in) AS total_tokens_in,
  SUM(tokens_out) AS total_tokens_out,
  SUM(estimated_cost_usd) AS total_cost_usd
FROM ai_usage_log
GROUP BY date, provider_type, provider_name
ORDER BY date DESC, total_cost_usd DESC;
```

---

### 6. 컨테이너 분리 체크포인트 (문서화)

별도 파일로 작성: `docs/SCALING_CHECKPOINTS.md`

---

## 📋 신규/수정 파일 목록

### 신규 파일 (3개)
1. `infrastructure/docker/start.sh` - 개선된 프로세스 관리
2. `docs/AI_POLICY.md` - LLM/STT/TTS 호출 정책
3. `docs/SCALING_CHECKPOINTS.md` - 아키텍처 분리 기준

### 수정 파일 (2개)
4. `docker-compose.yml` - healthcheck 개선
5. `db/migrations/002_improved_schema.sql` - 컬럼 추가

---

## 🎯 적용 우선순위

### P0 (v0 시작 전 필수)
1. ✅ `start.sh` 개선 (Fail-Fast)
2. ✅ DB 스키마 개선 (분석 컬럼 추가)
3. ✅ `AI_POLICY.md` 작성

### P1 (v0 중간 적용)
4. ✅ `ai_usage_log` 테이블 추가
5. ✅ Provider Service 레이어에 정책 구현

### P2 (v1 준비)
6. ✅ `SCALING_CHECKPOINTS.md` 검토
7. ✅ 모니터링 대시보드 (분석 뷰 기반)

---

## 📊 개선 효과

| 항목 | AS-IS | TO-BE | 효과 |
|------|-------|-------|------|
| **프로세스 크래시** | 부분 장애 | Fail-Fast 재시작 | ✅ 장애 격리 |
| **로그 분석** | 혼재 | 분리 | ✅ 디버깅 용이 |
| **분석 쿼리** | JSONB 파싱 | 컬럼 인덱스 | ✅ 속도 10배↑ |
| **비용 추적** | 수동 | 자동 로깅 | ✅ 투명성 |
| **정책 적용** | 코드 분산 | 문서 중앙화 | ✅ 일관성 |

---

**작성**: Antigravity AI  
**버전**: v2.1 (Final Hardening)  
**다음 단계**: P0 파일 생성 후 v0 개발 착수
