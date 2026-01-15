# 🎯 Korean Together - Phase 1 마일스톤 (ver0.1 ~ ver0.5)

**목표**: AI 서버 완성 → 콘텐츠 확장 → Unity 메타버스 연동  
**기간**: 약 12주 (3개월)  
**최종 산출물**: Unity 메타버스에서 인도네시아어-한국어 학습 서비스 완성

---

## 📊 전체 마일스톤 개요

```
Phase 1: 핵심 엔진 완성 (ver0.1 ~ ver0.5)
├─ ver0.1: AI 서버 연동 (2주)        ✅ 기술 검증
├─ ver0.2: 초급 콘텐츠 (2주)         ✅ 서비스 기본
├─ ver0.3: 중고급 콘텐츠 (2주)       ✅ 완전한 커리큘럼
├─ ver0.4: 인니어 적용 (2주)         ✅ 글로벌 준비
└─ ver0.5: Unity 연동 (4주)          ✅ 메타버스 완성
```

---

## 🗓️ 상세 마일스톤

### ver0.1: AI 서버 완벽 연동 (Week 1-2)

**목표**: 메타버스 없이 텍스트 기반 한국어-영어 학습 루프 완성

#### 핵심 기능
- [x] AI Provider 구조 완성 (Gemini, Google TTS)
- [x] Database 스키마 구축
- [x] Session 관리 (시작/종료/진도)
- [x] 평가 엔진 (규칙 기반 + LLM 하이브리드)
- [x] 피드백 생성 (한국어 → 영어 설명)

#### 기술 검증 항목
| 항목 | 목표 | 검증 방법 |
|------|------|-----------|
| API 응답 시간 | < 2초 | Postman 테스트 |
| Gemini 평가 정확도 | > 85% | 샘플 100개 수동 검증 |
| TTS 음질 | 자연스러움 | 청취 테스트 |
| Session 안정성 | 100회 연속 무오류 | 자동화 테스트 |

#### 테스트 시나리오 (최소)
```
1. 사용자 입력: "안녕하세요"
   → Gemini 평가: 95점
   → TTS 응답: "완벽해요! 반갑습니다."

2. 사용자 입력: "저는 학생이에요"
   → Gemini 평가: 80점 (격식체 권장)
   → TTS 응답: "거의 정확해요. '입니다'를 쓰면 더 격식있어요."

3. 사용자 입력: "사과를 좋아해요"
   → Gemini 평가: 100점
   → TTS 응답: "Perfect! 정확합니다."
```

#### 산출물
- [ ] Postman Collection (API 전체 테스트)
- [ ] API 문서 (Swagger/OpenAPI)
- [ ] 평가 정확도 리포트
- [ ] 성능 벤치마크 (latency, success rate)

---

### ver0.2: 초급 5종 레슨 (Week 3-4)

**목표**: A1 레벨 5개 레슨 완성 (인사, 자기소개, 쇼핑, 식당, 교통)

#### 레슨 구조
```
Lesson 1: 인사하기 (Greetings)
├─ Stage 1: 기본 인사 (안녕하세요, 반갑습니다)
├─ Stage 2: 시간대별 인사 (좋은 아침이에요, 안녕히 주무세요)
└─ Stage 3: 상황별 인사 (처음 뵙겠습니다, 잘 부탁드립니다)

Lesson 2: 자기소개 (Self-Introduction)
├─ Stage 1: 이름 (제 이름은 ~입니다)
├─ Stage 2: 국적/직업 (저는 ~에서 왔어요, 저는 ~입니다)
└─ Stage 3: 취미 (저는 ~를 좋아해요)

Lesson 3: 쇼핑 (Shopping)
├─ Stage 1: 가격 묻기 (이거 얼마예요?)
├─ Stage 2: 크기/색상 (더 큰 거 있어요? 파란색 있어요?)
└─ Stage 3: 결제하기 (카드로 할게요)

Lesson 4: 식당 (Restaurant)
├─ Stage 1: 주문하기 (불고기 주세요)
├─ Stage 2: 요청하기 (물 좀 주세요, 매운 걸로 주세요)
└─ Stage 3: 계산하기 (계산서 주세요)

Lesson 5: 교통 (Transportation)
├─ Stage 1: 방향 묻기 (지하철역이 어디예요?)
├─ Stage 2: 택시 타기 (명동으로 가주세요)
└─ Stage 3: 버스 타기 (이 버스 강남 가요?)
```

