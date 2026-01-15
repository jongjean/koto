# Korean Together - AI Service Policy

**작성일**: 2026-01-15  
**버전**: 1.0  
**적용 범위**: v0, v1, v2 전체

---

## 📌 문서 목적

AI Service (STT/TTS/LLM)의 **호출 정책, 타임아웃, 폴백, 비용 관리**를 명확히 정의하여 운영 일관성을 확보합니다.

**이 문서는 코드보다 우선합니다.** 정책 변경 시 코드를 수정하되, 이 문서를 먼저 업데이트하세요.

---

## 🎯 기본 원칙

### 1. 단일 공급자 원칙 (Single Provider per Phase)
- **v0**: 외부 API만 (Google STT/TTS, Gemini)
- **v1**: 외부 API 계속 (로컬 모델은 테스트만)
- **v2**: 로컬 우선 + 외부 폴백

### 2. Fail-Fast & Fallback
- 빠른 실패 감지
- 명확한 폴백 체인
- 사용자에게 "로딩 중" 상태 최소화

### 3. 비용 투명성
- 모든 AI 호출을 로깅
- 일일 비용 추정
- 쿼터 초과 사전 감지

---

## 🗣️ STT (Speech-to-Text) 정책

### v0 & v1: Google Speech-to-Text API

#### 호출 조건
```
조건: 음성 파일 업로드 완료 (POST /audio/upload)
트리거: WebSocket 이벤트 { type: "audio_uploaded", audio_id }
```

#### 파라미터
| 설정 | 값 | 근거 |
|------|-----|------|
| **Language** | `ko-KR` | 한국어 학습 |
| **Encoding** | `WEBM_OPUS` or `LINEAR16` | Unity 녹음 포맷 |
| **Sample Rate** | `48000` Hz | 브라우저 기본값 |
| **Model** | `default` (v0), `command_and_search` (v1) | 짧은 문장 최적화 |

#### 타임아웃 & 재시도
```yaml
Primary Timeout: 3초
Retry: 0회  # 음성은 재시도 의미 약함
Fallback: v2에서만 활성화 (Whisper)
```

#### 실패 처리
```javascript
if (stt_failed) {
  return {
    type: "stt_failed",
    message: "음성을 인식할 수 없습니다. 다시 말씀해 주세요.",
    suggest_text_input: true  // 텍스트 입력 버튼 표시
  };
}
```

#### 비용 추정 (2026년 기준)
```
Google STT: $0.006 / 15초
예상 사용량: 1,000회/일 × 평균 5초
일일 비용: $2.00
```

---

### v2: Whisper (로컬 GPU) + Google Fallback

#### Primary: Whisper
```python
# ai/providers/stt/whisper_stt.py
model = "base"  # tiny/base/small (VRAM 제약)
device = "cuda"  # GPU 사용
timeout = 2초    # 로컬이므로 빠름
```

#### Fallback: Google STT
```python
if whisper_failed or latency > 3초:
    fallback_to_google_stt()
```

---

## 🔊 TTS (Text-to-Speech) 정책

### v0 & v1: Google Text-to-Speech API

#### 호출 조건
```
조건: 평가 완료 후 피드백 생성
입력: 튜터 응답 텍스트 (한국어)
```

#### 파라미터
| 설정 | 값 | 근거 |
|------|-----|------|
| **Voice** | `ko-KR-Wavenet-A` | 자연스러운 여성 목소리 |
| **Language** | `ko-KR` | |
| **Speaking Rate** | `1.0` | 정상 속도 |
| **Pitch** | `0.0` | 기본 음높이 |
| **Audio Encoding** | `MP3` | 파일 크기 최적화 |

#### 타임아웃 & 재시도
```yaml
Primary Timeout: 2초
Retry: 1회 (간소화된 텍스트)
Fallback: v2에서만 (VITS)
```

#### 실패 처리
```javascript
if (tts_failed) {
  // 텍스트만 반환, 음성 없이
  return {
    type: "tutor_response",
    text: "좋아요! 다음으로 넘어가볼까요?",
    audio_url: null,  // 음성 없음
    fallback_mode: true
  };
}
```

#### 비용 추정
```
Google TTS: $4.00 / 1M characters
예상 사용량: 1,000회/일 × 평균 50자
일일 비용: $0.20
```

---

### v2: VITS (로컬 GPU) + Google Fallback

#### Primary: VITS
```python
model_path = "/app/models/vits_korean.pth"
device = "cuda"
timeout = 1초  # 로컬 GPU 빠름
```

#### Fallback: Google TTS
```python
if vits_failed or latency > 2초:
    fallback_to_google_tts()
```

---

## 🧠 LLM Evaluation 정책 (핵심)

### v0, v1, v2: Gemini 1.5 Pro

#### 호출 게이트 (언제 LLM을 호출하는가?)

```python
# 규칙 기반 평가 먼저 실행
rule_result = evaluate_by_rules(user_input, expected_pattern)

if rule_result.confidence >= 0.9:
    # 규칙으로 충분 → LLM 호출 생략
    return {
        "source": "rule",
        "score": rule_result.score,
        "feedback": rule_result.feedback,
        "llm_skipped": True
    }

elif 0.6 <= rule_result.confidence < 0.9:
    # 애매함 → LLM으로 정교한 평가
    llm_result = evaluate_by_llm(user_input, context)
    return {
        "source": "hybrid",
        "score": llm_result.score,
        "feedback": llm_result.feedback,
        "rule_score": rule_result.score  # 비교용
    }

else:  # confidence < 0.6
    # 확실히 틀림 → LLM으로 교정 제안
    llm_result = evaluate_by_llm(user_input, context, mode="correction")
    return {
        "source": "llm_correction",
        "score": llm_result.score,
        "feedback": llm_result.feedback,
        "retry_suggested": True
    }
```

