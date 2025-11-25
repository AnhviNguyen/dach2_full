"""
FastAPI backend for Korean Learning App
Main application entry point
"""
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from config import settings
import logging

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Create FastAPI app
app = FastAPI(
    title="Korean Learning App API",
    description="Backend API for Korean Studio - Your premium Korean learning companion",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc"
)

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=[settings.frontend_url, "http://localhost:5173"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# ===== HEALTH CHECK =====

@app.get("/")
async def root():
    """Root endpoint - API info"""
    return {
        "message": "Korean Studio API",
        "version": "1.0.0",
        "status": "running",
        "docs": "/docs"
    }


@app.get("/ping")
async def ping():
    """Health check endpoint"""
    return {
        "status": "ok",
        "message": "pong"
    }


@app.get("/health")
async def health_check():
    """Detailed health check"""
    return {
        "status": "healthy",
        "environment": settings.env,
        "openai_configured": bool(settings.openai_api_key and settings.openai_api_key != "your_openai_api_key_here")
    }


# ===== IMPORT ROUTERS =====
from routers import chat, lesson, tts, media, speaking, live_talk, user_progress
from services.pronunciation_model_service import load_pronunciation_model, is_model_loaded

# Include routers
app.include_router(chat.router)
app.include_router(lesson.router)
app.include_router(tts.router)
app.include_router(speaking.router)
app.include_router(live_talk.router)
app.include_router(user_progress.router)
app.include_router(media.router)  # Media router without /api prefix

@app.on_event("startup")
async def startup_event():
    logger.info("🚀 Korean Studio API starting up...")
    logger.info(f"Environment: {settings.env}")
    logger.info(f"Frontend URL: {settings.frontend_url}")
    logger.info(f"OpenAI configured: {bool(settings.openai_api_key and settings.openai_api_key != 'your_openai_api_key_here')}")
    
    # Load pronunciation model
    logger.info("Loading pronunciation model...")
    try:
        model_loaded = load_pronunciation_model()
        if model_loaded:
            logger.info("✅ Pronunciation model loaded successfully")
        else:
            logger.warning("⚠️ Pronunciation model not found. Pronunciation checking will use word-level accuracy only.")
    except Exception as e:
        logger.error(f"❌ Failed to load pronunciation model: {e}")
        logger.warning("⚠️ Pronunciation checking will use word-level accuracy only.")


@app.on_event("shutdown")
async def shutdown_event():
    logger.info("👋 Korean Studio API shutting down...")


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "main:app",
        host=settings.backend_host,
        port=settings.backend_port,
        reload=(settings.env == "development"),
        log_level="info"
    )
