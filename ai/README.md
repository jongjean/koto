# AI Service Provider Pattern 구현 예시

이 디렉토리는 **개선된 아키텍처(v2.0)**에 따라 AI 서비스를 Provider 패턴으로 분리한 구조입니다.

## 디렉토리 구조

```
ai/
├── providers/              # Provider 인터페이스 및 구현체
│   ├── __init__.py
│   ├── base.py            # ABC (Abstract Base Class)
│   ├── stt/
│   │   ├── __init__.py
│   │   ├── google_stt.py
│   │   └── whisper_stt.py (v2)
│   ├── tts/
│   │   ├── __init__.py
│   │   ├── google_tts.py
│   │   └── vits_tts.py (v2)
│   └── eval/
│       ├── __init__.py
│       └── gemini_eval.py
├── services/              # 비즈니스 로직
│   ├── __init__.py
│   ├── stt_service.py
│   ├── tts_service.py
│   └── eval_service.py
├── routes/                # FastAPI 라우트
│   ├── __init__.py
│   ├── stt.py
│   ├── tts.py
│   └── eval.py
├── models/                # Pydantic 모델
│   ├── __init__.py
│   ├── stt_models.py
│   ├── tts_models.py
│   └── eval_models.py
├── config/
│   ├── __init__.py
│   └── settings.py
├── utils/
│   ├── __init__.py
│   └── audio_utils.py
├── main.py                # FastAPI 앱
├── requirements.txt
└── README.md              # 이 파일
```

## 핵심 개념

### Provider 패턴
각 AI 기능(STT/TTS/평가)을 **추상 인터페이스(ABC)**로 정의하고, 여러 구현체(Google Cloud, 로컬 모델 등)를 교체 가능하게 만듭니다.

**장점**:
1. 공급자 변경 = 환경변수 1줄 수정
2. 폴백 로직 명확화
3. 테스트 용이 (Mock Provider)
4. 비용 최적화 (저렴한 Provider로 전환)

### 폴백 정책
```
Primary Provider 실패 → Fallback Provider → Error
```

예: Google STT 쿼터 초과 → Whisper 로컬 모델 → 503 Error

## 환경 변수 설정

```bash
# .env
STT_PROVIDER=google        # google | whisper
TTS_PROVIDER=google        # google | vits
EVAL_PROVIDER=gemini       # gemini

# Google Cloud (STT/TTS)
GOOGLE_APPLICATION_CREDENTIALS=/app/secrets/gcp-sa.json

# Gemini
GEMINI_API_KEY=AIza***

# Whisper (v2, 로컬 GPU)
WHISPER_MODEL_SIZE=base    # tiny | base | small | medium
WHISPER_DEVICE=cuda        # cuda | cpu

# VITS (v2, 로컬 GPU)
VITS_MODEL_PATH=/app/models/vits_korean.pth
```

## 사용 예시

### STT 사용
```python
from services.stt_service import STTService

stt_service = STTService()
result = await stt_service.transcribe(audio_bytes)

print(result.text)          # "안녕하세요"
print(result.provider)      # "google"
print(result.confidence)    # 0.95
```

### TTS 사용
```python
from services.tts_service import TTSService

tts_service = TTSService()
result = await tts_service.synthesize("좋은 아침입니다!", voice="ko-KR-Wavenet-A")

print(result.audio_url)     # MinIO presigned URL
print(result.duration_ms)   # 2500
```

### 평가 사용
```python
from services.eval_service import EvalService

eval_service = EvalService()
result = await eval_service.evaluate(
    user_text="저는 학생이에요",
    expected_pattern="저는 {직업}입니다",
    context={"lesson_id": "les_001", "difficulty": "A1"}
)

print(result.score)         # 80
print(result.errors)        # [{"type": "formality", "suggestion": "이에요 → 입니다"}]
print(result.feedback)      # "거의 정확해요! 격식체를 사용하면 더 좋습니다."
```

## v0 → v1 → v2 전환

### v0 (현재)
- Google STT/TTS만 사용
- 로컬 모델 코드 작성만 (실행 X)

### v1
- Google STT/TTS 계속 사용
- Whisper/VITS Provider 테스트

### v2
- 비용 최적화를 위해 로컬 모델 우선 사용
- 쿼터 초과 시 Google API로 폴백

## 성능 목표

| 작업 | v0 (외부 API) | v2 (로컬 모델) |
|------|---------------|----------------|
| STT | ~2초 | ~1초 (GPU) |
| TTS | ~1.5초 | ~0.5초 (GPU) |
| 평가 | ~1초 | ~1초 (Gemini 계속) |

## 다음 단계

1. `providers/base.py` 작성 (ABC)
2. `providers/stt/google_stt.py` 구현
3. `services/stt_service.py` 작성
4. `routes/stt.py` FastAPI 엔드포인트
5. 테스트 작성
