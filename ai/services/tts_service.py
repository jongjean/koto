from typing import Dict, Any
import os
import uuid
import time
from minio import Minio
from providers.tts.google_tts import GoogleTTSProvider

class TTSService:
    """
    TTS 서비스 - Provider를 관리하고 MinIO에 저장
    """
    
    def __init__(self):
        # Provider 초기화
        provider_name = os.getenv("TTS_PROVIDER", "google")
        
        if provider_name == "google":
            self.provider = GoogleTTSProvider()
        else:
            raise ValueError(f"Unknown TTS provider: {provider_name}")
        
        # MinIO 클라이언트 초기화
        self.minio_client = Minio(
            f"{os.getenv('MINIO_ENDPOINT', 'localhost')}:{os.getenv('MINIO_PORT', '9000')}",
            access_key=os.getenv('MINIO_ACCESS_KEY', 'koto_minio'),
            secret_key=os.getenv('MINIO_SECRET_KEY', ''),
            secure=os.getenv('MINIO_USE_SSL', 'false').lower() == 'true'
        )
        
        # 버킷 확인 및 생성
        self.bucket_name = "koto-audio"
        if not self.minio_client.bucket_exists(self.bucket_name):
            self.minio_client.make_bucket(self.bucket_name)
            print(f"Created bucket: {self.bucket_name}")
        
        # 정책 설정 (AI_POLICY.md 기준)
        self.timeout = 2.0
        self.max_retries = 1
    
    async def synthesize(
        self,
        text: str,
        voice: str = None,
        language: str = "ko-KR",
        save_to_minio: bool = True
    ) -> Dict[str, Any]:
        """
        텍스트를 음성으로 변환하고 MinIO에 저장
        
        Args:
            text: 변환할 텍스트
            voice: 음성 ID
            language: 언어 코드
            save_to_minio: MinIO 저장 여부
        
        Returns:
            {
                "audio_id": str,
                "audio_url": str (if save_to_minio),
                "audio_content": bytes (if not save_to_minio),
                "duration_ms": int,
                "provider": str,
                "latency_ms": int
            }
        """
        
        start_time = time.time()
        
        try:
            # TTS 생성
            result = await self.provider.synthesize(
                text=text,
                voice=voice,
                language=language
            )
            
            audio_content = result["audio_content"]
            
            # MinIO 저장
            if save_to_minio:
                audio_id = str(uuid.uuid4())
                object_name = f"tts/{audio_id}.mp3"
                
                from io import BytesIO
                
                self.minio_client.put_object(
                    bucket_name=self.bucket_name,
                    object_name=object_name,
                    data=BytesIO(audio_content),
                    length=len(audio_content),
                    content_type="audio/mpeg"
                )
                
                # Presigned URL 생성 (1시간 유효)
                audio_url = self.minio_client.presigned_get_object(
                    bucket_name=self.bucket_name,
                    object_name=object_name,
                    expires=3600  # 1 hour
                )
                
                latency_ms = int((time.time() - start_time) * 1000)
                
                return {
                    "audio_id": audio_id,
                    "audio_url": audio_url,
                    "duration_ms": result["duration_ms"],
                    "provider": result["provider"],
                    "voice": result["voice"],
                    "language": result["language"],
                    "latency_ms": latency_ms,
                    "text_length": result["text_length"]
                }
            else:
                latency_ms = int((time.time() - start_time) * 1000)
                
                return {
                    "audio_content": audio_content,
                    "duration_ms": result["duration_ms"],
                    "provider": result["provider"],
                    "latency_ms": latency_ms
                }
                
        except Exception as e:
            print(f"TTS service error: {e}")
            raise Exception(f"TTS synthesis failed: {str(e)}")
