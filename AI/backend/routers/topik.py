"""
TOPIK Router - Endpoints for TOPIK exam questions
"""
from fastapi import APIRouter, HTTPException, Query
from typing import List, Dict, Any, Optional, Literal
import logging

from services import topik_service
from services import vocabulary_lookup_service as dictionary_service

logger = logging.getLogger(__name__)

router = APIRouter(
    prefix="/api/topik",
    tags=["topik"]
)


@router.get("/exams")
async def list_exams() -> Dict[str, Any]:
    """
    List all available TOPIK exam numbers
    
    Returns:
        List of available exam numbers
    """
    try:
        exams = topik_service.list_available_exams()
        return {
            "exams": exams,
            "total": len(exams)
        }
    except Exception as e:
        logger.error(f"Error listing exams: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to list exams: {str(e)}")


@router.get("/exams/{exam_number}/questions")
async def get_topik_questions(
    exam_number: str,
    question_type: Literal["listening", "reading"] = Query(..., description="Type of questions: 'listening' (30 questions with audio) or 'reading' (40 questions, no audio)"),
    limit: Optional[int] = Query(None, ge=1, le=100, description="Limit number of questions returned"),
    offset: int = Query(0, ge=0, description="Offset for pagination")
) -> Dict[str, Any]:
    """
    Get TOPIK questions for a specific exam
    
    TOPIK 1 Structure:
    - Listening: 30 questions, each has audio file
    - Reading: 40 questions, no audio
    
    Args:
        exam_number: Exam number (e.g., "35", "36", "37")
        question_type: "listening" (30 questions with audio) or "reading" (40 questions, no audio)
        limit: Maximum number of questions to return
        offset: Offset for pagination
    
    Returns:
        Dictionary with questions data including audio URLs for listening questions
    """
    try:
        data = topik_service.load_topik_questions(exam_number, question_type)
        
        if "error" in data:
            raise HTTPException(status_code=404, detail=data["error"])
        
        questions = data.get("questions", [])
        total = data.get("total", len(questions))
        has_audio = data.get("has_audio", question_type == "listening")
        
        # Apply pagination
        if limit is not None:
            questions = questions[offset:offset + limit]
        else:
            questions = questions[offset:]
        
        # Log audio information for listening
        if question_type == "listening":
            audio_count = sum(1 for q in questions if q.get("audio_url"))
            logger.info(f"Returning {len(questions)} listening questions, {audio_count} with audio URLs")
        
        return {
            "exam_number": exam_number,
            "question_type": question_type,
            "total_questions": total,  # Total questions in exam (30 for listening, 40 for reading)
            "has_audio": has_audio,  # True for listening, False for reading
            "questions": questions,
            "returned": len(questions),
            "offset": offset,
            "limit": limit
        }
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error getting TOPIK questions: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to get questions: {str(e)}")


@router.get("/exams/{exam_number}/questions/{question_id}")
async def get_topik_question(
    exam_number: str,
    question_id: str,
    question_type: Literal["listening", "reading"] = Query(..., description="Type of questions: 'listening' or 'reading'")
) -> Dict[str, Any]:
    """
    Get a specific TOPIK question by ID
    
    For listening questions, includes audio_url for playback.
    For reading questions, no audio_url.
    
    Args:
        exam_number: Exam number (e.g., "35", "36", "37")
        question_id: Question ID
        question_type: "listening" (has audio) or "reading" (no audio)
    
    Returns:
        Question data with audio_url if listening question
    """
    try:
        question = topik_service.get_topik_question(exam_number, question_type, question_id)
        if question is None:
            raise HTTPException(
                status_code=404,
                detail=f"Question {question_id} not found in exam {exam_number}"
            )
        
        # Extract audio URL if listening question
        audio_url = None
        if question_type == "listening":
            context = question.get("context", {})
            audio_url = context.get("audio") or question.get("audio_url")
            if audio_url:
                logger.info(f"Question {question_id} has audio: {audio_url}")
        
        return {
            "exam_number": exam_number,
            "question_type": question_type,
            "has_audio": question_type == "listening" and audio_url is not None,
            "audio_url": audio_url,  # Audio URL for listening questions (None for reading)
            "question": question
        }
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error getting TOPIK question: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to get question: {str(e)}")


@router.get("/exams/{exam_number}/questions/number/{number}")
async def get_topik_question_by_number(
    exam_number: str,
    number: int,
    question_type: Literal["listening", "reading"] = Query(..., description="Type of questions: 'listening' (1-30) or 'reading' (1-40)")
) -> Dict[str, Any]:
    """
    Get a specific TOPIK question by question number
    
    Question number ranges:
    - Listening: 1-30
    - Reading: 1-40
    
    For listening questions, includes audio_url for playback.
    
    Args:
        exam_number: Exam number (e.g., "35", "36", "37")
        number: Question number (1-indexed, 1-30 for listening, 1-40 for reading)
        question_type: "listening" or "reading"
    
    Returns:
        Question data with audio_url if listening question
    """
    try:
        # Validate question number range
        if question_type == "listening" and (number < 1 or number > 30):
            raise HTTPException(
                status_code=400,
                detail=f"Listening question number must be between 1 and 30, got {number}"
            )
        elif question_type == "reading" and (number < 1 or number > 40):
            raise HTTPException(
                status_code=400,
                detail=f"Reading question number must be between 1 and 40, got {number}"
            )
        
        question = topik_service.get_topik_question_by_number(exam_number, question_type, number)
        if question is None:
            raise HTTPException(
                status_code=404,
                detail=f"Question number {number} not found in exam {exam_number}"
            )
        
        # Extract audio URL if listening question
        audio_url = None
        if question_type == "listening":
            context = question.get("context", {})
            audio_url = context.get("audio") or question.get("audio_url")
            if audio_url:
                logger.info(f"Question #{number} has audio: {audio_url}")
        
        return {
            "exam_number": exam_number,
            "question_type": question_type,
            "question_number": number,
            "has_audio": question_type == "listening" and audio_url is not None,
            "audio_url": audio_url,  # Audio URL for listening questions (None for reading)
            "question": question
        }
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error getting TOPIK question: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to get question: {str(e)}")


