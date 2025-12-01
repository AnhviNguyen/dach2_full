"""
FastAPI backend for Korean Learning App
Main application entry point

This module sets up the FastAPI application, configures CORS,
registers routers, and handles startup/shutdown events.
"""
import logging
from typing import Dict, Any

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from config import settings

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
# In development, allow all localhost origins (Flutter Web can run on any port)
if settings.env == "development":
    # Use allow_origin_regex to match any localhost port
    # This allows credentials to be sent
    app.add_middleware(
        CORSMiddleware,
        allow_origin_regex=r"https?://(localhost|127\.0\.0\.1|0\.0\.0\.0)(:\d+)?$",
        allow_credentials=True,
        allow_methods=["GET", "POST", "PUT", "DELETE", "OPTIONS", "PATCH", "HEAD"],
        allow_headers=["*"],
        expose_headers=["*"],
        max_age=3600,  # Cache preflight requests for 1 hour
    )
else:
    # In production, use specific origins
    allowed_origins = [
        settings.frontend_url,
        "http://localhost:5173",
    ]
    app.add_middleware(
        CORSMiddleware,
        allow_origins=allowed_origins,
        allow_credentials=True,
        allow_methods=["GET", "POST", "PUT", "DELETE", "OPTIONS", "PATCH", "HEAD"],
        allow_headers=["*"],
        expose_headers=["*"],
        max_age=3600,
    )


# ===== HEALTH CHECK =====

@app.get("/")
async def root() -> Dict[str, Any]:
    """
    Root endpoint - API information
    
    Returns:
        Basic API information and status
    """
    return {
        "message": "Korean Studio API",
        "version": "1.0.0",
        "status": "running",
        "docs": "/docs"
    }


@app.get("/ping")
async def ping() -> Dict[str, str]:
    """
    Health check endpoint
    
    Returns:
        Simple ping response
    """
    return {
        "status": "ok",
        "message": "pong"
    }


@app.get("/health")
async def health_check() -> Dict[str, Any]:
    """
    Detailed health check endpoint
    
    Returns:
        Health status including environment and OpenAI configuration status
    """
    return {
        "status": "healthy",
        "environment": settings.env,
        "openai_configured": bool(
            settings.openai_api_key 
            and settings.openai_api_key != "your_openai_api_key_here"
        )
    }


@app.get("/debug/openai-key")
async def debug_openai_key() -> Dict[str, Any]:
    """
    Debug endpoint to check OpenAI API key status (masked)
    
    This endpoint helps diagnose OpenAI API configuration issues.
    It tests the API key and returns masked information.
    
    Returns:
        Dictionary with API key status, masked preview, and test result
    """
    api_key = settings.openai_api_key
    if not api_key or api_key == "your_openai_api_key_here":
        return {
            "configured": False,
            "key_preview": None,
            "message": "API key not configured"
        }
    
    # Mask API key for security
    masked_key = f"{api_key[:10]}...{api_key[-4:]}" if len(api_key) > 14 else "***"
    
    # Test the key
    from openai import OpenAI
    test_result = None
    error_message = None
    
    try:
        client = OpenAI(api_key=api_key)
        response = client.chat.completions.create(
            model="gpt-4o-mini",
            messages=[{"role": "user", "content": "test"}],
            max_tokens=5
        )
        test_result = "success"
    except Exception as e:
        error_str = str(e)
        test_result = "failed"
        if "insufficient_quota" in error_str or "429" in error_str or "quota" in error_str.lower():
            error_message = "quota_exceeded"
        elif "invalid_api_key" in error_str or "401" in error_str:
            error_message = "invalid_key"
        else:
            error_message = str(e)[:100]
    
    return {
        "configured": True,
        "key_preview": masked_key,
        "test_result": test_result,
        "error": error_message,
        "model": settings.openai_model_name
    }


# ===== IMPORT ROUTERS =====
from routers import chat, lesson, tts, media, speaking, live_talk, user_progress, dictionary, topik, vocabulary, exercise, progress, roadmap
from services.pronunciation_model_service import load_pronunciation_model, is_model_loaded

# Include routers
app.include_router(chat.router)
app.include_router(lesson.router)
app.include_router(tts.router)
app.include_router(speaking.router)
app.include_router(live_talk.router)
app.include_router(user_progress.router)
app.include_router(media.router)  # Media router without /api prefix
app.include_router(dictionary.router)  # Dictionary router
app.include_router(topik.router)  # TOPIK router
app.include_router(vocabulary.router)  # Vocabulary router
app.include_router(exercise.router)  # Exercise router
app.include_router(progress.router)  # Progress router
app.include_router(roadmap.router)  # Roadmap router

@app.on_event("startup")
async def startup_event():
    logger.info("🚀 Korean Studio API starting up...")
    logger.info(f"Environment: {settings.env}")
    logger.info(f"Frontend URL: {settings.frontend_url}")
    
    # Log OpenAI API key status (masked)
    api_key = settings.openai_api_key
    if api_key and api_key != "your_openai_api_key_here":
        masked_key = f"{api_key[:10]}...{api_key[-4:]}" if len(api_key) > 14 else "***"
        logger.info(f"OpenAI API key: {masked_key}")
        logger.info(f"OpenAI model: {settings.openai_model_name}")
    else:
        logger.warning("⚠️ OpenAI API key not configured!")
    
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