#### 기대 패턴 (Expected Patterns) 예시
```json
{
  "lesson_id": "les_greeting_001",
  "stage_id": "stg_basic_greeting",
  "activity_id": "act_hello",
  "expected_patterns": [
    {
      "pattern": "안녕하세요",
      "variations": ["안녕하십니까", "안녕"],
      "formality": "formal",
      "score_range": [90, 100]
    },
    {
      "pattern": "반갑습니다",
      "variations": ["만나서 반가워요", "반가워요"],
      "formality": "neutral",
      "score_range": [85, 95]
    }
  ],
  "common_errors": [
    {
      "error_type": "pronunciation",
      "wrong": "안넝하세요",
      "correct": "안녕하세요",
      "feedback_en": "Make sure to pronounce '안녕' clearly."
    }
  ]
}
```

#### 산출물
- [ ] 5개 레슨 DB 데이터 (lessons, stages, activities)
- [ ] 기대 패턴 100개 이상
- [ ] 오류 패턴 50개 이상
- [ ] 각 레슨별 완료 테스트 (통과율 > 90%)

---

### ver0.3: 중급 5종 + 고급 5종 (Week 5-6)

**목표**: A2-B1 중급 5종, B2-C1 고급 5종 완성

#### 중급 레슨 (A2-B1)
```
Lesson 6: 은행/우체국 (Bank/Post Office)
├─ 계좌 개설, 송금, 우편 발송

Lesson 7: 병원 (Hospital)
├─ 증상 설명, 진료 예약, 약국

Lesson 8: 관공서 (Government Office)
├─ 비자 연장, 외국인등록증, 세금

Lesson 9: 거래/협상 (Negotiation)
├─ 가격 흥정, 약속 잡기, 의견 표현

Lesson 10: 감정 표현 (Emotions)
├─ 기쁨/슬픔, 불만/칭찬, 사과/감사
```

#### 고급 레슨 (B2-C1)
```
Lesson 11: 비즈니스 미팅 (Business Meeting)
├─ 프레젠테이션, 의견 제시, 반대 의견

Lesson 12: 뉴스/시사 토론 (Current Affairs)
├─ 뉴스 이해, 의견 개진, 토론

Lesson 13: 학술/전문 용어 (Academic)
├─ 논문 작성, 발표, 질의응답

Lesson 14: 한국 문화 (Korean Culture)
├─ 전통, 역사, 현대 문화

Lesson 15: 속어/관용구 (Slang/Idioms)
├─ 일상 속어, 관용 표현, 유머
```

#### 난이도별 평가 기준
| 레벨 | 목표 점수 | 문법 오류 허용 | 어휘 난이도 | 문장 길이 |
|------|-----------|----------------|-------------|-----------|
| **초급 (A1)** | 70+ | 3개 | 기본 500단어 | 5-10단어 |
| **중급 (A2-B1)** | 80+ | 2개 | 1,500단어 | 10-20단어 |
| **고급 (B2-C1)** | 90+ | 0-1개 | 3,000단어+ | 20단어+ |

#### 산출물
- [ ] 중급 5개 레슨 (각 3 stage, 10 activity)
- [ ] 고급 5개 레슨 (각 3 stage, 10 activity)
- [ ] 고급 평가 규칙 (문법/어휘/유창성)
- [ ] 레벨별 진도 로드맵

---

### ver0.4: 인도네시아어-한국어 적용 (Week 7-8)

**목표**: ko-id 언어팩 적용 및 인도네시아 학습자 최적화

