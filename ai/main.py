from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import os
from dotenv import load_dotenv

load_dotenv()

app = FastAPI(
    title="KOTO AI Service",
    description="Korean Together AI Service - STT/TTS/Evaluation",
    version="0.1.0"
)

# CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # TODO: 운영 환경에서는 제한 필요
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/health")
async def health_check():
    return {
        "status": "OK",
        "service": "KOTO AI Service",
        "version": "0.1.0",
        "gemini_configured": bool(os.getenv("GEMINI_API_KEY")),
        "google_credentials": bool(os.getenv("GOOGLE_APPLICATION_CREDENTIALS"))
    }

@app.get("/")
async def root():
    return {
        "message": "Korean Together AI Service",
        "endpoints": {
            "health": "/health",
            "stt": "/api/v1/stt (coming soon)",
            "tts": "/api/v1/tts (coming soon)",
            "evaluate": "/api/v1/evaluate (coming soon)"
        }
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        app,
        host="0.0.0.0",
        port=int(os.getenv("AI_PORT", "8000")),
        log_level="info"
    )
