from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import Optional
from services.tts_service import TTSService

router = APIRouter(prefix="/api/v1", tags=["tts"])

# TTS Service 초기화
tts_service = TTSService()

# Request/Response 모델
class TTSRequest(BaseModel):
    text: str
    voice: Optional[str] = None
    language: str = "ko-KR"
    save_to_minio: bool = True

class TTSResponse(BaseModel):
    audio_id: Optional[str] = None
    audio_url: Optional[str] = None
    duration_ms: int
    provider: str
    voice: str
    language: str
    latency_ms: int

@router.post("/tts", response_model=TTSResponse)
async def text_to_speech(request: TTSRequest):
    """
    텍스트를 음성으로 변환
    
    - **text**: 변환할 한국어 텍스트
    - **voice**: 음성 ID (기본: ko-KR-Wavenet-A)
    - **language**: 언어 코드 (기본: ko-KR)
    - **save_to_minio**: MinIO 저장 여부 (기본: true)
    
    Returns presigned URL for audio file (1 hour expiry)
    """
    
    if not request.text or len(request.text.strip()) == 0:
        raise HTTPException(status_code=400, detail="Text cannot be empty")
    
    if len(request.text) > 5000:
        raise HTTPException(status_code=400, detail="Text too long (max 5000 characters)")
    
    try:
        result = await tts_service.synthesize(
            text=request.text,
            voice=request.voice,
            language=request.language,
            save_to_minio=request.save_to_minio
        )
        
        return TTSResponse(**result)
        
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"TTS synthesis failed: {str(e)}"
        )
