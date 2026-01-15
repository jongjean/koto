# Korean Together - 언어팩 구조

## 📁 언어팩 파일

### ko-en.json (한국어-영어)
- 영어권 학습자를 위한 언어팩
- 기본 UI 문자열
- 피드백 템플릿
- 문법 설명 (영어)

### ko-id.json (한국어-인도네시아어) ✅
- 인도네시아어권 학습자를 위한 언어팩
- 모든 UI 인도네시아어 번역
- 인도네시아 학습자 특화 오류 패턴
- 문법 설명 (인도네시아어)

---

## 🎯 인도네시아 학습자 특화 기능

### 1. 일반적인 오류 패턴
1. **Particle Omission** (파티클 누락)
   - 이유: 인도네시아어에는 은/는/이/가 같은 파티클이 없음
   - 예: "나 학교 가요" → "나는 학교에 가요"

2. **Honorific Confusion** (높임말 혼동)
   - 이유: 한국어 높임 시스템이 더 복잡
   - 예: "선생님이 왔어" → "선생님이 오셨어요"

3. **Tense Conjugation** (시제 활용)
   - 이유: 인도네시아어는 동사 활용이 단순
   - 예: "어제 먹어요" → "어제 먹었어요"

4. **Topic vs Subject** (주제 vs 주어)
   - 이유: 은/는 vs 이/가 개념이 어려움
   - 예: "저가 학생" → "저는 학생입니다"

5. **Location Particles** (장소 파티클)
   - 이유: 에/에서/로 구분이 없음
   - 예: "학교 가요" → "학교에 가요"

---

## 🌐 사용 방법

### Backend (Python)
```python
import json

# 언어팩 로드
with open('shared/lang_packs/ko-id.json') as f:
    lang_pack = json.load(f)

# UI 문자열 사용
welcome_msg = lang_pack['ui_strings']['welcome']
# "Selamat datang di Korean Together!"

# 피드백 생성
feedback = lang_pack['feedback_templates']['good'].format(
    detail="Tambahkan partikel '를' setelah objek"
)
# "Bagus! Tambahkan partikel '를' setelah objek"

# 오류 패턴 확인
particle_errors = [p for p in lang_pack['indonesian_error_patterns'] 
                   if p['pattern_id'] == 'particle_omission'][0]
```

### Frontend (Unity C#)
```csharp
// 언어팩 로드
string langPackJson = File.ReadAllText("lang_packs/ko-id.json");
var langPack = JsonUtility.FromJson<LangPack>(langPackJson);

// UI 업데이트
startButton.text = langPack.ui_strings.start_lesson;
// "Mulai Pelajaran"

// 피드백 표시
string feedback = langPack.feedback_templates.excellent
    .Replace("{detail}", evaluationDetail);
```

---

## 📊 언어팩 통계

### ko-id.json
- UI 문자열: 15개
- 피드백 템플릿: 8개
- 오류 유형: 6개
- 인도네시아 특화 오류 패턴: 5개 (10개 예시)
- 레슨 설명: 15개
- 격려 메시지: 10개
- 일반 단어: 15개
- 문법 설명: 4개

---

## 🎓 추가 언어팩 확장

### 향후 지원 예정
- ko-zh (중국어)
- ko-ja (일본어)
- ko-vi (베트남어)
- ko-th (태국어)

각 언어별로:
1. 해당 언어권 학습자의 일반적인 오류 패턴 분석
2. 모국어 간섭 (Language Transfer) 고려
3. 문화적 맥락 반영

---

**작성**: Antigravity AI  
**버전**: ver0.4  
**언어팩**: ko-id (인도네시아어) ✅
