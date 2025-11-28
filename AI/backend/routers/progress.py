"""
Progress Router - Endpoints for saving lesson progress
"""
from fastapi import APIRouter, HTTPException, Query
from typing import Dict, Any
import logging
from services import database_service

logger = logging.getLogger(__name__)

router = APIRouter(
    prefix="/api/progress",
    tags=["progress"]
)


@router.post("/save")
async def save_progress(
    user_id: int = Query(..., description="User ID"),
    book_id: int = Query(..., description="Book number"),
    lesson_id: int = Query(..., description="Lesson number"),
    completed: bool = Query(True, description="Whether lesson is completed")
) -> Dict[str, Any]:
    """
    Save lesson progress for a user
    
    Args:
        user_id: User ID
        book_id: Book number
        lesson_id: Lesson number
        completed: Whether the lesson is completed
        
    Returns:
        Success status
    """
    try:
        success = database_service.save_lesson_progress(
            user_id=user_id,
            book_id=book_id,
            lesson_id=lesson_id,
            completed=completed
        )
        
        if success:
            return {
                'success': True,
                'message': 'Progress saved successfully',
                'user_id': user_id,
                'book_id': book_id,
                'lesson_id': lesson_id,
                'completed': completed
            }
        else:
            raise HTTPException(
                status_code=500,
                detail="Failed to save progress"
            )
            
    except Exception as e:
        logger.error(f"Error saving progress: {e}")
        raise HTTPException(
            status_code=500,
            detail=f"Failed to save progress: {str(e)}"
        )