#### 언어팩 구조
```json
// lang_packs/ko-id.json
{
  "code": "ko-id",
  "instruction_lang": "id",
  "target_lang": "ko",
  "evaluation_lang": "en",
  
  "ui_strings": {
    "welcome": "Selamat datang di Korean Together!",
    "start_lesson": "Mulai Pelajaran",
    "your_score": "Skor Anda: {score}",
    "try_again": "Coba lagi",
    "next_stage": "Lanjut ke tahap berikutnya"
  },
  
  "feedback_templates": {
    "excellent": "Sempurna! {detail}",
    "good": "Bagus! {detail}",
    "needs_improvement": "Hampir benar. {suggestion}",
    "grammar_error": "Kesalahan tata bahasa: {detail}",
    "vocabulary_error": "Gunakan kata '{correct}' lebih tepat."
  },
  
  "indonesian_error_patterns": [
    {
      "error_type": "particle_omission",
      "reason": "Bahasa Indonesia tidak memiliki partikel seperti 은/는/이/가",
      "common_mistakes": [
        {
          "wrong": "나 학교 가요",
          "correct": "나는 학교에 가요",
          "explanation_id": "Tambahkan partikel '는' setelah subjek"
        }
      ]
    },
    {
      "error_type": "honorific_confusion",
      "reason": "Sistem kehormatan bahasa Korea berbeda dengan Indonesia",
      "common_mistakes": [
        {
          "wrong": "선생님이 왔어",
          "correct": "선생님이 오셨어요",
          "explanation_id": "Gunakan bentuk hormat '오시다' untuk guru"
        }
      ]
    },
    {
      "error_type": "tense_confusion",
      "reason": "Bahasa Indonesia tidak memiliki konjugasi waktu yang kompleks",
      "common_mistakes": [
        {
          "wrong": "어제 먹어요",
          "correct": "어제 먹었어요",
          "explanation_id": "Gunakan bentuk lampau '먹었다' untuk kemarin"
        }
      ]
    }
  ],
  
  "lesson_intros": {
    "les_greeting_001": "Pelajaran ini mengajarkan cara menyapa dalam bahasa Korea...",
    "les_shopping_003": "Mari belajar berbelanja di Korea..."
  }
}
```

#### 인도네시아 학습자 최적화
```javascript
// ai/services/eval_service.js
async function evaluateForIndonesian(userText, expectedPattern, context) {
  const prompt = `
  You are evaluating a Korean learner whose native language is Indonesian.

  Common mistakes for Indonesian speakers:
  - Omitting particles (은/는/이/가/을/를)
  - Confusion with honorifics
  - Tense conjugation errors

  User input: ${userText}
  Expected: ${expectedPattern}

  Provide feedback in Indonesian (Bahasa Indonesia).

  OUTPUT FORMAT (JSON):
  {
    "score": 85,
    "primary_error_type": "particle_omission",
    "errors": [
      {
        "type": "grammar",
        "original": "나 학교 가요",
        "correct": "나는 학교에 가요",
        "reason_id": "Partikel subjek '는' diperlukan"
      }
    ],
    "feedback_id": "Hampir sempurna! Jangan lupa tambahkan partikel '는' setelah subjek.",
    "encourage": true
  }
  `;
  
  const result = await gemini.generate(prompt);
  return result;
}
```

#### 산출물
- [ ] ko-id 언어팩 (모든 UI 번역)
- [ ] 인도네시아 오류 패턴 30개
- [ ] 인니어 피드백 템플릿 50개
- [ ] 15개 레슨 × 3 stage × 인니어 설명

---

### ver0.5: Unity 메타버스 연동 (Week 9-12)

**목표**: Unity 3D 환경에서 AI 튜터와 실시간 상호작용

#### Unity 메타버스 씬
```
Scene 1: 카페 (Cafe)
├─ NPC: 바리스타 (AI 튜터)
├─ 상호작용: 주문하기 (Lesson 4 연동)
├─ 환경: 테이블, 의자, 메뉴판, 음악
└─ 기능: 음성 입력, 자막, 선택지

Scene 2: 공항 (Airport)
├─ NPC: 안내데스크 직원
├─ 상호작용: 체크인, 탑승구 찾기
├─ 환경: 출발 안내판, 수하물 카트
└─ 기능: 음성 입력 + 제스처

Scene 3: 편의점 (Convenience Store)
├─ NPC: 점원
├─ 상호작용: 쇼핑, 결제 (Lesson 3)
├─ 환경: 진열대, 계산대, 상품
└─ 기능: 3D 오브젝트 클릭 + 음성

Scene 4: 거리 (Street)
├─ NPC: 행인
├─ 상호작용: 길 찾기, 인사 (Lesson 1, 5)
├─ 환경: 건물, 신호등, 표지판
└─ 기능: 미니맵 + 네비게이션
```

