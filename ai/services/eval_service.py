from typing import Dict, Any, Optional
import os
from providers.eval.gemini_eval import GeminiEvaluator

class EvaluationService:
    """
    평가 서비스 - Provider를 관리하고 정책을 적용
    """
    
    def __init__(self):
        # 환경변수에서 Provider 선택
        provider_name = os.getenv("EVAL_PROVIDER", "gemini")
        
        # Provider 초기화
        if provider_name == "gemini":
            self.provider = GeminiEvaluator()
        else:
            raise ValueError(f"Unknown evaluation provider: {provider_name}")
        
        # 정책 설정 (AI_POLICY.md 기준)
        self.confidence_threshold = 0.9
        self.timeout = 2.0
        self.max_retries = 1
    
    async def evaluate(
        self,
        user_text: str,
        expected_pattern: str,
        context: Dict[str, Any],
        use_rules: bool = True
    ) -> Dict[str, Any]:
        """
        사용자 응답 평가 (정책 적용)
        
        Args:
            user_text: 사용자 입력
            expected_pattern: 기대 패턴
            context: 컨텍스트
            use_rules: 규칙 기반 평가 먼저 시도
        
        Returns:
            평가 결과
        """
        
        # Step 1: 규칙 기반 평가 (빠른 판정)
        if use_rules:
            rule_result = self._evaluate_by_rules(user_text, expected_pattern)
            
            # confidence >= 0.9면 LLM 호출 생략
            if rule_result["confidence"] >= self.confidence_threshold:
                return {
                    **rule_result,
                    "source": "rule",
                    "llm_skipped": True
                }
        
        # Step 2: LLM 평가 (정교한 분석)
        try:
            llm_result = await self.provider.evaluate(
                user_text=user_text,
                expected_pattern=expected_pattern,
                context=context
            )
            
            return {
                **llm_result,
                "source": "llm"
            }
            
        except Exception as e:
            print(f"LLM evaluation failed: {e}")
            
            # Fallback: 기본 피드백
            return self._fallback_evaluation(user_text)
    
    def _evaluate_by_rules(
        self,
        user_text: str,
        expected_pattern: str
    ) -> Dict[str, Any]:
        """
        규칙 기반 평가 (ver0.1 간단 버전)
        
        TODO: 정교한 규칙 추가
        """
        
        # 간단한 매칭
        normalized_user = user_text.strip().lower()
        normalized_expected = expected_pattern.strip().lower()
        
        # 정확히 일치
        if normalized_user == normalized_expected:
            return {
                "score": 100,
                "pass_fail": True,
                "primary_error_type": "none",
                "errors": [],
                "feedback": "Perfect!",
                "corrected": expected_pattern,
                "confidence": 1.0,
                "provider": "rule"
            }
        
        # 부분 일치 (간단 버전)
        if normalized_expected in normalized_user or normalized_user in normalized_expected:
            return {
                "score": 85,
                "pass_fail": True,
                "primary_error_type": "minor",
                "errors": [],
                "feedback": "Good! Very close to the expected answer.",
                "corrected": expected_pattern,
                "confidence": 0.8,
                "provider": "rule"
            }
        
        # 불확실 (LLM 필요)
        return {
            "score": 50,
            "confidence": 0.5,
            "provider": "rule_uncertain"
        }
    
    def _fallback_evaluation(self, user_text: str) -> Dict[str, Any]:
        """
        모든 평가 실패 시 기본 응답
        """
        return {
            "score": 50,
            "pass_fail": False,
            "primary_error_type": "system_error",
            "errors": [],
            "feedback": "Thank you for your answer. Let's try the next one.",
            "corrected": user_text,
            "source": "fallback",
            "suggest_retry": True
        }
