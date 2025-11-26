"""
Lesson Router - Endpoints for Korean lesson management and exercise checking
Tích hợp đầy đủ các loại bài tập: multiple choice, fill blank, reorder, và pronunciation
"""
from fastapi import APIRouter, HTTPException, UploadFile, File, Form, Request
from models.schemas import ExerciseCheckRequest, ExerciseCheckResponse
from services import openai_service, accuracy_service
from services.tts_service import generate_speech
from services.error_handlers import handle_openai_error, is_quota_error
from services.pronunciation_model_service import (
    check_pronunciation_from_bytes,
    is_model_loaded
)
import logging
from typing import Optional
from pathlib import Path
import json

logger = logging.getLogger(__name__)

router = APIRouter(
    prefix="/api/lesson",
    tags=["lesson"]
)


def get_model_status() -> bool:
    """Check if pronunciation model is loaded"""
    return is_model_loaded()


@router.post("/check-exercise", response_model=ExerciseCheckResponse)
async def check_exercise(
    request: Request,
    # For pronunciation exercises, accept audio file directly
    audio: Optional[UploadFile] = File(None, description="Audio file for pronunciation exercise"),
    lesson_id: Optional[str] = Form(None),
    exercise_type: Optional[str] = Form(None),
    expected_text: Optional[str] = Form(None),
    user_answers: Optional[str] = Form(None),  # JSON string for text exercises
    correct_answers: Optional[str] = Form(None),  # JSON string for text exercises
    question: Optional[str] = Form(None)
):
    """
    Check Korean exercise answers - Hỗ trợ đầy đủ các loại bài tập:
    - multiple_choice: Trắc nghiệm
    - fill_blank: Điền vào chỗ trống
    - reorder: Sắp xếp lại
    - pronunciation: Đánh giá phát âm (tích hợp pronunciation model)
    
    Có thể gọi theo 2 cách:
    1. JSON body (cho text exercises)
    2. Form data với audio file (cho pronunciation exercises)
    """
    try:
        # Determine exercise type and parse inputs
        # Priority: JSON body (request) > Form data with audio > Form data without audio
        
        # Check content type to determine how to parse
        content_type = request.headers.get("content-type", "")
        
        # Check if we have audio file (pronunciation exercises)
        if audio is not None:
            # Form data with audio (pronunciation exercises)
            ex_type = exercise_type or "pronunciation"
            lesson = lesson_id or "unknown"
            expected = expected_text
            user_ans = []
            correct_ans = []
            q = question
            logger.info(f"Using Form data with audio - type: {ex_type}")
        elif "application/json" in content_type:
            # JSON body request (text exercises)
            try:
                body = await request.json()
                request_data = ExerciseCheckRequest(**body)
                ex_type = request_data.exercise_type
                lesson = request_data.lesson_id
                expected = request_data.expected_text
                user_ans = request_data.user_answers if request_data.user_answers else []
                correct_ans = request_data.correct_answers if request_data.correct_answers else []
                q = request_data.question
                logger.info(f"Using JSON body request - type: {ex_type}, user_ans: {len(user_ans)}, correct_ans: {len(correct_ans)}")
            except Exception as e:
                logger.error(f"Failed to parse JSON body: {e}")
                raise HTTPException(
                    status_code=400,
                    detail=f"Invalid JSON body: {str(e)}"
                )
        else:
            # Form data without audio (text exercises via form)
            ex_type = exercise_type or "multiple_choice"
            lesson = lesson_id or "unknown"
            expected = expected_text
            user_ans = []
            correct_ans = []
            q = question
            if user_answers:
                try:
                    user_ans = json.loads(user_answers)
                except Exception as e:
                    logger.warning(f"Failed to parse user_answers JSON: {e}")
                    user_ans = []
            if correct_answers:
                try:
                    correct_ans = json.loads(correct_answers)
                except Exception as e:
                    logger.warning(f"Failed to parse correct_answers JSON: {e}")
                    correct_ans = []
            logger.info(f"Using Form data without audio - type: {ex_type}, user_ans: {len(user_ans)}, correct_ans: {len(correct_ans)}")
        
        logger.info(f"Exercise check - lesson: {lesson}, type: {ex_type}")
        
        # Handle pronunciation exercises
        if ex_type == "pronunciation":
            if not audio:
                raise HTTPException(
                    status_code=400,
                    detail="Audio file is required for pronunciation exercises"
                )
            if not expected:
                raise HTTPException(
                    status_code=400,
                    detail="expected_text is required for pronunciation exercises"
                )
            
            return await check_pronunciation_exercise(
                audio=audio,
                expected_text=expected,
                lesson_id=lesson,
                question=q
            )
        
        # Handle text-based exercises (multiple_choice, fill_blank, reorder)
        else:
            if not user_ans or not correct_ans:
                raise HTTPException(
                    status_code=400,
                    detail="user_answers and correct_answers are required for text exercises"
                )
            
            # Use AI to generate feedback
            try:
                is_correct, score, feedback, emotion_tag = await openai_service.check_exercise_with_feedback(
                    question=q or "Exercise question",
                    user_answers=user_ans,
                    correct_answers=correct_ans,
                    exercise_type=ex_type
                )
            except Exception as e:
                raise handle_openai_error(e, service_name="Exercise check")
            
            # Generate TTS for correct answer if needed (optional - won't fail if quota exceeded)
            tts_url = None
            if is_correct and correct_ans:
                correct_text = " ".join(correct_ans) if isinstance(correct_ans, list) else str(correct_ans)
                tts_path = await generate_speech(
                    text=correct_text,
                    allow_failure=True  # Don't fail the whole request if TTS fails
                )
                if tts_path:
                    tts_url = f"/media/{Path(tts_path).name}"
            
            return ExerciseCheckResponse(
                is_correct=is_correct,
                score=score,
                feedback=feedback,
                emotion_tag=emotion_tag,
                tts_url=tts_url,
                exercise_type=ex_type,
                pronunciation_details=None
            )

    except HTTPException:
        raise
    except Exception as e:
        raise handle_openai_error(e, service_name="Exercise check")


