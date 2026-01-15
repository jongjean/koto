from abc import ABC, abstractmethod
from typing import Dict, Any, Optional

class BaseProvider(ABC):
    """
    모든 AI Provider의 기본 추상 클래스
    """
    
    def __init__(self, config: Optional[Dict[str, Any]] = None):
        self.config = config or {}
        self.provider_name = self.__class__.__name__
    
    @abstractmethod
    async def health_check(self) -> bool:
        """
        Provider가 정상 동작하는지 확인
        """
        pass


class EvaluationProvider(BaseProvider):
    """
    평가 Provider 기본 클래스
    """
    
    @abstractmethod
    async def evaluate(
        self,
        user_text: str,
        expected_pattern: str,
        context: Dict[str, Any]
    ) -> Dict[str, Any]:
        """
        사용자 응답을 평가
        
        Args:
            user_text: 사용자가 입력한 텍스트
            expected_pattern: 기대하는 패턴
            context: 레슨/활동 컨텍스트
            
        Returns:
            {
                "score": int (0-100),
                "pass_fail": bool,
                "primary_error_type": str,
                "errors": list,
                "feedback": str,
                "corrected": str (optional)
            }
        """
        pass


class TTSProvider(BaseProvider):
    """
    Text-to-Speech Provider 기본 클래스
    """
    
    @abstractmethod
    async def synthesize(
        self,
        text: str,
        voice: str,
        language: str = "ko-KR"
    ) -> Dict[str, Any]:
        """
        텍스트를 음성으로 변환
        
        Args:
            text: 변환할 텍스트
            voice: 음성 ID (예: ko-KR-Wavenet-A)
            language: 언어 코드
            
        Returns:
            {
                "audio_url": str,
                "duration_ms": int,
                "provider": str
            }
        """
        pass


class STTProvider(BaseProvider):
    """
    Speech-to-Text Provider 기본 클래스
    """
    
    @abstractmethod
    async def transcribe(
        self,
        audio_bytes: bytes,
        language: str = "ko-KR"
    ) -> Dict[str, Any]:
        """
        음성을 텍스트로 변환
        
        Args:
            audio_bytes: 음성 데이터 (바이트)
            language: 언어 코드
            
        Returns:
            {
                "text": str,
                "confidence": float,
                "provider": str
            }
        """
        pass
