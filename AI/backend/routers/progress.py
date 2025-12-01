"""
Progress Router - Endpoints for saving lesson progress and daily tasks
"""
from fastapi import APIRouter, HTTPException, Query
from typing import Dict, Any, Optional
import logging
from datetime import datetime, date
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
        
        # Auto-update task progress if lesson is completed
        if success and completed:
            try:
                # Update roadmap task if user has roadmap
                roadmap_progress = database_service.get_roadmap_progress(user_id)
                if roadmap_progress:
                    roadmap_id = roadmap_progress['roadmap_id']
                    roadmap_data = roadmap_progress.get('roadmap_data', {})
                    
                    # Find matching tasks in roadmap
                    for period in roadmap_data.get('periods', []):
                        for task in period.get('tasks', []):
                            if task.get('type') == "textbook_learn":
                                task_id = task.get('id')
                                if task_id:
                                    # Get current progress from database
                                    task_progress_list = database_service.get_roadmap_task_progress(user_id, roadmap_id)
                                    existing_progress = next(
                                        (t for t in task_progress_list if t.get('task_id') == task_id),
                                        None
                                    )
                                    
                                    if existing_progress:
                                        current = existing_progress.get('current', 0)
                                    else:
                                        current = task.get('current', 0)
                                    
                                    target = task.get('target', 1)
                                    new_current = min(current + 1, target)
                                    completed_task = new_current >= target
                                    
                                    database_service.save_roadmap_task_progress(
                                        user_id=user_id,
                                        roadmap_id=roadmap_id,
                                        task_id=task_id,
                                        task_type="textbook_learn",
                                        task_title=task.get('title', ''),
                                        task_description=task.get('description', ''),
                                        target=target,
                                        current=new_current,
                                        completed=completed_task
                                    )
                                    logger.info(f"Auto-updated roadmap task {task_id} for user {user_id}: {new_current}/{target}")
            except Exception as e:
                logger.warning(f"Failed to auto-update task progress: {e}")
        
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


@router.post("/task/complete")
async def complete_task(data: Dict[str, Any]) -> Dict[str, Any]:
    """
    Mark a task as completed and update progress
    
    This endpoint is called when user completes an activity:
    - textbook_learn: When user completes a lesson
    - topik_practice: When user completes a TOPIK exam
    - vocab_flashcard: When user completes vocabulary learning
    - speak_practice: When user completes speaking practice
    - etc.
    
    Args:
        data: {
            "user_id": int,
            "task_type": str,  # textbook_learn, topik_practice, vocab_flashcard, etc.
            "task_data": Optional[Dict]  # Additional data (book_id, lesson_id, exam_id, etc.)
        }
    
    Returns:
        Success status and updated task progress
    """
    try:
        user_id = data.get("user_id")
        task_type = data.get("task_type")
        task_data = data.get("task_data", {})
        
        if not user_id or not task_type:
            raise HTTPException(
                status_code=400,
                detail="user_id and task_type are required"
            )
        
        # Update roadmap task if user has roadmap
        roadmap_progress = database_service.get_roadmap_progress(user_id)
        updated_tasks = []
        
        if roadmap_progress:
            roadmap_id = roadmap_progress['roadmap_id']
            roadmap_data = roadmap_progress.get('roadmap_data', {})
            
            # Find matching tasks in roadmap (có thể có nhiều task cùng type)
            for period in roadmap_data.get('periods', []):
                for task in period.get('tasks', []):
                    if task.get('type') == task_type:
                        task_id = task.get('id')
                        if task_id:
                            # Get current progress from database
                            task_progress_list = database_service.get_roadmap_task_progress(user_id, roadmap_id)
                            existing_progress = next(
                                (t for t in task_progress_list if t.get('task_id') == task_id),
                                None
                            )
                            
                            if existing_progress:
                                current = existing_progress.get('current', 0)
                            else:
                                current = task.get('current', 0)
                            
                            target = task.get('target', 1)
                            new_current = min(current + 1, target)
                            completed = new_current >= target
                            
                            database_service.save_roadmap_task_progress(
                                user_id=user_id,
                                roadmap_id=roadmap_id,
                                task_id=task_id,
                                task_type=task_type,
                                task_title=task.get('title', ''),
                                task_description=task.get('description', ''),
                                target=target,
                                current=new_current,
                                completed=completed
                            )
                            updated_tasks.append({
                                'task_id': task_id,
                                'current': new_current,
                                'target': target,
                                'completed': completed
                            })
                            logger.info(f"Updated roadmap task {task_id} for user {user_id}: {new_current}/{target}")
        
        return {
            'success': True,
            'message': 'Task progress updated',
            'task_type': task_type,
            'user_id': user_id,
            'updated_tasks': updated_tasks
        }
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error completing task: {e}")
        raise HTTPException(
            status_code=500,
            detail=f"Failed to complete task: {str(e)}"
        )

