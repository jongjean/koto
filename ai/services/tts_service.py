import os
import time
import uuid
import json
from typing import Dict, Any, Optional

from providers.tts.google_tts import GoogleTTSProvider
# from minio import Minio # Optional if not installed

class TTSService:
    def __init__(self):
        # 환경 변수 로드
        self.mock_mode = os.getenv("TTS_MOCK_MODE", "false").lower() == "true"
        
        # Provider 초기화
        if self.mock_mode:
            print("⚠️ TTS Mock Mode Active")
            self.provider = None
        else:
            try:
                self.provider = GoogleTTSProvider()
            except Exception as e:
                print(f"⚠️ TTS Provider init failed, falling back to mock: {e}")
                self.mock_mode = True
                self.provider = None
                
        # MinIO 클라이언트 초기화 (선택적)
        self.use_minio = os.getenv("USE_MINIO", "true").lower() == "true"
        self.minio_client = None
        self.bucket_name = "koto-audio"

        if self.use_minio and not self.mock_mode:
            try:
                from minio import Minio
                self.minio_client = Minio(
                    f"{os.getenv('MINIO_ENDPOINT', 'localhost')}:{os.getenv('MINIO_PORT', '9000')}",
                    access_key=os.getenv('MINIO_ACCESS_KEY', 'koto_minio'),
                    secret_key=os.getenv('MINIO_SECRET_KEY', ''),
                    secure=os.getenv('MINIO_USE_SSL', 'false').lower() == 'true'
                )
                
                # 버킷 확인 및 생성
                if not self.minio_client.bucket_exists(self.bucket_name):
                    self.minio_client.make_bucket(self.bucket_name)
                    print(f"Created bucket: {self.bucket_name}")
            except Exception as e:
                print(f"⚠️ MinIO 연결 실패, Mock 모드로 전환: {e}")
                self.use_minio = False
        else:
            self.use_minio = False
        
        # 정책 설정 (AI_POLICY.md 기준)
        self.timeout = 2.0
        self.max_retries = 1
    
    async def synthesize(
        self,
        text: str,
        voice: str = "ko-KR-Standard-A", 
        language: str = "ko-KR",
        save_to_minio: bool = True
    ) -> Dict[str, Any]:
        """
        텍스트를 음성으로 변환하고 MinIO에 저장
        """
        
        start_time = time.time()
        
        if self.mock_mode:
            # Mock response
            audio_id = str(uuid.uuid4())
            filename = f"{audio_id}.mp3"
            
            # Use relative URL for proxy usage
            mock_url = f"/mock/audio/{filename}"
            
            # Ensure mock directory exists
            mock_dir = os.path.join(os.path.dirname(os.path.dirname(__file__)), 'mock_audio')
            os.makedirs(mock_dir, exist_ok=True)
            
            # Create dummy mp3
            with open(os.path.join(mock_dir, filename), 'wb') as f:
                 f.write(b'\xFF\xF3\x44\xC4' + b'\x00'*100) # Minimal dummy MP3 pattern

            return {
                "audio_id": audio_id,
                "audio_url": mock_url,
                "duration_ms": 1000,
                "provider": "mock_tts",
                "voice": "ko-KR-Mock",
                "language": language
            }
            
        try:
            # TTS 변환
            result = await self.provider.synthesize(
                text=text,
                voice=voice,
                language=language
            )
            
            audio_content = result["audio_content"]
            
            # MinIO 저장
            if save_to_minio and self.minio_client:
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
                    "duration_ms": result.get("duration_ms", 0),
                    "provider": result.get("provider", "unknown"),
                    "voice": voice,
                    "language": language,
                    "latency_ms": latency_ms
                }
            else:
                # 바이너리 반환 (base64 인코딩 필요할 수 있음)
                import base64
                audio_base64 = base64.b64encode(audio_content).decode('utf-8')
                
                latency_ms = int((time.time() - start_time) * 1000)
                
                return {
                    "audio_id": str(uuid.uuid4()),
                    "audio_content": audio_base64, # base64 string
                    "duration_ms": result.get("duration_ms", 0),
                    "provider": result.get("provider", "unknown"),
                    "voice": voice,
                    "language": language,
                    "latency_ms": latency_ms
                }
                
        except Exception as e:
            print(f"TTS Synthesis Error: {e}")
            raise e