#### 타임아웃 & 재시도
```yaml
Primary Timeout: 2초
Retry: 1회
  - 첫 실패 시: 프롬프트 간소화 (예: 상세 설명 제거, 피드백만)
  - 재시도 타임아웃: 2초
Fallback: 기본 피드백 템플릿
```

#### 프롬프트 구조 (표준)

**Full Prompt (confidence < 0.9)**
```python
prompt = f"""
You are a Korean language tutor evaluating a beginner's response.

**Context:**
- Lesson: {lesson_title}
- Activity: {activity_description}
- Expected Pattern: {expected_pattern}

**User Response:** {user_text}

**Evaluate:**
1. Score (0-100)
2. Primary Error Type (grammar/vocabulary/pronunciation/formality)
3. Specific Errors (list)
4. Corrected Sentence
5. Feedback (encouraging, in Korean)

**Output JSON:**
{{
  "score": 85,
  "primary_error_type": "grammar",
  "errors": [{{"type": "particle", "original": "은", "correct": "는", "reason": "..."}}],
  "corrected": "저는 학생입니다.",
  "feedback": "거의 완벽해요! 조사만 고치면 됩니다."
}}
"""
```

**Simplified Prompt (재시도)**
```python
prompt = f"""
Korean tutor: Score this response (0-100) and give brief feedback in Korean.
User said: {user_text}
Expected: {expected_pattern}

JSON: {{"score": 80, "feedback": "좋아요!"}}
"""
```

#### 실패 처리
```javascript
if (llm_failed_after_retry) {
  // 기본 템플릿 사용
  return {
    type: "evaluation_complete",
    score: 50,  // 중립 점수
    feedback: "답변 감사해요. 다음 문제로 넘어가볼까요?",
    fallback_mode: true,
    suggest_retry: true
  };
}
```

#### 비용 추정
```
Gemini 1.5 Pro: $0.00025 / 1K tokens (입력), $0.005 / 1K tokens (출력)
예상 사용량:
  - 입력: 300 tokens/평가
  - 출력: 150 tokens/평가
  - 1,000회/일
일일 비용: (300×0.00025 + 150×0.005) × 1,000 = $0.075 + $0.75 = $0.825
```

---

## 💰 비용 모니터링

### 일일 알림 임계값
```yaml
STT: $10/일 초과 시 알림
TTS: $5/일 초과 시 알림
LLM: $20/일 초과 시 알림
Total: $30/일 초과 시 알림 + 로그 검토
```

### 쿼터 관리
```sql
-- 시간당 호출 제한 (예시)
SELECT COUNT(*) FROM ai_usage_log
WHERE provider_name = 'gemini'
  AND created_at > NOW() - INTERVAL '1 hour';

-- 1시간 1,000회 초과 시 → rate limit warning
```

### 주간 리포트 (자동)
```
매주 월요일 오전 9시:
- 지난 주 총 비용
- Provider별 비용 분포
- 평균 latency
- 실패율
- 이상 패턴 (예: 특정 시간대 폭증)
```

---

## 📊 성능 목표 (SLA)

### v0 & v1 (외부 API)
| Service | p95 Latency | Success Rate | 목표 |
|---------|-------------|--------------|------|
| STT | < 3초 | > 95% | 음성 인식 |
| TTS | < 2초 | > 98% | 음성 생성 |
| LLM Eval | < 2초 | > 90% | 평가/피드백 |

### v2 (로컬 GPU + 폴백)
| Service | p95 Latency | Success Rate | 목표 |
|---------|-------------|--------------|------|
| STT | < 1.5초 | > 97% | Whisper GPU |
| TTS | < 1초 | > 98% | VITS GPU |
| LLM Eval | < 2초 | > 95% | Gemini (변동 없음) |

---

## 🔧 정책 변경 프로세스

### 변경이 필요한 경우
1. 이 문서 수정 (PR)
2. 코드 수정
3. 테스트 (성능/비용)
4. 배포 + 모니터링

### 긴급 변경 (쿼터 초과, 장애)
1. 환경변수로 임시 변경 (예: `STT_PROVIDER=fallback`)
2. 사후 문서 업데이트

---

## 📝 체크리스트 (구현 시 확인)

### Provider 구현
- [ ] Timeout 설정 (`asyncio.wait_for`)
- [ ] Retry 로직 (횟수, 간격)
- [ ] Fallback 체인
- [ ] Error Handling (명확한 에러 타입)

### Service 레이어
- [ ] 정책 준수 (게이트, 타임아웃)
- [ ] 로깅 (`ai_usage_log` 테이블)
- [ ] 비용 추정 (선택)
- [ ] 메트릭 (latency, success_rate)

### 모니터링
- [ ] 일일 비용 집계 쿼리
- [ ] 실패율 알림 (> 10%)
- [ ] Latency 알림 (p95 > 목표 + 50%)

---

**작성**: Antigravity AI  
**검토**: 운영 팀 필수  
**다음 업데이트**: v1 종료 시점 (로컬 모델 도입 준비)
