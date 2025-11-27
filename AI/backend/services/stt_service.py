"""
STT Service - Speech-to-Text using local Whisper or Google STT
Giảm chi phí bằng cách không dùng OpenAI Whisper API
"""
import logging
import os
import tempfile
import subprocess
from pathlib import Path
from typing import Optional
from fastapi import UploadFile, HTTPException

logger = logging.getLogger(__name__)

# Try to use local Whisper first, fallback to Google STT
USE_LOCAL_WHISPER = os.getenv("USE_LOCAL_WHISPER", "true").lower() == "true"
USE_GOOGLE_STT = os.getenv("USE_GOOGLE_STT", "false").lower() == "true"

# Global Whisper model (loaded once)
_whisper_model = None
_whisper_processor = None


def _load_whisper_local():
    """Load local Whisper model (tiny or base)"""
    global _whisper_model, _whisper_processor
    
    if _whisper_model is not None:
        return True
    
    try:
        from transformers import WhisperProcessor, WhisperForConditionalGeneration
        import torch
        
        model_name = os.getenv("WHISPER_MODEL", "openai/whisper-tiny")  # tiny is fastest, base is better
        
        logger.info(f"Loading local Whisper model: {model_name}")
        _whisper_processor = WhisperProcessor.from_pretrained(model_name)
        _whisper_model = WhisperForConditionalGeneration.from_pretrained(model_name)
        
        # Use CPU by default (can use GPU if available)
        device = "cuda" if torch.cuda.is_available() else "cpu"
        _whisper_model.to(device)
        _whisper_model.eval()
        
        logger.info(f"✅ Local Whisper model loaded on {device}")
        return True
        
    except ImportError:
        logger.warning("transformers not installed. Install with: pip install transformers")
        return False
    except Exception as e:
        logger.error(f"Failed to load local Whisper: {e}")
        return False


def _convert_audio_to_wav(input_path: str, output_path: Optional[str] = None) -> Optional[str]:
    """
    Convert audio file to WAV format using ffmpeg (if available)
    
    Args:
        input_path: Path to input audio file
        output_path: Path to output WAV file (auto-generated if None)
    
    Returns:
        Path to converted WAV file, or None if conversion failed
    """
    if output_path is None:
        output_path = input_path.rsplit('.', 1)[0] + '_converted.wav'
    
    try:
        # Check if ffmpeg is available
        subprocess.run(['ffmpeg', '-version'], 
                      capture_output=True, 
                      check=True,
                      timeout=5)
    except (subprocess.CalledProcessError, FileNotFoundError, subprocess.TimeoutExpired):
        logger.warning("ffmpeg not found. Cannot convert audio formats.")
        return None
    
    try:
        # Convert to WAV using ffmpeg
        # -y: overwrite output file
        # -ar 16000: set sample rate to 16kHz
        # -ac 1: convert to mono
        # -f wav: output format WAV
        cmd = [
            'ffmpeg',
            '-i', input_path,
            '-ar', '16000',  # Sample rate 16kHz
            '-ac', '1',      # Mono
            '-f', 'wav',     # Format WAV
            '-y',            # Overwrite output
            output_path
        ]
        
        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            timeout=30  # 30 second timeout
        )
        
        if result.returncode == 0 and os.path.exists(output_path):
            logger.info(f"✅ Converted audio to WAV: {output_path}")
            return output_path
        else:
            logger.error(f"ffmpeg conversion failed: {result.stderr}")
            return None
            
    except subprocess.TimeoutExpired:
        logger.error("ffmpeg conversion timeout")
        return None
    except Exception as e:
        logger.error(f"Error converting audio: {e}")
        return None