@router.get("/exams/{exam_number}/questions/{question_id}/vocabulary")
async def get_question_vocabulary(
    exam_number: str,
    question_id: str,
    question_type: Literal["listening", "reading"] = Query(..., description="Type of questions"),
    max_words: int = Query(50, ge=1, le=200, description="Maximum number of words to translate")
) -> Dict[str, Any]:
    """
    Get vocabulary from a TOPIK question and translate using dictionary
    
    This endpoint connects TOPIK questions with the dictionary:
    - Extracts Korean words from the question
    - Translates them using the dictionary
    
    Args:
        exam_number: Exam number
        question_id: Question ID
        question_type: Type of questions
        max_words: Maximum number of words to translate
    
    Returns:
        Dictionary with question data and vocabulary translations
    """
    try:
        # Get the question
        question = topik_service.get_topik_question(exam_number, question_type, question_id)
        if question is None:
            raise HTTPException(
                status_code=404,
                detail=f"Question {question_id} not found in exam {exam_number}"
            )
        
        # Extract text from question
        text_parts = []
        
        # Get prompt text
        prompt = question.get("prompt", "")
        if prompt:
            text_parts.append(prompt)
        
        # Get intro text
        intro = question.get("intro_text", "")
        if intro:
            text_parts.append(intro)
        
        # Get answer options text
        answers = question.get("answers", [])
        for answer in answers:
            answer_text = answer.get("text", "")
            if answer_text:
                text_parts.append(answer_text)
        
        # Combine all text
        full_text = " ".join(text_parts)
        
        # Translate using dictionary
        translation_result = dictionary_service.translate_text_with_dictionary(full_text, max_words)
        
        return {
            "exam_number": exam_number,
            "question_type": question_type,
            "question_id": question_id,
            "question": question,
            "vocabulary": translation_result
        }
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error getting question vocabulary: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to get vocabulary: {str(e)}")


@router.get("/stats")
async def get_topik_stats() -> Dict[str, Any]:
    """
    Get statistics about available TOPIK data
    
    Returns:
        Dictionary with statistics
    """
    try:
        stats = topik_service.get_topik_stats()
        return stats
    except Exception as e:
        logger.error(f"Error getting TOPIK stats: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to get stats: {str(e)}")


@router.get("/competition/questions")
async def get_competition_questions(
    count: int = Query(20, ge=1, le=50, description="Number of questions to return"),
    mix_types: bool = Query(True, description="Mix listening and reading questions")
) -> Dict[str, Any]:
    """
    Get random TOPIK questions for competition
    
    This endpoint returns a mix of listening and reading questions from different exams.
    Questions are randomly selected and shuffled.
    
    Args:
        count: Number of questions to return (default: 20, max: 50)
        mix_types: Whether to mix listening and reading questions (default: True)
    
    Returns:
        Dictionary with mixed questions from different exams
    """
    try:
        import random
        
        # Get all available exams
        exams = topik_service.list_available_exams()
        if not exams:
            raise HTTPException(
                status_code=404,
                detail="No TOPIK exams available"
            )
        
        all_questions = []
        
        # Collect questions from all exams
        for exam_number in exams:
            # Get listening questions
            listening_data = topik_service.load_topik_questions(exam_number, "listening")
            listening_questions = listening_data.get("questions", [])
            
            # Get reading questions
            reading_data = topik_service.load_topik_questions(exam_number, "reading")
            reading_questions = reading_data.get("questions", [])
            
            # Add metadata to questions
            for q in listening_questions:
                q["question_type"] = "listening"
                q["exam_number"] = exam_number
                # Extract audio URL
                context = q.get("context", {})
                audio_url = context.get("audio") or q.get("audio_url")
                if audio_url:
                    q["audio_url"] = audio_url
            
            for q in reading_questions:
                q["question_type"] = "reading"
                q["exam_number"] = exam_number
                q["audio_url"] = None
            
            # Add to all questions
            if mix_types:
                all_questions.extend(listening_questions)
                all_questions.extend(reading_questions)
            else:
                # If not mixing, use only listening
                all_questions.extend(listening_questions)
        
        if not all_questions:
            raise HTTPException(
                status_code=404,
                detail="No questions found in available exams"
            )
        
        # Randomly select questions
        selected_questions = random.sample(
            all_questions,
            min(count, len(all_questions))
        )
        
        # Shuffle the selected questions
        random.shuffle(selected_questions)
        
        # Count by type
        listening_count = sum(1 for q in selected_questions if q.get("question_type") == "listening")
        reading_count = sum(1 for q in selected_questions if q.get("question_type") == "reading")
        
        logger.info(f"Returning {len(selected_questions)} competition questions: {listening_count} listening, {reading_count} reading")
        
        return {
            "total": len(selected_questions),
            "listening_count": listening_count,
            "reading_count": reading_count,
            "questions": selected_questions
        }
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error getting competition questions: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to get competition questions: {str(e)}")
