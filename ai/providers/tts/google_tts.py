import os
import io
from typing import Dict, Any
from google.cloud import texttospeech
from ..base import TTSProvider

class GoogleTTSProvider(TTSProvider):
    """
    Google Cloud Text-to-Speech Provider
    """
    
    def __init__(self, config: Dict[str, Any] = None):
        super().__init__(config)
        
        # Google Cloud 인증 처리
        # 1. 서비스 계정 파일 확인
        creds_path = os.getenv("GOOGLE_APPLICATION_CREDENTIALS")
        
        if creds_path and os.path.exists(creds_path):
            self.client = texttospeech.TextToSpeechClient()
        else:
            # 2. 파일 없으면 API Key 사용 (GEMINI_API_KEY 공유)
            print("Warning: GOOGLE_APPLICATION_CREDENTIALS not found. Trying API Key fallback.")
            from google.api_core.client_options import ClientOptions
            
            api_key = os.getenv("GEMINI_API_KEY")
            if not api_key:
                raise ValueError("No Google Cloud Credentials provided (File or API Key)")
                
            client_options = ClientOptions(api_key=api_key)
            self.client = texttospeech.TextToSpeechClient(client_options=client_options)
        
        # 기본 설정 (Standard-C 남성)
        self.default_voice = self.config.get("default_voice", "ko-KR-Standard-C")
        self.default_language = self.config.get("default_language", "ko-KR")
        self.timeout = self.config.get("timeout", 2.0)
    
    async def health_check(self) -> bool:
        """
        Google TTS API 연결 테스트
        """
        try:
            # 간단한 TTS 요청으로 테스트
            synthesis_input = texttospeech.SynthesisInput(text="테스트")
            voice = texttospeech.VoiceSelectionParams(
                language_code=self.default_language,
                name=self.default_voice
            )
            audio_config = texttospeech.AudioConfig(
                audio_encoding=texttospeech.AudioEncoding.MP3
            )
            
            response = self.client.synthesize_speech(
                input=synthesis_input,
                voice=voice,
                audio_config=audio_config,
                timeout=self.timeout
            )
            
            return len(response.audio_content) > 0
            
        except Exception as e:
            print(f"Google TTS health check failed: {e}")
            return False
    
    async def synthesize(
        self,
        text: str,
        voice: str = None,
        language: str = None
    ) -> Dict[str, Any]:
        """
        텍스트를 음성으로 변환
        
        Args:
            text: 변환할 텍스트
            voice: 음성 ID (예: ko-KR-Wavenet-A)
            language: 언어 코드 (예: ko-KR)
        
        Returns:
            {
                "audio_content": bytes,
                "duration_ms": int,
                "provider": "google_tts",
                "voice": str,
                "language": str
            }
        """
        
        voice = voice or self.default_voice
        language = language or self.default_language
        
        if not voice or (language not in voice): # 언어가 바뀌었는데 보이스가 안 바뀐 경우
            if language == "en-US":
                voice = "en-US-Standard-D" # Neural2 대신 Standard (남성)
            elif language == "id-ID":
                voice = "id-ID-Standard-A"  # 여성 (Standard A)
            elif language == "ko-KR":
                voice = "ko-KR-Standard-C" # Neural2 대신 Standard (남성)
        
        try:
            # TTS 요청 설정
            synthesis_input = texttospeech.SynthesisInput(text=text)
            
            voice_params = texttospeech.VoiceSelectionParams(
                language_code=language,
                name=voice
            )
            
            audio_config = texttospeech.AudioConfig(
                audio_encoding=texttospeech.AudioEncoding.MP3,
                speaking_rate=0.9, # 학습용이라 조금 천천히 또박또박
                pitch=0.0
            )
            
            # TTS 생성
            response = self.client.synthesize_speech(
                input=synthesis_input,
                voice=voice_params,
                audio_config=audio_config,
                timeout=self.timeout
            )
            
            # 음성 데이터
            audio_content = response.audio_content
            
            # 대략적인 duration 계산 (실제로는 audio analysis 필요)
            # 한국어 평균: ~150 characters/minute
            estimated_duration_ms = int((len(text) / 150) * 60 * 1000)
            
            return {
                "audio_content": audio_content,
                "duration_ms": estimated_duration_ms,
                "provider": "google_tts",
                "voice": voice,
                "language": language,
                "text_length": len(text)
            }
            
        except Exception as e:
            print(f"Google TTS synthesis failed: {e}")
            raise Exception(f"TTS synthesis failed: {str(e)}")