#### Unity-API 통신
```csharp
// Unity C# - SessionManager.cs
public class SessionManager : MonoBehaviour
{
    private WebSocket ws;
    private string apiBaseUrl = "https://uconcreative.ddns.net/koto-api";
    
    // 1. 세션 시작
    public async Task<SessionData> StartLesson(string lessonId)
    {
        var request = UnityWebRequest.Post(
            $"{apiBaseUrl}/sessions",
            new { lesson_id = lessonId, user_id = "test_123", lang_pack = "ko-id" },
            "application/json"
        );
        
        await request.SendWebRequest();
        var session = JsonUtility.FromJson<SessionData>(request.downloadHandler.text);
        
        // WebSocket 연결
        await ConnectWebSocket(session.id);
        return session;
    }
    
    // 2. 음성 업로드
    public async Task<string> UploadAudio(AudioClip clip)
    {
        var audioBytes = WavUtility.FromAudioClip(clip);
        var form = new WWWForm();
        form.AddBinaryData("audio", audioBytes, "recording.wav", "audio/wav");
        
        var request = UnityWebRequest.Post($"{apiBaseUrl}/audio/upload", form);
        await request.SendWebRequest();
        
        var response = JsonUtility.FromJson<UploadResponse>(request.downloadHandler.text);
        return response.audio_id;
    }
    
    // 3. WebSocket 이벤트
    private async Task ConnectWebSocket(string sessionId)
    {
        ws = new WebSocket($"wss://uconcreative.ddns.net/koto/ws/session/{sessionId}");
        
        ws.OnMessage += (bytes) => {
            var msg = JsonUtility.FromJson<TutorMessage>(Encoding.UTF8.GetString(bytes));
            
            switch (msg.type)
            {
                case "evaluation_complete":
                    DisplayScore(msg.score);
                    DisplayFeedback(msg.feedback);
                    PlayTTS(msg.tts_url);
                    break;
                    
                case "next_activity":
                    LoadActivity(msg.activity);
                    break;
            }
        };
        
        await ws.Connect();
    }
    
    // 4. TTS 재생
    private IEnumerator PlayTTS(string url)
    {
        using var request = UnityWebRequestMultimedia.GetAudioClip(url, AudioType.MPEG);
        yield return request.SendWebRequest();
        
        var clip = DownloadHandlerAudioClip.GetContent(request);
        audioSource.PlayOneShot(clip);
        
        // NPC 립싱크
        npcAnimator.SetTrigger("Talk");
    }
}
```

#### Unity UI 시스템
```
HUD (항상 표시):
├─ 학습자 이름 / 레벨
├─ 현재 레슨 / Stage
├─ 점수 / 진도바
└─ 마이크 버튼 / 설정

대화 UI (NPC 상호작용):
├─ NPC 이름 / 역할
├─ 자막 (한국어 + 인니어 번역)
├─ 선택지 버튼 (3-4개)
└─ 음성 입력 파형

피드백 UI (평가 결과):
├─ 점수 애니메이션 (0 → 85)
├─ 별점 (★★★★☆)
├─ 오류 표시 (빨간색 밑줄)
├─ 교정 제안 (초록색)
└─ 다음 버튼 / 재시도
```

#### 산출물
- [ ] Unity 프로젝트 (2022.3 LTS)
- [ ] 4개 메타버스 씬 완성
- [ ] WebSocket 통신 완료
- [ ] 음성 입출력 동작
- [ ] UI/UX 완성
- [ ] WebGL 빌드 (브라우저 실행)

---

## 📅 전체 타임라인 (12주)