async def transcribe_with_local_whisper(
    audio_file_path: str,
    language: str = "ko"
) -> Optional[str]:
    """
    Transcribe audio using local Whisper model (FREE)
    
    Args:
        audio_file_path: Path to audio file
        language: Language code (ko, vi, en, etc.)
    
    Returns:
        Transcribed text or None if error
    """
    converted_path = None
    try:
        if not _load_whisper_local():
            logger.warning("Local Whisper model not loaded")
            return None
        
        import librosa
        import torch
        import numpy as np
        import warnings
        
        # Suppress librosa warnings
        with warnings.catch_warnings():
            warnings.filterwarnings("ignore", category=FutureWarning)
            warnings.filterwarnings("ignore", category=UserWarning)
            
            # Load audio - try different methods
            audio = None
            sr = None
            
            try:
                # Try loading with librosa (handles most formats)
                audio, sr = librosa.load(audio_file_path, sr=16000, mono=True)
            except Exception as load_error:
                logger.warning(f"librosa failed: {load_error}")
                # Try with soundfile directly
                try:
                    import soundfile as sf
                    audio, sr = sf.read(audio_file_path)
                    # Convert to mono if stereo
                    if len(audio.shape) > 1:
                        audio = np.mean(audio, axis=1)
                    # Resample to 16kHz if needed
                    if sr != 16000:
                        audio = librosa.resample(audio, orig_sr=sr, target_sr=16000)
                        sr = 16000
                except Exception as sf_error:
                    logger.warning(f"soundfile failed: {sf_error}")
                    # Last resort: try converting to WAV first (for m4a, webm, etc.)
                    logger.info("🔄 Attempting to convert audio to WAV format...")
                    converted_path = _convert_audio_to_wav(audio_file_path)
                    if converted_path and os.path.exists(converted_path):
                        try:
                            audio, sr = librosa.load(converted_path, sr=16000, mono=True)
                            logger.info("✅ Successfully loaded converted WAV file")
                        except Exception as convert_error:
                            logger.error(f"Failed to load converted WAV: {convert_error}")
                            return None
                    else:
                        logger.error("Could not convert audio format. Install ffmpeg for better format support.")
                        return None
        
        if audio is None or len(audio) == 0:
            logger.error("Audio file is empty or invalid")
            return None
        
        logger.info(f"Audio loaded: {len(audio)} samples at {sr}Hz")
        
        # Process with Whisper
        inputs = _whisper_processor(audio, sampling_rate=16000, return_tensors="pt")
        
        # Move to same device as model
        device = next(_whisper_model.parameters()).device
        inputs = {k: v.to(device) for k, v in inputs.items()}
        
        # Generate transcription
        with torch.no_grad():
            generated_ids = _whisper_model.generate(
                inputs["input_features"],
                language=language,
                task="transcribe"
            )
        
        # Decode
        transcription = _whisper_processor.batch_decode(
            generated_ids, 
            skip_special_tokens=True
        )[0]
        
        if not transcription or not transcription.strip():
            logger.warning("Local Whisper returned empty transcription")
            return None
        
        logger.info(f"✅ Local Whisper transcription: '{transcription[:100]}...'")
        return transcription.strip()
        
    except ImportError as e:
        logger.error(f"Missing dependency for local Whisper: {e}")
        logger.info("Install with: pip install transformers torch librosa soundfile")
        return None
    except Exception as e:
        logger.error(f"Error in local Whisper transcription: {e}", exc_info=True)
        return None
    finally:
        # Cleanup converted file if created
        if converted_path and os.path.exists(converted_path):
            try:
                os.unlink(converted_path)
                logger.debug(f"Cleaned up converted file: {converted_path}")
            except Exception as e:
                logger.warning(f"Failed to delete converted file: {e}")


async def transcribe_with_google_stt(
    audio_file_path: str,
    language: str = "ko"
) -> Optional[str]:
    """
    Transcribe audio using Google Speech-to-Text API (rẻ hơn OpenAI)
    
    Requires: pip install google-cloud-speech
    
    Args:
        audio_file_path: Path to audio file
        language: Language code (ko-KR, vi-VN, en-US, etc.)
    
    Returns:
        Transcribed text or None if error
    """
    try:
        from google.cloud import speech
        
        # Initialize client
        client = speech.SpeechClient()
        
        # Read audio file
        with open(audio_file_path, "rb") as audio_file:
            content = audio_file.read()
        
        # Configure recognition
        # Map language codes: ko -> ko-KR, vi -> vi-VN
        lang_code_map = {
            "ko": "ko-KR",
            "vi": "vi-VN",
            "en": "en-US"
        }
        google_lang = lang_code_map.get(language, language)
        
        # Detect audio format
        # For now, assume LINEAR16 (WAV). Can be improved to auto-detect
        config = speech.RecognitionConfig(
            encoding=speech.RecognitionConfig.AudioEncoding.ENCODING_UNSPECIFIED,  # Auto-detect
            sample_rate_hertz=16000,
            language_code=google_lang,
            audio_channel_count=1,
        )
        
        audio = speech.RecognitionAudio(content=content)
        
        # Perform transcription
        response = client.recognize(config=config, audio=audio)
        
        if not response.results:
            logger.warning("Google STT returned no results")
            return None
        
        # Get first result
        transcript = response.results[0].alternatives[0].transcript
        logger.info(f"Google STT transcription: {transcript[:100]}...")
        return transcript.strip()
        
    except ImportError:
        logger.warning("google-cloud-speech not installed. Install with: pip install google-cloud-speech")
        return None
    except Exception as e:
        logger.error(f"Error in Google STT transcription: {e}")
        return None


