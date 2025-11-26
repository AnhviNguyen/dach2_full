"""
TTS Router - Text-to-Speech endpoints using OpenAI TTS
"""
from fastapi import APIRouter, HTTPException
from fastapi.responses import FileResponse
from models.schemas import TTSRequest, TTSResponse
from services.tts_service import generate_speech
from services.error_handlers import handle_openai_error
import logging
from pathlib import Path

logger = logging.getLogger(__name__)

router = APIRouter(
    prefix="/api",
    tags=["tts"]
)


@router.post("/tts", response_model=TTSResponse)
async def text_to_speech(request: TTSRequest):
    """
    Generate speech from text using Google TTS (FREE)

    This endpoint converts text to speech and returns the audio file path.
    Results are cached - same text with same language will return cached audio.
    
    Language is auto-detected if not provided:
    - Korean (한국어): 'ko'
    - Vietnamese (Tiếng Việt): 'vi'
    - English: 'en'
    """
    try:
        logger.info(f"TTS request - text: {request.text[:50]}..., lang: {request.lang or 'auto'}")

        # Generate speech using Google TTS (free, no quota)
        audio_path = await generate_speech(
            text=request.text,
            lang=request.lang
        )

        # Convert absolute path to URL-friendly path
        # For now, return the relative path that frontend can fetch
        audio_url = f"/media/{Path(audio_path).name}"

        return TTSResponse(
            audio_url=audio_url,
            text=request.text
        )

    except Exception as e:
        raise handle_openai_error(e, service_name="TTS")


# Media serving moved to routers/media.py