```
Week  Milestone   Tasks                              산출물
────────────────────────────────────────────────────────────────
1-2   ver0.1      AI Provider, DB, API 기본          Postman Collection
                  Gemini 평가, TTS 연동              API 문서
                  세션 관리, 성능 테스트             벤치마크 리포트

3-4   ver0.2      초급 5개 레슨 콘텐츠 제작          Lesson DB 데이터
                  기대 패턴 100개                    오류 패턴 50개
                  레슨별 테스트                      테스트 리포트

5-6   ver0.3      중급 5개 + 고급 5개 레슨           중고급 콘텐츠
                  난이도별 평가 규칙                 평가 기준 문서
                  레벨 테스트 시스템                 진도 로드맵

7-8   ver0.4      ko-id 언어팩 적용                  번역 파일
                  인니어 오류 패턴 30개              오류 DB
                  인니어 피드백 템플릿 50개          피드백 DB
                  15개 레슨 인니어 설명              콘텐츠 완성

9-12  ver0.5      Unity 4개 씬 제작                  Unity 프로젝트
                  WebSocket 통신                     통신 모듈
                  음성 입출력                        음성 모듈
                  UI/UX 완성                         최종 빌드
                  WebGL 배포                         배포 패키지
────────────────────────────────────────────────────────────────
```

---

## 🎯 Phase 1 완료 기준

### 기술 검증
- [ ] API p95 latency < 2초
- [ ] Gemini 평가 정확도 > 85%
- [ ] TTS 음질 만족도 > 4.0/5.0
- [ ] Session 무오류 100회 연속

### 콘텐츠 완성
- [ ] 초급 5종 (75 activities)
- [ ] 중급 5종 (150 activities)
- [ ] 고급 5종 (150 activities)
- [ ] 총 375 activities 완성

### 다국어 지원
- [ ] ko-en (영어 안내) 완성
- [ ] ko-id (인니어 안내) 완성
- [ ] 인니 학습자 오류 패턴 30개
- [ ] 인니어 피드백 100% 번역

### Unity 메타버스
- [ ] 4개 씬 완성 (카페, 공항, 편의점, 거리)
- [ ] NPC AI 튜터 동작
- [ ] 음성 입출력 완료
- [ ] WebGL 빌드 성공
- [ ] 1회 완전한 학습 루프 (시작 → 학습 → 평가 → 완료) 가능

---

## 📊 성공 지표 (KPI)

### 기술 지표
| 지표 | 목표 | 측정 방법 |
|------|------|-----------|
| API 응답 시간 (p95) | < 2초 | 모니터링 |
| AI 평가 정확도 | > 85% | 샘플 테스트 |
| TTS 음질 | > 4.0/5.0 | 청취 테스트 |
| WebSocket 안정성 | > 99% | 연결 유지율 |

### 학습 지표
| 지표 | 목표 | 측정 방법 |
|------|------|-----------|
| 레슨 완료율 | > 70% | DB 쿼리 |
| 평균 세션 시간 | 15-30분 | 로그 분석 |
| 학습자 만족도 | > 4.2/5.0 | 설문조사 |
| 재방문율 | > 50% | 세션 추적 |

---

## 🎨 비주얼 로드맵

```
Phase 1: AI 엔진 + 메타버스 기초
═══════════════════════════════════════════════════════════════

[ver0.1] ████████░░░░░░░░░░ (2주)
         AI 서버 연동 ✅
         │
         ├─ Gemini 평가
         ├─ Google TTS
         └─ 텍스트 학습 루프

[ver0.2] ░░░░░░░░████████░░ (2주)
         초급 5종 ✅
         │
         ├─ 인사하기
         ├─ 자기소개
         ├─ 쇼핑
         ├─ 식당
         └─ 교통

[ver0.3] ░░░░░░░░░░░░████████ (2주)
         중고급 10종 ✅
         │
         ├─ 중급 5종 (은행, 병원, 관공서...)
         └─ 고급 5종 (비즈니스, 뉴스, 학술...)

[ver0.4] ████████░░░░░░░░░░ (2주)
         인니어 적용 ✅
         │
         ├─ ko-id 언어팩
         ├─ 인니 오류 패턴
         └─ 피드백 번역

[ver0.5] ░░░░░░░░████████████ (4주)
         Unity 메타버스 ✅
         │
         ├─ 4개 씬 (카페, 공항, 편의점, 거리)
         ├─ NPC AI 튜터
         ├─ 음성 입출력
         └─ WebGL 배포

═══════════════════════════════════════════════════════════════
Phase 1 완료! ✨
→ Phase 2: 상용 서비스 준비 (v1.0)
```

---

**작성**: Antigravity AI  
**버전**: Phase 1 Roadmap v1.0  
**예상 기간**: 12주 (2026-01-16 ~ 2026-04-10)  
**다음 단계**: ver0.1 개발 착수
