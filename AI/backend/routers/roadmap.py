"""
Roadmap Router - Endpoints for roadmap feature
"""
from fastapi import APIRouter, HTTPException, Query
from typing import List, Dict, Any, Optional
import logging
import random

from services import openai_service, topik_service

logger = logging.getLogger(__name__)

router = APIRouter(
    prefix="/api/roadmap",
    tags=["roadmap"]
)


@router.post("/survey")
async def submit_survey(data: Dict[str, Any]) -> Dict[str, Any]:
    """
    Submit survey answers
    
    Args:
        data: {
            "user_id": int,
            "has_learned_korean": bool,
            "learning_reason": str,
            "self_assessed_level": int (1-6)
        }
    
    Returns:
        Success message
    """
    try:
        # Store survey data (in production, save to database)
        logger.info(f"Survey submitted for user {data.get('user_id')}")
        return {
            "success": True,
            "message": "Survey submitted successfully"
        }
    except Exception as e:
        logger.error(f"Error submitting survey: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to submit survey: {str(e)}")


@router.get("/placement/questions")
async def get_placement_questions(
    count: int = Query(8, ge=1, le=20, description="Number of questions to return")
) -> Dict[str, Any]:
    """
    Generate placement test questions using GPT
    GPT will generate questions to assess Korean language level
    
    Args:
        count: Number of questions (default: 8, max: 20)
    
    Returns:
        Dictionary with GPT-generated questions
    """
    try:
        # GPT prompt to generate placement test questions
        gpt_prompt = f"""Bạn là một giáo viên tiếng Hàn chuyên nghiệp. Hãy tạo CHÍNH XÁC {count} câu hỏi KHÁC NHAU để đánh giá trình độ tiếng Hàn của người học (từ cấp độ 1 đến 6).

YÊU CẦU QUAN TRỌNG:
1. Tạo ĐÚNG {count} câu hỏi, KHÔNG được ít hơn
2. Mỗi câu hỏi phải HOÀN TOÀN KHÁC NHAU về nội dung, không được lặp lại
3. Đa dạng về chủ đề: chào hỏi, số đếm, gia đình, thời gian, địa điểm, màu sắc, thức ăn, động từ, tính từ, ngữ pháp cơ bản, v.v.
4. Đa dạng về loại: ngữ pháp, từ vựng, đọc hiểu, điền từ
5. Độ khó từ dễ (1-2) đến khó (5-6) để đánh giá được nhiều cấp độ
6. Mỗi câu hỏi có 4 lựa chọn (A, B, C, D)
7. Chỉ có 1 đáp án đúng duy nhất
8. Đáp án đúng phải phân bố đều (không phải tất cả đều là A)

Ví dụ các loại câu hỏi cần có:
- Câu hỏi từ vựng cơ bản (안녕하세요, 감사합니다, v.v.)
- Câu hỏi ngữ pháp (이/가, 을/를, 은/는, v.v.)
- Câu hỏi số đếm (하나, 둘, 셋, v.v.)
- Câu hỏi thời gian (지금, 오늘, 내일, v.v.)
- Câu hỏi đọc hiểu ngắn
- Câu hỏi điền từ vào chỗ trống

Trả lời theo format JSON:
{{
    "questions": [
        {{
            "id": "q1",
            "question": "<câu hỏi bằng tiếng Hàn hoặc tiếng Việt, PHẢI KHÁC NHAU>",
            "options": [
                {{"value": "A", "text": "<lựa chọn A>"}},
                {{"value": "B", "text": "<lựa chọn B>"}},
                {{"value": "C", "text": "<lựa chọn C>"}},
                {{"value": "D", "text": "<lựa chọn D>"}}
            ],
            "correct_answer": "A",
            "difficulty": "1",
            "type": "vocabulary"
        }},
        {{
            "id": "q2",
            "question": "<câu hỏi HOÀN TOÀN KHÁC, không lặp lại câu 1>",
            "options": [
                {{"value": "A", "text": "<lựa chọn A>"}},
                {{"value": "B", "text": "<lựa chọn B>"}},
                {{"value": "C", "text": "<lựa chọn C>"}},
                {{"value": "D", "text": "<lựa chọn D>"}}
            ],
            "correct_answer": "B",
            "difficulty": "2",
            "type": "grammar"
        }}
        ... (tiếp tục cho đến q{count})
    ]
}}

QUAN TRỌNG: Phải tạo ĐÚNG {count} câu hỏi, mỗi câu phải KHÁC NHAU hoàn toàn. Chỉ trả về JSON, không có text thêm."""

        # Call GPT to generate questions
        # Add system message to ensure diversity
        system_message = "Bạn là một giáo viên tiếng Hàn chuyên nghiệp. Bạn phải tạo câu hỏi đa dạng, không lặp lại. Mỗi câu hỏi phải về chủ đề khác nhau."
        full_prompt = f"{system_message}\n\n{gpt_prompt}"
        
        gpt_response = openai_service.chat_with_coach_ivy(
            user_message=full_prompt,
            conversation_history=[],
            use_system_prompt=False
        )
        
        # Parse GPT response
        import json
        import re
        
        # Extract JSON from response
        json_match = re.search(r'\{.*\}', gpt_response, re.DOTALL)
        if json_match:
            gpt_result = json.loads(json_match.group())
            questions = gpt_result.get("questions", [])
        else:
            # Fallback: create simple questions
            questions = _generate_fallback_questions(count)
        
        # Ensure we have the right number of questions
        if len(questions) > count:
            questions = questions[:count]
        elif len(questions) < count:
            # Add fallback questions if needed
            fallback = _generate_fallback_questions(count - len(questions))
            questions.extend(fallback)
        
        logger.info(f"Generated {len(questions)} placement questions using GPT")
        
        return {
            "total": len(questions),
            "questions": questions
        }
    except Exception as e:
        logger.error(f"Error generating placement questions: {e}")
        # Fallback to simple questions
        questions = _generate_fallback_questions(count)
        return {
            "total": len(questions),
            "questions": questions
        }


