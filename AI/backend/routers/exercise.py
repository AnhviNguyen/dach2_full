"""
Exercise Router - Endpoints for generating exercises using GPT
"""
from fastapi import APIRouter, HTTPException, Query
from typing import List, Dict, Any
import logging
from services import database_service, openai_service
from services.error_handlers import handle_openai_error
from openai import OpenAI
from config import settings

logger = logging.getLogger(__name__)

router = APIRouter(
    prefix="/api/exercise",
    tags=["exercise"]
)

client = OpenAI(api_key=settings.openai_api_key)


@router.get("/generate")
async def generate_exercises(
    book_id: int = Query(..., description="Book number"),
    lesson_id: int = Query(..., description="Lesson number"),
    count: int = Query(5, description="Number of exercises to generate")
) -> Dict[str, Any]:
    """
    Generate exercises for a lesson using GPT
    
    Uses vocabulary and grammar from the lesson to create contextual exercises
    
    Args:
        book_id: Book number
        lesson_id: Lesson number
        count: Number of exercises to generate
        
    Returns:
        List of generated exercises
    """
    try:
        # Get lesson data
        lesson = database_service.get_lesson_by_book_and_lesson_number(book_id, lesson_id)
        if not lesson:
            raise HTTPException(status_code=404, detail="Lesson not found")
        
        lesson_db_id = lesson['id']
        
        # Get vocabulary and grammar for context
        vocab_list = database_service.get_vocabulary_by_lesson(lesson_db_id)
        grammar_list = database_service.get_grammar_by_lesson(lesson_db_id)
        
        # Build context for GPT
        vocab_context = "\n".join([
            f"- {v['korean']} ({v['pronunciation']}): {v['vietnamese']}"
            for v in vocab_list[:10]  # Limit to 10 for context
        ])
        
        grammar_context = "\n".join([
            f"- {g['title']}: {g['explanation']}"
            for g in grammar_list[:5]  # Limit to 5 for context
        ])
        
        # Generate exercises using GPT
        prompt = f"""Bạn là giáo viên tiếng Hàn. Tạo {count} bài tập cho bài học "{lesson['title']}".

Từ vựng trong bài:
{vocab_context}

Ngữ pháp trong bài:
{grammar_context}

Yêu cầu:
1. Tạo các bài tập đa dạng: multiple_choice, fill_blank, reorder
2. Câu hỏi phải liên quan đến từ vựng và ngữ pháp trong bài
3. Mỗi bài tập phải có:
   - type: "multiple_choice" | "fill_blank" | "reorder"
   - question: Câu hỏi bằng tiếng Việt
   - options: Mảng các lựa chọn (cho multiple_choice)
   - correct: Chỉ số đáp án đúng (cho multiple_choice) hoặc đáp án đúng (cho fill_blank)
   - answer: Đáp án đúng (cho fill_blank)

Trả về JSON array với format:
[
  {{
    "type": "multiple_choice",
    "question": "...",
    "options": ["...", "...", "...", "..."],
    "correct": 0,
    "answer": null
  }},
  {{
    "type": "fill_blank",
    "question": "...",
    "options": null,
    "correct": null,
    "answer": "..."
  }}
]

Chỉ trả về JSON, không có text khác."""

        try:
            response = client.chat.completions.create(
                model=settings.openai_model_name,
                messages=[
                    {"role": "system", "content": "Bạn là giáo viên tiếng Hàn chuyên tạo bài tập. Trả về JSON hợp lệ."},
                    {"role": "user", "content": prompt}
                ],
                temperature=0.7,
                max_tokens=2000
            )
            
            import json
            response_text = response.choices[0].message.content.strip()
            
            # Try to extract JSON from response
            if "```json" in response_text:
                response_text = response_text.split("```json")[1].split("```")[0].strip()
            elif "```" in response_text:
                response_text = response_text.split("```")[1].split("```")[0].strip()
            
            exercises = json.loads(response_text)
            
            # Ensure exercises have required fields
            for i, ex in enumerate(exercises):
                ex['id'] = i + 1
                if 'type' not in ex:
                    ex['type'] = 'multiple_choice'
                if 'options' not in ex:
                    ex['options'] = []
                if 'correct' not in ex:
                    ex['correct'] = 0
                if 'answer' not in ex:
                    ex['answer'] = None
            
            logger.info(f"Generated {len(exercises)} exercises for book={book_id}, lesson={lesson_id}")
            
            return {
                'book_id': book_id,
                'lesson_id': lesson_id,
                'lesson_title': lesson['title'],
                'exercises': exercises,
                'total': len(exercises)
            }
            
        except Exception as e:
            logger.error(f"Error generating exercises with GPT: {e}")
            raise HTTPException(
                status_code=500,
                detail=f"Failed to generate exercises: {str(e)}"
            )
            
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error in generate_exercises: {e}")
        raise HTTPException(
            status_code=500,
            detail=f"Failed to generate exercises: {str(e)}"
        )

