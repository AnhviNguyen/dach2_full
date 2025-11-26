"""
TTS Service - Text-to-Speech using Google TTS (gTTS)

Google TTS is free, doesn't consume quota, and supports multiple languages.
"""
import logging
import hashlib
from pathlib import Path
from typing import Optional

logger = logging.getLogger(__name__)

# Directory for storing TTS audio files
MEDIA_DIR = Path("media/tts")
MEDIA_DIR.mkdir(parents=True, exist_ok=True)


def _get_audio_hash(text: str, lang: str) -> str:
    """Generate unique hash for text + language combination"""
    content = f"{text}_{lang}"
    return hashlib.md5(content.encode()).hexdigest()


def _detect_language(text: str) -> str:
    """
    Detect language from text to choose appropriate TTS language
    
    Returns:
        Language code: 'ko' for Korean, 'vi' for Vietnamese, 'en' for English
    """
    # Simple heuristic: check for Korean characters
    if any('\uAC00' <= char <= '\uD7A3' for char in text):
        return 'ko'  # Korean
    # Check for Vietnamese characters (with diacritics)
    elif any(char in 'àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđ' for char in text.lower()):
        return 'vi'  # Vietnamese
    else:
        return 'en'  # English (default)


async def generate_speech_google(
    text: str,
    lang: Optional[str] = None,
    allow_failure: bool = False
) -> Optional[str]:
    """
    Generate speech using Google TTS (gTTS) - FREE
    
    Args:
        text: Text to convert to speech
        lang: Language code (auto-detected if not provided)
        allow_failure: If True, return None on error instead of raising
    
    Returns:
        Path to audio file, or None if allow_failure=True and error occurs
    """
    try:
        import asyncio
        from gtts import gTTS
        
        # Auto-detect language if not provided
        if not lang:
            lang = _detect_language(text)
        
        # Check cache
        audio_hash = _get_audio_hash(text, lang)
        audio_path = MEDIA_DIR / f"{audio_hash}.mp3"
        
        # Return cached file if exists
        if audio_path.exists():
            logger.info(f"Google TTS cache hit for: {text[:50]}...")
            return str(audio_path)
        
        # Generate new audio using Google TTS
        logger.info(f"Generating Google TTS for: {text[:50]}... (lang={lang})")
        
        # Run gTTS in thread pool since it's a blocking I/O operation
        loop = asyncio.get_event_loop()
        
        def _generate_tts():
            """Synchronous function to generate TTS"""
            tts = gTTS(text=text, lang=lang, slow=False)
            tts.save(str(audio_path))
        
        # Execute in thread pool to avoid blocking
        await loop.run_in_executor(None, _generate_tts)
        
        logger.info(f"Google TTS saved to: {audio_path}")
        return str(audio_path)
        
    except ImportError:
        error_msg = "gTTS library not installed. Install with: pip install gtts"
        logger.error(error_msg)
        if allow_failure:
            return None
        raise ImportError(error_msg)
    except Exception as e:
        logger.error(f"Error in generate_speech_google: {e}")
        if allow_failure:
            logger.warning("Google TTS generation failed, returning None")
            return None
        raise


async def generate_speech(
    text: str,
    lang: Optional[str] = None,
    allow_failure: bool = False
) -> Optional[str]:
    """
    Generate speech from text using Google TTS (FREE)
    
    This is the main function to use. It uses Google TTS which is free
    and doesn't consume any quota.
    
    Args:
        text: Text to convert to speech
        lang: Language code (auto-detected if not provided: 'ko' for Korean, 'vi' for Vietnamese, 'en' for English)
        allow_failure: If True, return None on error instead of raising
    
    Returns:
        Path to audio file, or None if allow_failure=True and error occurs
    """
    return await generate_speech_google(text, lang=lang, allow_failure=allow_failure)