async def transcribe_audio_cheap(
    file: UploadFile,
    language: str = "ko"
) -> str:
    """
    Transcribe audio using cheapest available method
    
    Priority:
    1. Local Whisper (FREE, no quota)
    2. Google STT (cheaper than OpenAI)
    3. Fallback to OpenAI Whisper (if configured)
    
    Args:
        file: Audio file upload
        language: Language code
    
    Returns:
        Transcribed text
    """
    temp_file_path = None
    
    try:
        # Save uploaded file to temp location
        file_extension = Path(file.filename).suffix or ".webm"
        with tempfile.NamedTemporaryFile(delete=False, suffix=file_extension) as temp_file:
            temp_file_path = temp_file.name
            content = await file.read()
            temp_file.write(content)
            temp_file.flush()
        
        # Reset file pointer for potential reuse
        await file.seek(0)
        
        logger.info(f"Transcribing audio: {file.filename} ({len(content)} bytes)")
        
        # Try local Whisper first (FREE)
        if USE_LOCAL_WHISPER:
            try:
                logger.info("🔄 Trying local Whisper (FREE)...")
                transcript = await transcribe_with_local_whisper(temp_file_path, language)
                if transcript and transcript.strip():
                    logger.info("✅ Used local Whisper (FREE) - No quota consumed!")
                    return transcript
                else:
                    logger.warning("⚠️ Local Whisper returned empty transcript")
            except ImportError as e:
                logger.error(f"❌ Local Whisper dependencies missing: {e}")
                logger.info("💡 Install with: pip install transformers torch librosa soundfile")
            except Exception as e:
                logger.warning(f"⚠️ Local Whisper failed: {e}")
                logger.debug(f"Error details: {e}", exc_info=True)
        
        # Try Google STT (cheaper than OpenAI)
        if USE_GOOGLE_STT:
            try:
                transcript = await transcribe_with_google_stt(temp_file_path, language)
                if transcript and transcript.strip():
                    logger.info("✅ Used Google STT (cheaper)")
                    return transcript
                else:
                    logger.warning("Google STT returned empty transcript")
            except Exception as e:
                logger.warning(f"Google STT failed: {e}. Trying next method...")
        
        # Fallback: Use OpenAI Whisper (if available, but costs money)
        # Only if both local methods failed
        logger.warning("Both local methods failed. Falling back to OpenAI Whisper (costs money)")
        try:
            from services.openai_service import transcribe_audio
            await file.seek(0)  # Reset file pointer
            return await transcribe_audio(file, language)
        except Exception as openai_error:
            error_str = str(openai_error)
            # Check if it's a quota error
            if "429" in error_str or "quota" in error_str.lower() or "insufficient_quota" in error_str.lower():
                logger.error(f"OpenAI Whisper failed due to quota: {openai_error}")
                raise HTTPException(
                    status_code=503,
                    detail="Đã vượt quá hạn mức API. Local Whisper không khả dụng. Vui lòng kiểm tra tài khoản và thêm credits, hoặc cài đặt local Whisper."
                )
            else:
                logger.error(f"OpenAI Whisper also failed: {openai_error}")
                # If OpenAI also fails (e.g., quota), raise a clear error
                raise HTTPException(
                    status_code=500,
                    detail=f"Tất cả phương pháp STT đều thất bại. Local Whisper: {'failed' if USE_LOCAL_WHISPER else 'disabled'}, "
                           f"Google STT: {'failed' if USE_GOOGLE_STT else 'disabled'}, "
                           f"OpenAI Whisper: failed ({str(openai_error)[:200]})"
                )
        
    except Exception as e:
        logger.error(f"Error in transcribe_audio_cheap: {e}")
        raise
    
    finally:
        # Cleanup temp file
        if temp_file_path and os.path.exists(temp_file_path):
            try:
                os.unlink(temp_file_path)
            except Exception as e:
                logger.warning(f"Failed to delete temp file: {e}")

