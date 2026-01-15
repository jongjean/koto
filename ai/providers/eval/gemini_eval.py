import os
import json
from typing import Dict, Any
import google.generativeai as genai
from ..base import EvaluationProvider

class GeminiEvaluator(EvaluationProvider):
    """
    Gemini API를 사용한 한국어 평가 Provider
    """
    
    def __init__(self, config: Dict[str, Any] = None):
        super().__init__(config)
        
        # Gemini API 설정
        api_key = os.getenv("GEMINI_API_KEY")
        if not api_key:
            raise ValueError("GEMINI_API_KEY not found in environment")
        
        genai.configure(api_key=api_key)
        
        # 모델 설정
        self.model_id = self.config.get("model_id", "gemini-pro-latest")
        self.model = genai.GenerativeModel(self.model_id)
        
        # 타임아웃 설정 (AI_POLICY.md 기준)
        self.timeout = self.config.get("timeout", 2.0)
    
    async def health_check(self) -> bool:
        """
        Gemini API 연결 테스트
        """
        try:
            response = self.model.generate_content("Hello")
            return bool(response.text)
        except Exception as e:
            print(f"Gemini health check failed: {e}")
            return False
    
    async def evaluate(
        self,
        user_text: str,
        expected_pattern: str,
        context: Dict[str, Any]
    ) -> Dict[str, Any]:
        """
        Gemini를 사용하여 한국어 응답 평가
        
        Args:
            user_text: 사용자 응답
            expected_pattern: 기대 패턴
            context: {
                "lesson_id": str,
                "activity_id": str,
                "difficulty": int,
                "lang_pack": str (예: "ko-en")
            }
        """
        
        # 언어팩에 따라 피드백 언어 결정
        lang_pack = context.get("lang_pack", "ko-en")
        feedback_lang = "English" if lang_pack == "ko-en" else "Bahasa Indonesia"
        
        # 프롬프트 생성
        prompt = self._create_prompt(
            user_text=user_text,
            expected_pattern=expected_pattern,
            context=context,
            feedback_lang=feedback_lang
        )
        
        try:
            # Gemini API 호출
            response = self.model.generate_content(prompt)
            result_text = response.text
            
            # JSON 파싱
            # Gemini가 ```json ... ``` 형식으로 반환할 수 있으므로 정리
            if "```json" in result_text:
                result_text = result_text.split("```json")[1].split("```")[0]
            elif "```" in result_text:
                result_text = result_text.split("```")[1].split("```")[0]
            
            result = json.loads(result_text.strip())
            
            # 결과 검증 및 기본값 설정
            return {
                "score": int(result.get("score", 50)),
                "pass_fail": result.get("score", 50) >= 70,
                "primary_error_type": result.get("primary_error_type", "unknown"),
                "errors": result.get("errors", []),
                "feedback": result.get("feedback", "Good effort!"),
                "corrected": result.get("corrected", user_text),
                "provider": "gemini",
                "model_id": self.model_id
            }
            
        except json.JSONDecodeError as e:
            # JSON 파싱 실패 시 fallback
            print(f"JSON parse error: {e}, raw response: {result_text}")
            return self._fallback_response(user_text)
        
        except Exception as e:
            print(f"Gemini evaluation error: {e}")
            return self._fallback_response(user_text)
    
    def _create_prompt(
        self,
        user_text: str,
        expected_pattern: str,
        context: Dict[str, Any],
        feedback_lang: str
    ) -> str:
        """
        Gemini용 평가 프롬프트 생성
        """
        
        prompt = f"""You are a Korean language tutor evaluating a learner's response.

**Context:**
- Expected Pattern: {expected_pattern}
- Difficulty Level: {context.get('difficulty', 1)}/5
- Feedback Language: {feedback_lang}

**User Response:** 
{user_text}

**Your Task:**
Evaluate the Korean response and provide detailed feedback.

**Evaluation Criteria:**
1. **Grammar** (문법): Correct use of particles (은/는/이/가/을/를), verb conjugation, sentence structure
2. **Vocabulary** (어휘): Appropriate word choice for the context
3. **Formality** (격식): Appropriate level of politeness (반말/존댓말)
4. **Naturalness** (자연스러움): How natural it sounds to a native speaker

**Output Format (JSON):**
```json
{{
  "score": 85,
  "primary_error_type": "grammar|vocabulary|formality|pronunciation|none",
  "errors": [
    {{
      "type": "grammar",
      "original": "나 학교 가요",
      "correct": "나는 학교에 가요",
      "reason": "Missing particle '는' after subject, missing '에' after location"
    }}
  ],
  "feedback": "Almost perfect! Just add the particle '는' after the subject.",
  "corrected": "저는 학교에 갑니다"
}}
```

**Scoring Guide:**
- 90-100: Perfect or near-perfect
- 80-89: Good with minor errors
- 70-79: Acceptable with some errors
- 60-69: Needs improvement
- Below 60: Major errors

Provide feedback in {feedback_lang}. Be encouraging and specific.
"""
        
        return prompt
    
    def _fallback_response(self, user_text: str) -> Dict[str, Any]:
        """
        Gemini 실패 시 기본 응답
        """
        return {
            "score": 50,
            "pass_fail": False,
            "primary_error_type": "system_error",
            "errors": [],
            "feedback": "Unable to evaluate at this moment. Please try again.",
            "corrected": user_text,
            "provider": "gemini_fallback",
            "model_id": self.model_id
        }
