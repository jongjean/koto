# Korean Together - Scaling Checkpoints

**작성일**: 2026-01-15  
**버전**: 1.0  
**목적**: 아키텍처 진화 시점을 명확히 정의

---

## 📌 문서 목적

"언제 서비스를 분리해야 하는가?"를 **정량적 지표**로 정의하여, 감정이나 추측이 아닌 **데이터 기반 의사결정**을 가능하게 합니다.

---

## 🎯 현재 아키텍처 (v0, v1)

```
┌─────────────────────────┐
│    koto-app Container   │
│  (Node.js + Python)     │
│                         │
│  ┌─────────┬─────────┐  │
│  │API:5000 │ AI:8000 │  │
│  └─────────┴─────────┘  │
└─────────────────────────┘
```

**장점**: 
- ✅ 배포 단순
- ✅ 로컬 통신 (내부 포트)
- ✅ 운영 복잡도 최소

**한계**:
- ⚠️ 동시성 제약 (한 프로세스 병목)
- ⚠️ 리소스 독립 스케일링 불가

---

## 📊 Checkpoint 1: AI 컨테이너 분리

### 🚨 분리 결정 조건 (v1 종료 시점에 판단)

#### 조건 A: API 응답 지연 (필수)
```sql
-- p95 API 응답시간 측정 (30분 이상 지속)
SELECT PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY latency_ms) AS p95_latency
FROM session_events
WHERE event_type = 'tutor_response'
  AND created_at > NOW() - INTERVAL '30 minutes';

-- 임계값: > 800ms
```

#### 조건 B: AI 병목 비율 (필수)
```sql
-- AI 호출 시간이 전체 지연의 비율
SELECT
  AVG(ai_latency_ms::FLOAT / total_latency_ms) AS ai_ratio
FROM (
  SELECT
    e.latency_ms AS total_latency_ms,
    a.latency_ms AS ai_latency_ms
  FROM session_events e
  JOIN ai_usage_log a ON e.id = a.event_id
  WHERE e.created_at > NOW() - INTERVAL '1 hour'
) sub;

-- 임계값: > 0.6 (60%)
```

#### 조건 C: 연결 안정성 (권장)
```sql
-- WebSocket disconnect rate
SELECT
  COUNT(CASE WHEN disconnect_reason = 'timeout' THEN 1 END)::FLOAT / COUNT(*) AS disconnect_rate
FROM websocket_sessions
WHERE created_at > NOW() - INTERVAL '1 hour';

-- 임계값: > 0.01 (1%)
```

#### 조건 D: 동시 세션 수 (트리거)
```sql
-- 최근 1시간 피크 동시 세션
SELECT MAX(concurrent_sessions)
FROM (
  SELECT created_at, COUNT(*) AS concurrent_sessions
  FROM sessions
  WHERE status = 'active'
  GROUP BY DATE_TRUNC('minute', created_at)
) sub
WHERE created_at > NOW() - INTERVAL '1 hour';

-- 임계값: >= 50
```

### ✅ 분리 결정 룰

| 조건 조합 | 판정 | 액션 |
|-----------|------|------|
| A + B | **권고 (Recommended)** | 다음 스프린트에 분리 계획 수립 |
| A + B + C | **필수 (Required)** | 즉시 분리 작업 시작 |
| A + B + D | **긴급 (Urgent)** | 이번 주 내 분리 |
| D만 충족 | 관찰 (Monitor) | 일주일 모니터링 후 재평가 |

---

### 🔄 분리 후 아키텍처 (v1+)

```
┌──────────────────┐     ┌──────────────────┐
│   koto-api       │────▶│    koto-ai       │
│  (Node.js:5000)  │     │  (Python:8001)   │
└──────────────────┘     └──────────────────┘
        │                        │
        └────────┬───────────────┘
                 ▼
        ┌──────────────────┐
        │  postgres/redis  │
        └──────────────────┘
```

**변경 사항**:
```yaml
# docker-compose.yml
services:
  koto-api:
    environment:
      AI_SERVICE_URL: http://koto-ai:8001  # 변경
  
  koto-ai:
    build: ./ai
    ports:
      - "127.0.0.1:8001:8001"
```

**마이그레이션 절차**:
1. `docker-compose.yml` 분리
2. 환경변수 업데이트
3. Blue-Green 배포 (기존 유지, 신규 테스트)
4. 트래픽 전환
5. 기존 컨테이너 종료

---

## 📊 Checkpoint 2: Database Read Replica

### 🚨 분리 결정 조건 (v1 중반 이후)

#### 조건 A: DB CPU 사용률
```bash
# 30분 평균 CPU > 70%
docker stats koto-postgres --no-stream | awk '{print $3}'
```

#### 조건 B: 분석 쿼리 영향
```sql
-- 보고서 쿼리가 트랜잭션에 미치는 영향
-- 실행 중인 쿼리 중 분석 쿼리 비율
SELECT COUNT(*) FROM pg_stat_activity
WHERE state = 'active' AND query LIKE '%v_evaluation_stats%';

-- 임계값: > 5개 동시 실행
```

