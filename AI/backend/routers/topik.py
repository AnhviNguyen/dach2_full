"""
TOPIK Router - Endpoints for TOPIK exam questions
"""
from fastapi import APIRouter, HTTPException, Query
from typing import List, Dict, Any, Optional, Literal
import logging

from services import topik_service, dictionary_service

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
    question_type: Literal["listening", "reading"] = Query(..., description="Type of questions"),
    limit: Optional[int] = Query(None, ge=1, le=100, description="Limit number of questions returned"),
    offset: int = Query(0, ge=0, description="Offset for pagination")
) -> Dict[str, Any]:
    """
    Get TOPIK questions for a specific exam
    
    Args:
        exam_number: Exam number (e.g., "35", "36", "37")
        question_type: Type of questions ("listening" or "reading")
        limit: Maximum number of questions to return
        offset: Offset for pagination
    
    Returns:
        Dictionary with questions data
    """
    try:
        data = topik_service.load_topik_questions(exam_number, question_type)
        
        if "error" in data:
            raise HTTPException(status_code=404, detail=data["error"])
        
        questions = data.get("questions", [])
        total = len(questions)
        
        # Apply pagination
        if limit is not None:
            questions = questions[offset:offset + limit]
        else:
            questions = questions[offset:]
        
        return {
            "exam_number": exam_number,
            "question_type": question_type,
            "questions": questions,
            "total": total,
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
    question_type: Literal["listening", "reading"] = Query(..., description="Type of questions")
) -> Dict[str, Any]:
    """
    Get a specific TOPIK question by ID
    
    Args:
        exam_number: Exam number
        question_id: Question ID
        question_type: Type of questions
    
    Returns:
        Question data
    """
    try:
        question = topik_service.get_topik_question(exam_number, question_type, question_id)
        if question is None:
            raise HTTPException(
                status_code=404,
                detail=f"Question {question_id} not found in exam {exam_number}"
            )
        
        return {
            "exam_number": exam_number,
            "question_type": question_type,
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
    question_type: Literal["listening", "reading"] = Query(..., description="Type of questions")
) -> Dict[str, Any]:
    """
    Get a specific TOPIK question by question number
    
    Args:
        exam_number: Exam number
        number: Question number (1-indexed)
        question_type: Type of questions
    
    Returns:
        Question data
    """
    try:
        question = topik_service.get_topik_question_by_number(exam_number, question_type, number)
        if question is None:
            raise HTTPException(
                status_code=404,
                detail=f"Question number {number} not found in exam {exam_number}"
            )
        
        return {
            "exam_number": exam_number,
            "question_type": question_type,
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

