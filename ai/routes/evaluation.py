from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import Dict, Any, Optional
from services.eval_service import EvaluationService
import time

router = APIRouter(prefix="/api/v1", tags=["evaluation"])

# Evaluation Service 초기화
eval_service = EvaluationService()

# Request/Response 모델
class EvaluationRequest(BaseModel):
    user_text: str
    expected_pattern: str
    context: Dict[str, Any] = {}
    use_rules: bool = True

class EvaluationResponse(BaseModel):
    score: int
    pass_fail: bool
    primary_error_type: str
    errors: list
    feedback: str
    corrected: Optional[str] = None
    source: str
    provider: str
    latency_ms: int

@router.post("/evaluate", response_model=EvaluationResponse)
async def evaluate_response(request: EvaluationRequest):
    """
    한국어 응답 평가
    
    - **user_text**: 사용자가 입력한 한국어 텍스트
    - **expected_pattern**: 기대하는 응답 패턴
    - **context**: 레슨/활동 컨텍스트
    - **use_rules**: 규칙 기반 평가 먼저 시도 여부
    """
    
    start_time = time.time()
    
    try:
        result = await eval_service.evaluate(
            user_text=request.user_text,
            expected_pattern=request.expected_pattern,
            context=request.context,
            use_rules=request.use_rules
        )
        
        latency_ms = int((time.time() - start_time) * 1000)
        
        return EvaluationResponse(
            **result,
            latency_ms=latency_ms
        )
        
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Evaluation failed: {str(e)}"
        )