def _generate_fallback_questions(count: int) -> List[Dict[str, Any]]:
    """Generate simple fallback questions if GPT fails"""
    fallback_questions = [
        {
            "id": "q1",
            "question": "안녕하세요 có nghĩa là gì?",
            "options": [
                {"value": "A", "text": "Xin chào"},
                {"value": "B", "text": "Cảm ơn"},
                {"value": "C", "text": "Xin lỗi"},
                {"value": "D", "text": "Tạm biệt"}
            ],
            "correct_answer": "A",
            "difficulty": "1",
            "type": "vocabulary"
        },
        {
            "id": "q2",
            "question": "저는 학생___입니다. (Tôi là học sinh)",
            "options": [
                {"value": "A", "text": "이"},
                {"value": "B", "text": "을"},
                {"value": "C", "text": "을/를"},
                {"value": "D", "text": "입니다"}
            ],
            "correct_answer": "A",
            "difficulty": "1",
            "type": "grammar"
        },
    ]
    
    # Repeat questions if needed
    result = []
    for i in range(count):
        q = fallback_questions[i % len(fallback_questions)].copy()
        q["id"] = f"q{i+1}"
        result.append(q)
    
    return result


@router.post("/placement/evaluate")
async def evaluate_placement_test(data: Dict[str, Any]) -> Dict[str, Any]:
    """
    Evaluate placement test answers and determine user level using GPT
    GPT will analyze answers and determine the appropriate level
    
    Args:
        data: {
            "user_id": int,
            "survey_data": {
                "hasLearnedKorean": bool,
                "learningReason": str,
                "selfAssessedLevel": int
            },
            "answers": [
                {
                    "question_id": str,
                    "question": str,
                    "user_answer": str,
                    "correct_answer": str,
                    "is_correct": bool,
                    "difficulty": str,
                    "type": str
                }
            ],
            "questions": [
                {
                    "id": str,
                    "question": str,
                    "options": [...],
                    "correct_answer": str,
                    "difficulty": str,
                    "type": str
                }
            ]
        }
    
    Returns:
        {
            "level": int (1-6),
            "score": float,
            "correct_answers": int,
            "total_questions": int,
            "reasoning": str,
            "recommendation": str,
            "textbook_unlock": int (book number to unlock)
        }
    """
    try:
        user_id = data.get("user_id")
        survey_data = data.get("survey_data", {})
        answers = data.get("answers", [])
        questions = data.get("questions", [])
        
        if not answers:
            raise HTTPException(status_code=400, detail="No answers provided")
        
        # Calculate basic score
        total_questions = len(answers)
        correct_answers = sum(1 for a in answers if a.get("is_correct", False))
        score = (correct_answers / total_questions * 100) if total_questions > 0 else 0
        
        # Prepare detailed context for GPT evaluation
        # Build question-answer pairs
        qa_pairs = []
        for i, answer in enumerate(answers):
            question_id = answer.get("question_id", f"q{i+1}")
            # Find corresponding question
            question = next((q for q in questions if q.get("id") == question_id), {})
            
            qa_pairs.append({
                "question": question.get("question", answer.get("question", "")),
                "user_answer": answer.get("user_answer", ""),
                "correct_answer": answer.get("correct_answer", ""),
                "is_correct": answer.get("is_correct", False),
                "difficulty": answer.get("difficulty", question.get("difficulty", "1")),
                "type": answer.get("type", question.get("type", "general"))
            })
        
        # Prepare context for GPT
        survey_info = f"""
        Thông tin khảo sát:
        - Đã học tiếng Hàn: {survey_data.get('hasLearnedKorean', False)}
        - Lý do học: {survey_data.get('learningReason', 'N/A')}
        - Tự đánh giá cấp độ: {survey_data.get('selfAssessedLevel', 1)}
        """
        
        # Analyze by difficulty and type
        difficulty_stats = {}
        type_stats = {}
        for qa in qa_pairs:
            diff = qa.get("difficulty", "1")
            qtype = qa.get("type", "general")
            is_correct = qa.get("is_correct", False)
            
            if diff not in difficulty_stats:
                difficulty_stats[diff] = {"correct": 0, "total": 0}
            difficulty_stats[diff]["total"] += 1
            if is_correct:
                difficulty_stats[diff]["correct"] += 1
            
            if qtype not in type_stats:
                type_stats[qtype] = {"correct": 0, "total": 0}
            type_stats[qtype]["total"] += 1
            if is_correct:
                type_stats[qtype]["correct"] += 1
        
        # Build detailed analysis
        analysis = f"""
        Kết quả bài kiểm tra:
        - Tổng số câu: {total_questions}
        - Số câu đúng: {correct_answers}
        - Điểm số: {score:.1f}%
        
        Phân tích theo độ khó:
        """
        for diff in sorted(difficulty_stats.keys()):
            stats = difficulty_stats[diff]
            analysis += f"\n- Cấp độ {diff}: {stats['correct']}/{stats['total']} câu đúng"
        
        analysis += "\n\nPhân tích theo loại câu hỏi:"
        for qtype in type_stats.keys():
            stats = type_stats[qtype]
            analysis += f"\n- {qtype}: {stats['correct']}/{stats['total']} câu đúng"
        
        # Build question-answer details for GPT
        qa_details = "\n\nChi tiết câu hỏi và câu trả lời:\n"
        for i, qa in enumerate(qa_pairs[:10], 1):  # Limit to first 10 for token efficiency
            qa_details += f"""
Câu {i}:
- Câu hỏi: {qa.get('question', '')}
- Đáp án đúng: {qa.get('correct_answer', '')}
- Người học chọn: {qa.get('user_answer', '')}
- Kết quả: {'Đúng' if qa.get('is_correct') else 'Sai'}
- Độ khó: {qa.get('difficulty', '1')}
- Loại: {qa.get('type', 'general')}
"""
        
        # GPT prompt for comprehensive level evaluation
        gpt_prompt = f"""Bạn là một chuyên gia đánh giá trình độ tiếng Hàn với nhiều năm kinh nghiệm. Hãy phân tích kỹ lưỡng kết quả bài kiểm tra và đánh giá cấp độ của người học (1-6).

{survey_info}

{analysis}

{qa_details}

Hãy đánh giá cấp độ người học dựa trên:
1. Tỷ lệ câu trả lời đúng tổng thể
2. Khả năng trả lời đúng các câu hỏi ở các độ khó khác nhau
3. Điểm mạnh/yếu ở các loại câu hỏi (ngữ pháp, từ vựng, đọc hiểu)
4. Thông tin khảo sát (tham khảo)

Trả lời theo format JSON:
{{
    "level": <số từ 1-6, phải là số nguyên>,
    "reasoning": "<phân tích chi tiết lý do đánh giá cấp độ này, ít nhất 2-3 câu>",
    "recommendation": "<lời khuyên học tập cụ thể dựa trên điểm mạnh/yếu, ít nhất 2-3 câu>",
    "strengths": ["<điểm mạnh 1>", "<điểm mạnh 2>"],
    "weaknesses": ["<điểm yếu 1>", "<điểm yếu 2>"]
}}

QUAN TRỌNG: 
- "level" phải là số nguyên từ 1 đến 6
- Phân tích phải chi tiết và chính xác
- Chỉ trả về JSON, không có text thêm hay markdown formatting"""

        # Call GPT
        try:
            gpt_response = openai_service.chat_with_coach_ivy(
                user_message=gpt_prompt,
                conversation_history=[],
                use_system_prompt=False
            )
            
            # Parse GPT response
            import json
            import re
            
            # Extract JSON from response (handle markdown code blocks)
            json_match = re.search(r'```json\s*(\{.*?\})\s*```', gpt_response, re.DOTALL)
            if not json_match:
                json_match = re.search(r'\{.*\}', gpt_response, re.DOTALL)
            
            if json_match:
                json_str = json_match.group(1) if json_match.groups() else json_match.group()
                gpt_result = json.loads(json_str)
                evaluated_level = gpt_result.get("level", 1)
                
                # Ensure level is integer and in range
                if isinstance(evaluated_level, str):
                    evaluated_level = int(evaluated_level) if evaluated_level.isdigit() else 1
                evaluated_level = max(1, min(6, int(evaluated_level)))
                
                reasoning = gpt_result.get("reasoning", "")
                recommendation = gpt_result.get("recommendation", "")
            else:
                # Fallback: determine level based on score
                evaluated_level = _determine_level_by_score(score, survey_data.get("selfAssessedLevel", 1))
                reasoning = f"Dựa trên điểm số {score:.1f}%"
                recommendation = "Hãy tiếp tục luyện tập để cải thiện trình độ"
        except Exception as e:
            logger.warning(f"GPT evaluation failed: {e}, using score-based evaluation")
            evaluated_level = _determine_level_by_score(score, survey_data.get("selfAssessedLevel", 1))
            reasoning = f"Dựa trên điểm số {score:.1f}%"
            recommendation = "Hãy tiếp tục luyện tập để cải thiện trình độ"
        
        # Ensure level is between 1-6
        evaluated_level = max(1, min(6, int(evaluated_level)))
        
        # Determine textbook unlock (unlock all books up to level-1)
        textbook_unlock = max(0, evaluated_level - 1)
        
        logger.info(f"User {user_id} evaluated at level {evaluated_level}, score: {score:.1f}%")
        
        return {
            "level": evaluated_level,
            "score": round(score, 1),
            "correct_answers": correct_answers,
            "total_questions": total_questions,
            "reasoning": reasoning,
            "recommendation": recommendation,
            "textbook_unlock": textbook_unlock,
        }
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error evaluating placement test: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to evaluate placement test: {str(e)}")


