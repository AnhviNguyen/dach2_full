"""
Speaking Router - Korean speaking practice and pronunciation evaluation
Tích hợp model pronunciation check với GPT để đạt độ chính xác cao và trải nghiệm tốt
"""
from fastapi import APIRouter, HTTPException, UploadFile, File, Form
from models.schemas import ReadAloudResponse, AccuracyDetails
from services import openai_service, accuracy_service
from services.pronunciation_model_service import (
    check_pronunciation_from_bytes,
    is_model_loaded
)
import logging
from typing import Optional
from pathlib import Path

logger = logging.getLogger(__name__)

router = APIRouter(
    prefix="/api",
    tags=["speaking"]
)

# Model is loaded in main.py startup event
# Just check if it's available
def get_model_status() -> bool:
    """Check if pronunciation model is loaded"""
    return is_model_loaded()


@router.post("/speaking/read-aloud", response_model=ReadAloudResponse)
async def check_read_aloud(
    audio: UploadFile = File(..., description="Audio file (webm, mp3, wav)"),
    expected_text: str = Form(..., description="The Korean text the user should read"),
    language: str = Form(default="ko", description="Language code (ko for Korean)")
):
    """
    Đánh giá phát âm tiếng Hàn khi đọc to
    Tích hợp model pronunciation check (Wav2Vec2 + Conformer) với GPT

    Quy trình:
    1. Transcribe audio bằng Whisper
    2. Check pronunciation bằng model chuyên dụng (nếu có)
    3. Tính word-level accuracy (fallback nếu model không có)
    4. Tạo feedback bằng GPT dựa trên kết quả model
    5. Trả về hybrid score kết hợp cả hai

    Supported audio formats: webm, mp3, wav, m4a
    """
    try:
        logger.info(f"Read-aloud check - Expected: '{expected_text[:50]}...', Audio: {audio.filename}")

        # Step 1: Transcribe audio using Whisper
        transcript = await openai_service.transcribe_audio(
            file=audio,
            language=language
        )
        logger.info(f"Transcript: '{transcript}'")

        # Step 2: Check pronunciation với model (nếu có)
        model_result = None
        phoneme_accuracy = None
        per = None
        
        if get_model_status():
            try:
                # Đọc audio bytes
                audio_bytes = await audio.read()
                await audio.seek(0)  # Reset file pointer
                
                # Check pronunciation với model
                pronunciation_result = check_pronunciation_from_bytes(
                    audio_bytes=audio_bytes,
                    expected_text=expected_text,
                    sample_rate=16000,
                    audio_format=Path(audio.filename).suffix[1:] if audio.filename else "wav"
                )
                
                if pronunciation_result:
                    model_result = {
                        "phoneme_accuracy": pronunciation_result.phoneme_accuracy,
                        "per": pronunciation_result.per,
                        "wrong_phonemes": pronunciation_result.wrong_phonemes,
                        "wrong_words": pronunciation_result.wrong_words,
                        "matches": pronunciation_result.matches,
                        "substitutions": pronunciation_result.substitutions,
                        "insertions": pronunciation_result.insertions,
                        "deletions": pronunciation_result.deletions
                    }
                    phoneme_accuracy = pronunciation_result.phoneme_accuracy
                    per = pronunciation_result.per
                    logger.info(f"✅ Model pronunciation check: {phoneme_accuracy:.1f}% accuracy, PER: {per:.4f}")
                else:
                    logger.warning("Model check returned None, falling back to word accuracy")
            except Exception as e:
                logger.error(f"Error in model pronunciation check: {e}. Falling back to word accuracy.")
        
        # Step 3: Calculate word accuracy (fallback hoặc bổ sung)
        word_accuracy, details = accuracy_service.calculate_word_accuracy(
            expected_text=expected_text,
            spoken_text=transcript,
            ignore_fillers=True
        )
        logger.info(f"Word accuracy: {word_accuracy}%")

        # Step 4: Generate AI feedback bằng tiếng Việt với thông tin từ model
        feedback_vi, tricky_words = await openai_service.generate_bilingual_feedback(
            expected_text=expected_text,
            spoken_text=transcript,
            word_accuracy=word_accuracy,
            accuracy_details=details,
            model_result=model_result  # Truyền kết quả từ model
        )
        logger.info(f"Feedback tiếng Việt: '{feedback_vi[:50]}...'")

        # Step 5: Generate TTS cho feedback
        try:
            # Vietnamese TTS (OpenAI TTS supports Vietnamese with 'alloy' voice)
            tts_vi_path = await openai_service.generate_speech(
                text=feedback_vi,
                voice="alloy"  # Works for Vietnamese
            )
            tts_vi_url = f"/media/{Path(tts_vi_path).name}"
            logger.info(f"VI TTS generated: {tts_vi_url}")
        except Exception as e:
            logger.error(f"Error generating VI TTS: {e}")
            tts_vi_url = None

        # Step 6: Calculate overall score
        # Ưu tiên model score nếu có, nếu không dùng word accuracy
        if phoneme_accuracy is not None:
            # Model có độ chính xác cao hơn, dùng làm chính
            overall_score = phoneme_accuracy
            logger.info(f"Using model phoneme accuracy as overall score: {overall_score:.1f}%")
        else:
            # Fallback: dùng word accuracy
            overall_score = word_accuracy
            logger.info(f"Using word accuracy as overall score: {overall_score:.1f}%")

        # Determine emotion tag
        if overall_score >= 85:
            emotion_tag = "praise"
        elif overall_score >= 70:
            emotion_tag = "encouraging"
        else:
            emotion_tag = "corrective"

        # Build accuracy details
        # Nếu có model result, ưu tiên dùng thông tin từ model
        if model_result:
            accuracy_details_obj = AccuracyDetails(
                word_accuracy=phoneme_accuracy,  # Dùng phoneme accuracy từ model
                wer=per,  # Dùng PER từ model
                matches=model_result.get("matches", 0),
                substitutions=model_result.get("substitutions", 0),
                insertions=model_result.get("insertions", 0),
                deletions=model_result.get("deletions", 0),
                expected_words=details.get("expected_words", []),  # Giữ word list từ accuracy service
                spoken_words=details.get("spoken_words", [])
            )
        else:
            accuracy_details_obj = AccuracyDetails(
                word_accuracy=word_accuracy,
                wer=details.get("wer", 1.0),
                matches=details.get("matches", 0),
                substitutions=details.get("substitutions", 0),
                insertions=details.get("insertions", 0),
                deletions=details.get("deletions", 0),
                expected_words=details.get("expected_words", []),
                spoken_words=details.get("spoken_words", [])
            )

        # Legacy combined feedback (giữ để tương thích)
        ai_feedback_combined = feedback_vi

        return ReadAloudResponse(
            transcript=transcript,
            expected_text=expected_text,
            word_accuracy=word_accuracy,
            ai_feedback=ai_feedback_combined,  # Legacy field
            overall_score=overall_score,
            emotion_tag=emotion_tag,
            accuracy_details=accuracy_details_obj,
            feedback_en="",  # Không dùng nữa, để trống
            feedback_vi=feedback_vi,
            tts_en_url=None,  # Không dùng nữa
            tts_vi_url=tts_vi_url,
            tricky_words=tricky_words,
            tts_url=None
        )

    except Exception as e:
        logger.error(f"Error in check_read_aloud: {e}")
        raise HTTPException(
            status_code=500,
            detail=f"Failed to evaluate pronunciation: {str(e)}"
        )


@router.post("/speaking/free-speak")
async def check_free_speaking(
    audio: UploadFile = File(..., description="Audio file"),
    context: Optional[str] = Form(default=None, description="Conversation context"),
    language: str = Form(default="ko", description="Language code (ko for Korean)")
):
    """
    Evaluate free-form Korean speaking (future feature)

    This will be used for Speaking Chat mode where user has
    natural conversation with Coach Ivy in Korean
    """
    try:
        # Step 1: Transcribe
        transcript = await openai_service.transcribe_audio(
            file=audio,
            language=language
        )

        # Step 2: Get conversational response from Coach Ivy
        reply, emotion_tag = await openai_service.chat_with_coach(
            message=transcript,
            mode="free_chat",
            context={"type": "speaking_practice", "context": context} if context else None
        )

        return {
            "transcript": transcript,
            "reply": reply,
            "emotion_tag": emotion_tag,
            "tts_url": None
        }

    except Exception as e:
        logger.error(f"Error in check_free_speaking: {e}")
        raise HTTPException(
            status_code=500,
            detail=f"Failed to process speech: {str(e)}"
        )
