from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from datetime import datetime
import json
import os
import asyncio

router = APIRouter(prefix="/api/v1", tags=["feedback"])

class FeedbackRequest(BaseModel):
    message: str
    contact: str = ""

@router.post("/feedback")
async def submit_feedback(req: FeedbackRequest):
    """
    사용자 피드백 저장 (날짜별 파일)
    """
    # 날짜별로 파일 분리
    today = datetime.now().strftime("%Y-%m-%d")
    feedback_dir = "/home/ucon/koto/feedbacks"
    os.makedirs(feedback_dir, exist_ok=True)
    
    feedback_file = os.path.join(feedback_dir, f"feedback_{today}.json")
    
    feedback_entry = {
        "timestamp": datetime.now().isoformat(),
        "message": req.message[:500],  # 최대 500자 제한
        "contact": req.contact[:100] if req.contact else ""
    }
    
    # 비동기 파일 쓰기
    try:
        # 기존 피드백 읽기
        feedbacks = []
        if os.path.exists(feedback_file):
            with open(feedback_file, 'r', encoding='utf-8') as f:
                try:
                    feedbacks = json.load(f)
                except json.JSONDecodeError:
                    feedbacks = []
        
        # 하루 최대 1000개 제한 (DoS 방지)
        if len(feedbacks) >= 1000:
            raise HTTPException(status_code=429, detail="Daily limit reached")
        
        # 새 피드백 추가
        feedbacks.append(feedback_entry)
        
        # 저장
        with open(feedback_file, 'w', encoding='utf-8') as f:
            json.dump(feedbacks, f, ensure_ascii=False, indent=2)
        
        return {
            "status": "success",
            "message": "Feedback received",
            "count": len(feedbacks)
        }
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to save feedback: {str(e)}")

@router.get("/feedbacks")
async def get_feedbacks(date: str = None):
    """
    피드백 조회 (관리자용)
    date 파라미터: YYYY-MM-DD 형식 (없으면 오늘)
    """
    feedback_dir = "/home/ucon/koto/feedbacks"
    
    if not date:
        date = datetime.now().strftime("%Y-%m-%d")
    
    feedback_file = os.path.join(feedback_dir, f"feedback_{date}.json")
    
    if not os.path.exists(feedback_file):
        return {
            "date": date,
            "feedbacks": [],
            "count": 0
        }
    
    try:
        with open(feedback_file, 'r', encoding='utf-8') as f:
            feedbacks = json.load(f)
        
        return {
            "date": date,
            "feedbacks": feedbacks,
            "count": len(feedbacks)
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to read feedbacks: {str(e)}")

@router.get("/feedbacks/dates")
async def get_feedback_dates():
    """
    피드백이 있는 날짜 목록 조회
    """
    feedback_dir = "/home/ucon/koto/feedbacks"
    
    if not os.path.exists(feedback_dir):
        return {"dates": []}
    
    try:
        files = os.listdir(feedback_dir)
        dates = []
        for f in files:
            if f.startswith("feedback_") and f.endswith(".json"):
                date = f.replace("feedback_", "").replace(".json", "")
                dates.append(date)
        
        dates.sort(reverse=True)  # 최신순
        return {"dates": dates}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to list dates: {str(e)}")

class DeleteRequest(BaseModel):
    date: str
    indices: list[int]

@router.delete("/feedbacks")
async def delete_feedbacks(req: DeleteRequest):
    """
    피드백 삭제 (관리자용)
    선택한 인덱스의 피드백을 삭제하고 저장
    """
    feedback_dir = "/home/ucon/koto/feedbacks"
    feedback_file = os.path.join(feedback_dir, f"feedback_{req.date}.json")
    
    if not os.path.exists(feedback_file):
        raise HTTPException(status_code=404, detail="Feedback file not found")
    
    try:
        with open(feedback_file, 'r', encoding='utf-8') as f:
            feedbacks = json.load(f)
        
        # 인덱스를 역순으로 정렬하여 뒤에서부터 삭제 (앞의 인덱스 변화 방지)
        indices = sorted(req.indices, reverse=True)
        deleted_count = 0
        
        for idx in indices:
            if 0 <= idx < len(feedbacks):
                del feedbacks[idx]
                deleted_count += 1
        
        # 변경사항 저장
        with open(feedback_file, 'w', encoding='utf-8') as f:
            json.dump(feedbacks, f, ensure_ascii=False, indent=2)
            
        return {
            "status": "success",
            "message": f"{deleted_count} feedbacks deleted",
            "remaining": len(feedbacks)
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to delete feedbacks: {str(e)}")