#### 조건 C: 동시 활성 세션
```sql
SELECT COUNT(*) FROM sessions WHERE status = 'active';

-- 임계값: >= 100
```

### ✅ Read Replica 도입 기준
- A + B 충족 시 권고
- A + B + C 충족 시 필수

---

## 📊 Checkpoint 3: Redis 메모리 증설 또는 분리

### 🚨 증설/분리 조건

#### 메모리 사용률
```bash
# 80% 초과 시 증설 검토
docker exec koto-redis redis-cli INFO memory | grep used_memory_human

# maxmemory 정책 확인
docker exec koto-redis redis-cli CONFIG GET maxmemory-policy
```

#### 키 개수 증가율
```bash
# 일일 증가율이 20% 이상 지속 시
docker exec koto-redis redis-cli DBSIZE
```

### ✅ 조치
1. **증설**: 512MB → 2GB (docker-compose 수정)
2. **TTL 정책 강화**: 세션 캐시 1시간 → 30분
3. **분리** (극단): 세션용 Redis / 캐시용 Redis 분리

---

## 📊 Checkpoint 4: MinIO → CDN 전환

### 🚨 전환 조건 (v2 이후)

#### 트래픽 비용
```sql
-- 일일 TTS 파일 다운로드 수
SELECT COUNT(*) FROM ai_usage_log
WHERE provider_type = 'tts'
  AND created_at > NOW() - INTERVAL '1 day';

-- 임계값: 10,000회/일 초과
```

#### 대역폭
```bash
# MinIO 네트워크 사용량 (일일 10GB 초과 시)
docker stats koto-minio --no-stream | awk '{print $8}'
```

### ✅ 전환 옵션
1. **CloudFlare R2** (S3 호환, 트래픽 무료)
2. **AWS CloudFront + S3**
3. **Google Cloud CDN + Storage**

---

## 📊 Checkpoint 5: 리전 분리 (다국가 확장)

### 🚨 분리 조건 (Phase H2)

#### 국가별 사용자 수
```sql
SELECT region, COUNT(DISTINCT user_id) AS users
FROM sessions
WHERE created_at > NOW() - INTERVAL '30 days'
GROUP BY region
HAVING COUNT(DISTINCT user_id) > 1000;
```

#### 지연 시간 (해외 사용자)
```bash
# 인도네시아 → 한국 서버 레이턴시
# 평균 > 300ms 시 리전 분리 검토
```

### ✅ 리전별 서버 구성
```
Korea Server (koto-kr.com):
  - API + AI + DB (한국 사용자)

Indonesia Server (koto-id.com):
  - API + AI + DB (인도네시아 사용자)
  - 언어팩: ko-id

Central (koto.com):
  - 콘텐츠 동기화
  - 모델 업데이트 배포
  - 통합 대시보드
```

---

## 📊 모니터링 대시보드 (필수)

### v0 단계
```sql
-- 일일 체크 쿼리 (수동)
-- 1. API 응답시간
SELECT PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY latency_ms) FROM session_events;

-- 2. AI 사용량
SELECT provider_name, COUNT(*) FROM ai_usage_log WHERE created_at > NOW() - INTERVAL '1 day' GROUP BY 1;

-- 3. 동시 세션
SELECT COUNT(*) FROM sessions WHERE status = 'active';
```

### v1 단계
```yaml
# Grafana 대시보드 (선택)
- API p95 latency (목표: < 800ms)
- AI provider별 성공률 (목표: > 95%)
- 동시 세션 (임계값: 50)
- 일일 비용 (알림: > $30)
```

---

## 🎯 의사결정 프로세스

### 주간 체크 (매주 금요일)
1. 체크포인트 지표 수집
2. 임계값 도달 여부 확인
3. 필요 시 다음 주 액션 계획

### 긴급 대응 (실시간)
```
조건 A+B+C+D 모두 충족 → Slack/Email 알림
→ 24시간 내 긴급 회의
→ 48시간 내 분리 작업 시작
```

---

## 📋 체크리스트 (분리 작업 전)

### AI 컨테이너 분리 시
- [ ] docker-compose.yml AI 서비스 분리
- [ ] 환경변수 `AI_SERVICE_URL` 업데이트
- [ ] 네트워크 통신 테스트 (koto-network)
- [ ] 로그 수집 확인 (Filebeat 또는 볼륨)
- [ ] Blue-Green 배포 계획
- [ ] 롤백 계획

### DB Read Replica 추가 시
- [ ] PostgreSQL Replication 설정
- [ ] 분석 쿼리 Read Replica로 라우팅
- [ ] Lag 모니터링 (< 1초)
- [ ] Failover 테스트

---

**작성**: Antigravity AI  
**검토 주기**: 매주 금요일  
**다음 업데이트**: v1 종료 시점 (2026년 4월 예상)