async def check_pronunciation_exercise(
    audio: UploadFile,
    expected_text: str,
    lesson_id: str,
    question: Optional[str] = None
) -> ExerciseCheckResponse:
    """
    Check pronunciation exercise - tích hợp pronunciation model vào bài học
    
    Quy trình:
    1. Transcribe audio bằng Whisper
    2. Check pronunciation bằng model (nếu có)
    3. Tính word-level accuracy
    4. Tạo feedback bằng GPT
    5. Generate TTS cho feedback
    """
    try:
        logger.info(f"Pronunciation exercise - Lesson: {lesson_id}, Expected: '{expected_text[:50]}...'")
        
        # Step 1: Transcribe audio using Whisper
        transcript = await openai_service.transcribe_audio(
            file=audio,
            language="ko"
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
            except Exception as e:
                logger.error(f"Error in model pronunciation check: {e}. Falling back to word accuracy.")
        
        # Step 3: Calculate word accuracy
        word_accuracy, details = accuracy_service.calculate_word_accuracy(
            expected_text=expected_text,
            spoken_text=transcript,
            ignore_fillers=True
        )
        logger.info(f"Word accuracy: {word_accuracy}%")
        
        # Step 4: Generate AI feedback
        feedback_vi, tricky_words = await openai_service.generate_bilingual_feedback(
            expected_text=expected_text,
            spoken_text=transcript,
            word_accuracy=word_accuracy,
            accuracy_details=details,
            model_result=model_result
        )
        
        # Step 5: Calculate overall score
        if phoneme_accuracy is not None:
            overall_score = phoneme_accuracy
        else:
            overall_score = word_accuracy
        
        # Determine if correct (threshold: >= 70%)
        is_correct = overall_score >= 70.0
        
        # Determine emotion tag
        if overall_score >= 85:
            emotion_tag = "praise"
        elif overall_score >= 70:
            emotion_tag = "encouraging"
        else:
            emotion_tag = "corrective"
        
        # Step 6: Generate TTS cho feedback (optional - won't fail if error)
        tts_url = None
        tts_vi_path = await generate_speech(
            text=feedback_vi,
            lang="vi",  # Vietnamese feedback
            allow_failure=True  # Don't fail the whole request if TTS fails
        )
        if tts_vi_path:
            tts_url = f"/media/{Path(tts_vi_path).name}"
        
        # Build pronunciation details
        pronunciation_details = {
            "transcript": transcript,
            "expected_text": expected_text,
            "word_accuracy": word_accuracy,
            "phoneme_accuracy": phoneme_accuracy,
            "per": per,
            "overall_score": overall_score,
            "tricky_words": tricky_words or [],
            "accuracy_details": {
                "matches": model_result.get("matches", details.get("matches", 0)) if model_result else details.get("matches", 0),
                "substitutions": model_result.get("substitutions", details.get("substitutions", 0)) if model_result else details.get("substitutions", 0),
                "insertions": model_result.get("insertions", details.get("insertions", 0)) if model_result else details.get("insertions", 0),
                "deletions": model_result.get("deletions", details.get("deletions", 0)) if model_result else details.get("deletions", 0),
            } if model_result or details else None
        }
        
        return ExerciseCheckResponse(
            is_correct=is_correct,
            score=overall_score,
            feedback=feedback_vi,
            emotion_tag=emotion_tag,
            tts_url=tts_url,
            exercise_type="pronunciation",
            pronunciation_details=pronunciation_details
        )
        
    except Exception as e:
        logger.error(f"Error in check_pronunciation_exercise: {e}")
        raise HTTPException(
            status_code=500,
            detail=f"Failed to check pronunciation: {str(e)}"
        )


@router.get("/list")
async def get_lessons():
    """
    Get list of available lessons with their exercises
    
    Returns list of lessons with metadata about available exercise types
    """
    # This is a placeholder - in production, this would fetch from database
    lessons = [
        {
            "lesson_id": "lesson_1",
            "title": "Bài 1: Chào hỏi",
            "description": "Học cách chào hỏi cơ bản trong tiếng Hàn",
            "level": "beginner",
            "available_exercises": [
                {
                    "type": "multiple_choice",
                    "title": "Trắc nghiệm",
                    "description": "Chọn đáp án đúng"
                },
                {
                    "type": "pronunciation",
                    "title": "Luyện phát âm",
                    "description": "Đọc to và kiểm tra phát âm"
                }
            ]
        },
        {
            "lesson_id": "lesson_2",
            "title": "Bài 2: Giới thiệu bản thân",
            "description": "Học cách giới thiệu bản thân",
            "level": "beginner",
            "available_exercises": [
                {
                    "type": "fill_blank",
                    "title": "Điền vào chỗ trống",
                    "description": "Hoàn thành câu"
                },
                {
                    "type": "pronunciation",
                    "title": "Luyện phát âm",
                    "description": "Đọc to và kiểm tra phát âm"
                }
            ]
        }
    ]
    
    return {
        "lessons": lessons,
        "total": len(lessons)
    }


@router.get("/{lesson_id}")
async def get_lesson_detail(lesson_id: str):
    """
    Get detailed information about a specific lesson
    
    Returns lesson content, exercises, and metadata
    """
    # Placeholder - in production, fetch from database
    return {
        "lesson_id": lesson_id,
        "title": f"Lesson {lesson_id}",
        "description": "Lesson description",
        "content": "Lesson content here...",
        "exercises": [
            {
                "exercise_id": f"{lesson_id}_ex1",
                "type": "multiple_choice",
                "question": "Chọn câu chào hỏi đúng",
                "options": ["안녕하세요", "감사합니다", "죄송합니다"]
            },
            {
                "exercise_id": f"{lesson_id}_ex2",
                "type": "pronunciation",
                "expected_text": "안녕하세요",
                "instruction": "Đọc to câu sau"
            }
        ]
    }