def _determine_level_by_score(score: float, self_assessed: int) -> int:
    """Determine level based on score and self-assessment"""
    if score >= 90:
        return min(6, max(4, self_assessed))
    elif score >= 75:
        return min(5, max(3, self_assessed))
    elif score >= 60:
        return min(4, max(2, self_assessed))
    elif score >= 40:
        return min(3, max(1, self_assessed))
    else:
        return 1


@router.get("/tasks")
async def get_roadmap_tasks(
    user_id: int = Query(..., description="User ID")
) -> Dict[str, Any]:
    """
    Get roadmap tasks based on user level
    
    Args:
        user_id: User ID
    
    Returns:
        Dictionary with tasks organized by categories
    """
    try:
        # In production, get user level from database
        # For now, return default tasks structure
        tasks = _generate_roadmap_tasks(level=1)  # Default level 1
        
        return {
            "user_id": user_id,
            "level": 1,  # Get from database
            "tasks": tasks,
            "total_tasks": sum(len(cat["tasks"]) for cat in tasks),
            "completed_tasks": 0,  # Get from database
        }
    except Exception as e:
        logger.error(f"Error getting roadmap tasks: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to get roadmap tasks: {str(e)}")


def _generate_roadmap_tasks(level: int) -> List[Dict[str, Any]]:
    """Generate roadmap tasks based on level"""
    # Tasks based on available features in the app
    base_tasks = [
        {
            "category": "Giáo trình",
            "icon": "book",
            "tasks": [
                {
                    "id": "textbook_learn",
                    "title": "Học bài trong giáo trình",
                    "description": "Hoàn thành ít nhất 1 bài học trong giáo trình",
                    "type": "textbook_learn",
                    "target": 1,
                    "current": 0,
                },
                {
                    "id": "textbook_vocab",
                    "title": "Học từ vựng",
                    "description": "Hoàn thành phần từ vựng của bài học",
                    "type": "textbook_vocab",
                    "target": 1,
                    "current": 0,
                },
                {
                    "id": "textbook_grammar",
                    "title": "Học ngữ pháp",
                    "description": "Xem và học ngữ pháp của bài học",
                    "type": "textbook_grammar",
                    "target": 1,
                    "current": 0,
                },
                {
                    "id": "textbook_exercise",
                    "title": "Làm bài tập",
                    "description": "Hoàn thành bài tập và đạt điểm >= 80%",
                    "type": "textbook_exercise",
                    "target": 1,
                    "current": 0,
                },
            ]
        },
        {
            "category": "Luyện thi TOPIK",
            "icon": "quiz",
            "tasks": [
                {
                    "id": "topik_practice",
                    "title": "Luyện đề TOPIK",
                    "description": "Hoàn thành 1 đề thi TOPIK",
                    "type": "topik_practice",
                    "target": 1,
                    "current": 0,
                },
            ]
        },
        {
            "category": "Luyện nói",
            "icon": "mic",
            "tasks": [
                {
                    "id": "speak_practice",
                    "title": "Luyện phát âm",
                    "description": "Hoàn thành 1 bài luyện phát âm",
                    "type": "speak_practice",
                    "target": 1,
                    "current": 0,
                },
            ]
        },
    ]
    
    # Adjust tasks based on level
    if level >= 2:
        base_tasks[0]["tasks"].append({
            "id": "textbook_chat",
            "title": "Chat với AI",
            "description": "Sử dụng tính năng Chat AI trong bài học",
            "type": "textbook_chat",
            "target": 1,
            "current": 0,
        })
    
    return base_tasks


@router.post("/tasks/update")
async def update_task_status(data: Dict[str, Any]) -> Dict[str, Any]:
    """
    Update task completion status
    
    Args:
        data: {
            "user_id": int,
            "task_id": str,
            "completed": bool
        }
    
    Returns:
        Success message
    """
    try:
        # In production, update database
        logger.info(f"Task {data.get('task_id')} updated for user {data.get('user_id')}")
        return {
            "success": True,
            "message": "Task status updated"
        }
    except Exception as e:
        logger.error(f"Error updating task status: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to update task status: {str(e)}")


@router.get("/user/{user_id}")
async def get_user_roadmap(user_id: int) -> Dict[str, Any]:
    """
    Get user roadmap level and progress
    
    Args:
        user_id: User ID
    
    Returns:
        Dictionary with user roadmap information
    """
    try:
        # In production, get from database
        return {
            "user_id": user_id,
            "level": 1,  # Get from database
            "textbook_unlock": 0,  # Get from database
            "completed_tasks": 0,  # Get from database
            "total_tasks": 0,  # Get from database
            "progress": 0.0,  # Get from database
        }
    except Exception as e:
        logger.error(f"Error getting user roadmap: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to get user roadmap: {str(e)}")

