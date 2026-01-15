from typing import Dict, Any, List
import json
import os
import requests
from ..base import EvaluationProvider

class GeminiEvaluator(EvaluationProvider):
    """
    Google Gemini 기반 평가 Provider (Requests 동기 호출 - 안전 모드)
    """
    
    def __init__(self, config: Dict[str, Any] = None):
        super().__init__(config)
        self.model_id = self.config.get("model_id", "gemini-1.5-flash")
        self.api_key = os.getenv("GEMINI_API_KEY")
        
        if not self.api_key:
            print("Warning: GEMINI_API_KEY not found")

    async def health_check(self) -> bool:
        return True

    async def evaluate(
        self, 
        user_text: str, 
        expected_pattern: str, 
        context: Dict[str, Any] = None
    ) -> Dict[str, Any]:
        """
        Gemini API 호출 (Requests 사용)
        """
        if not context:
            context = {}

        # Context에 expected_pattern 추가 (Fallback에서 사용)
        context['expected_pattern'] = expected_pattern
        
        prompt = self._create_prompt(user_text, expected_pattern, context)
        
        url = f"https://generativelanguage.googleapis.com/v1beta/models/{self.model_id}:generateContent?key={self.api_key}"
        headers = {'Content-Type': 'application/json'}
        payload = {
            "contents": [{
                "parts": [{"text": prompt}]
            }],
            "generationConfig": {
                "temperature": 0.2,
                "responseMimeType": "application/json"
            }
        }
        
        try:
            # 동기 호출, 타임아웃 넉넉하게
            response = requests.post(url, headers=headers, json=payload, timeout=30)
            
            if response.status_code != 200:
                print(f"Gemini API Error {response.status_code}: {response.text}")
                return self._fallback_response(user_text, context)
            
            data = response.json()
            
            # 응답 파싱
            try:
                candidate = data["candidates"][0]["content"]["parts"][0]["text"]
                
                # 마크다운 코드블록 제거 (더 확실하게)
                json_str = candidate.strip()
                if "```json" in candidate:
                    parts = candidate.split("```json")
                    if len(parts) > 1:
                        json_str = parts[1].split("```")[0].strip()
                elif "```" in candidate:
                    parts = candidate.split("```")
                    if len(parts) > 1:
                        json_str = parts[1].strip()
                
                # 빈 값 체크
                if not json_str:
                    print("Empty JSON string from AI")
                    return self._fallback_response(user_text, context)

                # JSON 로드 시도
                try:
                    eval_result = json.loads(json_str)
                except json.JSONDecodeError:
                    # JSON이 망가져서 왔을 경우, 텍스트 전체를 피드백으로 사용
                    print(f"JSON Decode Error. Raw: {json_str}")
                    # 점점점(...) 방지: 내용이 없으면 기본 메시지
                    fallback_text = json_str.strip()
                    if not fallback_text or fallback_text == "...":
                        fallback_text = "AI가 유효한 답변을 생성하지 못했습니다. (Parsing Error)"
                        
                    return {
                        "score": 0,
                        "feedback": fallback_text, 
                        "corrected": expected_pattern,
                        "provider": "gemini_parsing_error"
                    }
                
                # 필수 필드 방어 코드
                if "score" not in eval_result or eval_result["score"] is None:
                    eval_result["score"] = 0
                
                # 피드백이 비어있거나 ... 인 경우 방어
                if "feedback" not in eval_result or not eval_result["feedback"] or eval_result["feedback"].strip() == "...":
                    lang = context.get('native_lang', 'en')
                    if lang == 'ko':
                        eval_result["feedback"] = "AI가 구체적인 피드백을 주지 않았습니다. 다시 시도해보세요."
                    elif lang == 'id':
                        eval_result["feedback"] = "AI tidak memberikan umpan balik spesifik."
                    else:
                        eval_result["feedback"] = "AI did not provide specific feedback."
                    
                # 숫자형 변환 확인
                try:
                    eval_result["score"] = int(eval_result["score"])
                except:
                    eval_result["score"] = 0

                eval_result["provider"] = "gemini_requests"
                eval_result["model_id"] = self.model_id
                
                return eval_result
                
            except (KeyError, IndexError) as e:
                print(f"Structure Error: {data}")
                return self._fallback_response(user_text, context)
                
        except Exception as e:
            print(f"Gemini evaluation error: {e}")
            return self._fallback_response(user_text, context)
    
    def _create_prompt(
        self,
        user_text: str,
        expected_pattern: str,
        context: Dict[str, Any]
    ) -> str:
        """
        다국어 학습을 지원하는 범용 프롬프트 생성
        """
        target_lang = context.get('target_lang', 'ko') 
        native_lang = context.get('native_lang', 'en')
        
        # 언어 코드 -> 이름
        lang_names = {'ko': 'Korean', 'en': 'English', 'id': 'Indonesian'}
        t_name = lang_names.get(target_lang, 'Korean')
        n_name = lang_names.get(native_lang, 'English')
        
        # 지시어 생성 (Instruction for Language) & Template Injection
        lang_instruction = f"translate all feedback/explanations into **{n_name}**."
        feedback_example = f"Detailed explanation in {n_name} (Must not be empty)"
        
        if native_lang == 'ko':
             lang_instruction = "CRITICAL: Write feedback in **Korean (한국어)**."
             feedback_example = "발음과 문법에 대한 구체적인 피드백 (한국어로 작성)"
        elif native_lang == 'id':
             lang_instruction = "CRITICAL: Write feedback ONLY in **Bahasa Indonesia**."
             feedback_example = "Penjelasan rinci tentang kesalahan dalam Bahasa Indonesia"

        prompt = f"""Role: Professional Language Tutor ({t_name})
Student Base Language: {n_name}
Target: "{expected_pattern}"
Input: "{user_text}"

Task: Evaluate user's input.
1. Score 0-100.
2. {lang_instruction} Explain WHY the user is wrong.

JSON Output Only:
{{
  "score": (int),
  "feedback": "{feedback_example}",
  "corrected": "Correct {t_name} sentence"
}}
"""
        return prompt
    
    def _fallback_response(self, user_text: str, context: Dict[str, Any] = None) -> Dict[str, Any]:
        """Failover"""
        lang = context.get('native_lang', 'en') if context else 'en'
        expected = context.get('expected_pattern', user_text) if context else user_text
        
        msg = "AI is slow to respond. Please try again."
        if lang == 'ko': msg = "AI 응답 지연. 잠시 후 다시 시도해주세요."
        elif lang == 'id': msg = "Respons AI lambat. Silakan coba lagi."
            
        return {
            "score": 0,
            "feedback": msg,
            "corrected": expected,
            "provider": "fallback"
        }
