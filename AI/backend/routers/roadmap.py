"""
Roadmap Router - Endpoints for roadmap feature
"""
from fastapi import APIRouter, HTTPException, Query
from typing import List, Dict, Any, Optional
import logging
import math
import random

from services import openai_service, topik_service, database_service

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
        gpt_prompt = f"""Bạn là một giáo viên tiếng Hàn chuyên nghiệp. Hãy tạo CHÍNH XÁC {count} câu hỏi HOÀN TOÀN KHÁC NHAU để đánh giá trình độ tiếng Hàn của người học (từ cấp độ 1 đến 6).

YÊU CẦU BẮT BUỘC:
1. Tạo ĐÚNG {count} câu hỏi, KHÔNG được ít hơn
2. MỖI CÂU HỎI PHẢI HOÀN TOÀN KHÁC NHAU - không được lặp lại nội dung, từ vựng, hoặc cấu trúc
3. Đa dạng về chủ đề: chào hỏi, số đếm, gia đình, thời gian, địa điểm, màu sắc, thức ăn, động từ, tính từ, ngữ pháp, v.v.
4. Đa dạng về loại: vocabulary, grammar, reading, listening, fill_blank
5. Độ khó từ dễ (1-2) đến khó (5-6) để đánh giá được nhiều cấp độ
6. Mỗi câu hỏi có 4 lựa chọn (A, B, C, D)
7. Chỉ có 1 đáp án đúng duy nhất
8. Đáp án đúng phải phân bố đều (A, B, C, D đều có)

DANH SÁCH CHỦ ĐỀ CẦN CÓ (mỗi câu hỏi về 1 chủ đề khác nhau):
- Chào hỏi cơ bản (안녕하세요, 안녕히 가세요)
- Cảm ơn/xin lỗi (감사합니다, 죄송합니다)
- Số đếm (하나, 둘, 셋, 일, 이, 삼)
- Gia đình (아버지, 어머니, 형, 누나)
- Thời gian (지금, 오늘, 내일, 어제)
- Địa điểm (학교, 집, 병원, 식당)
- Màu sắc (빨간색, 파란색, 노란색)
- Thức ăn (밥, 물, 빵, 과일)
- Động từ (가다, 오다, 먹다, 보다)
- Tính từ (좋다, 크다, 작다, 예쁘다)
- Ngữ pháp 이/가, 은/는, 을/를, 에/에서
- Câu hỏi đọc hiểu ngắn
- Câu điền từ vào chỗ trống

VÍ DỤ CÁC CÂU HỎI KHÁC NHAU (KHÔNG ĐƯỢC LẶP LẠI):
q1: "안녕하세요 có nghĩa là gì?" (vocabulary - chào hỏi)
q2: "저는 학생___입니다." (grammar - 이/가)
q3: "하나, 둘, 셋 có nghĩa là gì?" (vocabulary - số đếm)
q4: "오늘 날씨가 좋습니다. '오늘' có nghĩa là gì?" (vocabulary - thời gian)
q5: "저는 학교___갑니다." (grammar - 에/에서)
q6: "빨간색 có nghĩa là gì?" (vocabulary - màu sắc)
q7: "저는 밥을 먹습니다. '먹습니다' có nghĩa là gì?" (vocabulary - động từ)
q8: "그는 키가 큽니다. '큽니다' có nghĩa là gì?" (vocabulary - tính từ)

Trả lời theo format JSON (KHÔNG ĐƯỢC LẶP LẠI CÂU HỎI):
{{
    "questions": [
        {{
            "id": "q1",
            "question": "<câu hỏi 1 - về chủ đề 1, HOÀN TOÀN KHÁC>",
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
            "question": "<câu hỏi 2 - về chủ đề 2, HOÀN TOÀN KHÁC câu 1>",
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
        ... (tiếp tục cho đến q{count}, MỖI CÂU PHẢI KHÁC NHAU)
    ]
}}

QUAN TRỌNG: 
- Phải tạo ĐÚNG {count} câu hỏi
- MỖI CÂU HỎI PHẢI HOÀN TOÀN KHÁC NHAU - không được lặp lại nội dung
- Mỗi câu về 1 chủ đề khác nhau
- Chỉ trả về JSON, không có text thêm."""

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
        
        # Extract JSON from response (handle markdown code blocks)
        json_match = re.search(r'```json\s*(\{.*?\})\s*```', gpt_response, re.DOTALL)
        if not json_match:
            json_match = re.search(r'\{.*\}', gpt_response, re.DOTALL)
        
        if json_match:
            try:
                json_str = json_match.group(1) if json_match.groups() else json_match.group()
                gpt_result = json.loads(json_str)
                questions = gpt_result.get("questions", [])
                logger.info(f"Successfully parsed {len(questions)} questions from GPT response")
            except json.JSONDecodeError as e:
                logger.warning(f"Failed to parse JSON from GPT response: {e}")
                logger.debug(f"GPT response: {gpt_response[:500]}")
                questions = _generate_fallback_questions(count)
        else:
            logger.warning("No JSON found in GPT response, using fallback")
            logger.debug(f"GPT response: {gpt_response[:500]}")
            # Fallback: create simple questions
            questions = _generate_fallback_questions(count)
        
        # Remove duplicate questions based on question text
        seen_questions = set()
        unique_questions = []
        for q in questions:
            question_text = q.get("question", "").strip().lower()
            if question_text and question_text not in seen_questions:
                seen_questions.add(question_text)
                unique_questions.append(q)
        
        questions = unique_questions
        
        # Ensure we have the right number of questions
        if len(questions) > count:
            questions = questions[:count]
        elif len(questions) < count:
            # Add fallback questions if needed (avoid duplicates)
            existing_texts = {q.get("question", "").strip().lower() for q in questions}
            fallback = _generate_fallback_questions(count - len(questions), existing_texts)
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


def _generate_fallback_questions(count: int, existing_texts: set = None) -> List[Dict[str, Any]]:
    """Generate simple fallback questions if GPT fails"""
    if existing_texts is None:
        existing_texts = set()
    
    # Expanded list of diverse fallback questions
    all_fallback_questions = [
        {
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
        {
            "question": "감사합니다 có nghĩa là gì?",
            "options": [
                {"value": "A", "text": "Xin chào"},
                {"value": "B", "text": "Cảm ơn"},
                {"value": "C", "text": "Xin lỗi"},
                {"value": "D", "text": "Tạm biệt"}
            ],
            "correct_answer": "B",
            "difficulty": "1",
            "type": "vocabulary"
        },
        {
            "question": "하나, 둘, 셋 có nghĩa là gì?",
            "options": [
                {"value": "A", "text": "Một, hai, ba"},
                {"value": "B", "text": "Bốn, năm, sáu"},
                {"value": "C", "text": "Bảy, tám, chín"},
                {"value": "D", "text": "Mười, mười một, mười hai"}
            ],
            "correct_answer": "A",
            "difficulty": "1",
            "type": "vocabulary"
        },
        {
            "question": "오늘 có nghĩa là gì?",
            "options": [
                {"value": "A", "text": "Hôm qua"},
                {"value": "B", "text": "Hôm nay"},
                {"value": "C", "text": "Ngày mai"},
                {"value": "D", "text": "Bây giờ"}
            ],
            "correct_answer": "B",
            "difficulty": "1",
            "type": "vocabulary"
        },
        {
            "question": "저는 학교___갑니다. (Tôi đi đến trường)",
            "options": [
                {"value": "A", "text": "에"},
                {"value": "B", "text": "에서"},
                {"value": "C", "text": "을"},
                {"value": "D", "text": "이"}
            ],
            "correct_answer": "A",
            "difficulty": "2",
            "type": "grammar"
        },
        {
            "question": "빨간색 có nghĩa là gì?",
            "options": [
                {"value": "A", "text": "Màu đỏ"},
                {"value": "B", "text": "Màu xanh"},
                {"value": "C", "text": "Màu vàng"},
                {"value": "D", "text": "Màu trắng"}
            ],
            "correct_answer": "A",
            "difficulty": "1",
            "type": "vocabulary"
        },
        {
            "question": "저는 밥을 먹습니다. '먹습니다' có nghĩa là gì?",
            "options": [
                {"value": "A", "text": "Ăn"},
                {"value": "B", "text": "Uống"},
                {"value": "C", "text": "Ngủ"},
                {"value": "D", "text": "Đi"}
            ],
            "correct_answer": "A",
            "difficulty": "1",
            "type": "vocabulary"
        },
        {
            "question": "아버지 có nghĩa là gì?",
            "options": [
                {"value": "A", "text": "Bố"},
                {"value": "B", "text": "Mẹ"},
                {"value": "C", "text": "Anh trai"},
                {"value": "D", "text": "Chị gái"}
            ],
            "correct_answer": "A",
            "difficulty": "1",
            "type": "vocabulary"
        },
        {
            "question": "저는 물을 마십니다. '마십니다' có nghĩa là gì?",
            "options": [
                {"value": "A", "text": "Ăn"},
                {"value": "B", "text": "Uống"},
                {"value": "C", "text": "Mua"},
                {"value": "D", "text": "Xem"}
            ],
            "correct_answer": "B",
            "difficulty": "1",
            "type": "vocabulary"
        },
    ]
    
    # Filter out questions that already exist
    available_questions = [
        q for q in all_fallback_questions 
        if q["question"].strip().lower() not in existing_texts
    ]
    
    # If we don't have enough unique questions, use what we have
    if len(available_questions) < count:
        available_questions = all_fallback_questions
    
    # Select questions (avoid duplicates)
    result = []
    used_indices = set()
    for i in range(count):
        if i < len(available_questions):
            idx = i
        else:
            # Cycle through available questions if needed
            idx = i % len(available_questions)
            if idx in used_indices and len(available_questions) > 1:
                # Try to find a different question
                for j in range(len(available_questions)):
                    if j not in used_indices:
                        idx = j
                        break
        
        q = available_questions[idx].copy()
        q["id"] = f"q{len(result) + 1}"
        result.append(q)
        used_indices.add(idx)
    
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
        
        # Determine textbook unlock: unlock all books from 1 to current level
        # If user is at level 3, unlock books 1, 2, 3 (consider books 1-2 as already learned)
        textbook_unlock = evaluated_level  # Unlock books 1 to level
        
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
    Get roadmap tasks based on user level and progress from database
    
    Args:
        user_id: User ID
    
    Returns:
        Dictionary with tasks organized by categories, with progress from database
    """
    try:
        # Get roadmap from database
        roadmap_progress = database_service.get_roadmap_progress(user_id)
        
        if roadmap_progress:
            # Get task progress from database
            roadmap_id = roadmap_progress['roadmap_id']
            task_progress_list = database_service.get_roadmap_task_progress(user_id, roadmap_id)
            
            # Create a map of task_id -> progress
            task_progress_map = {
                t['task_id']: t for t in task_progress_list
            }
            
            # Get roadmap data and merge with progress
            roadmap_data = roadmap_progress.get('roadmap_data', {})
            periods = roadmap_data.get('periods', [])
            
            # Merge task progress into roadmap tasks
            for period in periods:
                for task in period.get('tasks', []):
                    task_id = task.get('id')
                    if task_id in task_progress_map:
                        progress = task_progress_map[task_id]
                        task['current'] = progress.get('current', 0)
                        task['completed'] = progress.get('completed', False)
            
            # Convert to task categories format (for backward compatibility)
            tasks = _generate_roadmap_tasks(level=roadmap_progress.get('current_level', 1))
            
            # Merge progress into tasks
            for category in tasks:
                for task in category.get('tasks', []):
                    task_id = task.get('id')
                    if task_id in task_progress_map:
                        progress = task_progress_map[task_id]
                        task['current'] = progress.get('current', 0)
                        task['completed'] = progress.get('completed', False)
            
            total_tasks = sum(len(cat["tasks"]) for cat in tasks)
            completed_tasks = sum(
                1 for cat in tasks
                for task in cat.get("tasks", [])
                if task.get("completed", False)
            )
            
            return {
                "user_id": user_id,
                "level": roadmap_progress.get('current_level', 1),
                "tasks": tasks,
                "total_tasks": total_tasks,
                "completed_tasks": completed_tasks,
                "roadmap_id": roadmap_id,
            }
        else:
            # No roadmap exists, return default tasks
            tasks = _generate_roadmap_tasks(level=1)
            return {
                "user_id": user_id,
                "level": 1,
                "tasks": tasks,
                "total_tasks": sum(len(cat["tasks"]) for cat in tasks),
                "completed_tasks": 0,
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
            "completed": bool,
            "current": int (optional, to update progress),
            "roadmap_id": str (optional, will find latest if not provided)
        }
    
    Returns:
        Success message
    """
    try:
        user_id = data.get("user_id")
        task_id = data.get("task_id")
        completed = data.get("completed", False)
        current = data.get("current")
        roadmap_id = data.get("roadmap_id")
        
        if not user_id or not task_id:
            raise HTTPException(status_code=400, detail="user_id and task_id are required")
        
        # Get roadmap_id if not provided
        if not roadmap_id:
            roadmap_progress = database_service.get_roadmap_progress(user_id)
            if not roadmap_progress:
                raise HTTPException(status_code=404, detail="Roadmap not found for user")
            roadmap_id = roadmap_progress['roadmap_id']
        
        # Get task info from roadmap data
        roadmap_progress = database_service.get_roadmap_progress(user_id, roadmap_id)
        if not roadmap_progress:
            raise HTTPException(status_code=404, detail="Roadmap not found")
        
        roadmap_data = roadmap_progress.get('roadmap_data', {})
        
        # Find task in roadmap data
        task_info = None
        for period in roadmap_data.get('periods', []):
            for task in period.get('tasks', []):
                if task.get('id') == task_id:
                    task_info = task
                    break
            if task_info:
                break
        
        if not task_info:
            raise HTTPException(status_code=404, detail="Task not found in roadmap")
        
        # Update task progress in database
        success = database_service.save_roadmap_task_progress(
            user_id=user_id,
            roadmap_id=roadmap_id,
            task_id=task_id,
            task_type=task_info.get('type', ''),
            task_title=task_info.get('title', ''),
            task_description=task_info.get('description', ''),
            target=task_info.get('target', 1),
            current=current,
            completed=completed
        )
        
        if not success:
            raise HTTPException(status_code=500, detail="Failed to update task status")
        
        logger.info(f"Task {task_id} updated for user {user_id}: completed={completed}")
        return {
            "success": True,
            "message": "Task status updated",
            "task_id": task_id,
            "completed": completed
        }
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error updating task status: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to update task status: {str(e)}")


@router.post("/generate")
async def generate_roadmap(data: Dict[str, Any]) -> Dict[str, Any]:
    """
    Generate personalized roadmap with timeline based on user goals
    
    Args:
        data: {
            "user_id": int,
            "current_level": int (1-6),  # From placement test
            "target_level": int (1-6),   # TOPIK level goal (e.g., 5)
            "timeline_months": int,       # Number of months to achieve goal (e.g., 10)
            "survey_data": {
                "hasLearnedKorean": bool,
                "learningReason": str,
                "selfAssessedLevel": int
            }
        }
    
    Returns:
        {
            "roadmap_id": str,
            "current_level": int,
            "target_level": int,
            "timeline_months": int,
            "total_days": int,
            "periods": [
                {
                    "period": "Ngày 1-10",
                    "start_day": 1,
                    "end_day": 10,
                    "title": "Giai đoạn nền tảng",
                    "description": "Mô tả giai đoạn",
                    "focus": ["từ vựng cơ bản", "ngữ pháp cơ bản"],
                    "tasks": [
                        {
                            "id": "task_1",
                            "type": "textbook_learn",
                            "title": "Học bài 1-3 trong giáo trình",
                            "description": "Hoàn thành 3 bài học đầu tiên",
                            "target": 3,
                            "current": 0,
                            "days": [1, 2, 3]  # Ngày nào làm task này
                        },
                        ...
                    ]
                },
                ...
            ]
        }
    """
    try:
        user_id = data.get("user_id")
        current_level = data.get("current_level", 1)
        target_level = data.get("target_level", 5)
        timeline_months = data.get("timeline_months", 10)
        timeline_days = data.get("timeline_days")  # Optional: actual days
        survey_data = data.get("survey_data", {})
        
        # Validate inputs
        current_level = max(1, min(6, int(current_level)))
        target_level = max(1, min(6, int(target_level)))
        timeline_months = max(1, min(24, int(timeline_months)))  # Max 2 years
        
        if current_level >= target_level:
            raise HTTPException(
                status_code=400, 
                detail="Target level must be higher than current level"
            )
        
        # Calculate total days: use timeline_days if provided, otherwise calculate from months
        if timeline_days is not None:
            total_days = max(1, min(730, int(timeline_days)))  # Max 2 years (730 days)
            # Update timeline_months to match actual days for display
            timeline_months = math.ceil(total_days / 30.0)
        else:
            total_days = timeline_months * 30  # Approximate
        
        # Generate roadmap using GPT
        roadmap = await _generate_roadmap_with_gpt(
            current_level=current_level,
            target_level=target_level,
            timeline_months=timeline_months,
            total_days=total_days,
            survey_data=survey_data
        )
        
        roadmap_id = f"roadmap_{user_id}_{int(__import__('time').time())}"
        
        # Save roadmap to database
        roadmap_full_data = {
            "roadmap_id": roadmap_id,
            "user_id": user_id,
            "current_level": current_level,
            "target_level": target_level,
            "timeline_months": timeline_months,
            "total_days": total_days,
            **roadmap
        }
        
        database_service.save_roadmap_progress(
            user_id=user_id,
            roadmap_id=roadmap_id,
            current_level=current_level,
            target_level=target_level,
            timeline_months=timeline_months,
            total_days=total_days,
            roadmap_data=roadmap_full_data
        )
        
        # Save all tasks to database
        for period in roadmap.get("periods", []):
            for task in period.get("tasks", []):
                database_service.save_roadmap_task_progress(
                    user_id=user_id,
                    roadmap_id=roadmap_id,
                    task_id=task.get("id", ""),
                    task_type=task.get("type", ""),
                    task_title=task.get("title", ""),
                    task_description=task.get("description", ""),
                    target=task.get("target", 1),
                    current=task.get("current", 0),
                    completed=False
                )
        
        logger.info(
            f"Generated and saved roadmap for user {user_id}: "
            f"Level {current_level} -> {target_level} in {timeline_months} months"
        )
        
        return {
            "roadmap_id": roadmap_id,
            "user_id": user_id,
            "current_level": current_level,
            "target_level": target_level,
            "timeline_months": timeline_months,
            "total_days": total_days,
            **roadmap
        }
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error generating roadmap: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to generate roadmap: {str(e)}")


async def _generate_roadmap_with_gpt(
    current_level: int,
    target_level: int,
    timeline_months: int,
    total_days: int,
    survey_data: Dict[str, Any]
) -> Dict[str, Any]:
    """Generate roadmap timeline using GPT"""
    
    # Available features in the app
    available_features = """
    CÁC TÍNH NĂNG CÓ SẴN TRONG APP:
    1. Giáo trình (Textbook):
       - Học bài (textbook_learn): Học các bài học trong giáo trình
       - Học từ vựng (textbook_vocab): Học từ vựng của bài học
       - Học ngữ pháp (textbook_grammar): Xem và học ngữ pháp
       - Làm bài tập (textbook_exercise): Làm bài tập và đạt điểm >= 80%
       - Chat với AI (textbook_chat): Sử dụng tính năng Chat AI trong bài học
    
    2. Từ vựng (Vocabulary):
       - Flashcard (vocab_flashcard): Học từ vựng bằng flashcard
       - Match game (vocab_match): Ghép từ tiếng Hàn - tiếng Việt
       - Phát âm (vocab_pronunciation): Luyện phát âm từ vựng
       - Nghe viết (vocab_listen_write): Nghe và viết từ vựng
       - Quiz (vocab_quiz): Làm quiz từ vựng
       - Test (vocab_test): Làm bài test từ vựng
    
    3. Luyện nói (Speaking):
       - Phát âm (speak_pronunciation): Luyện phát âm câu/phrase
       - Nói tự do (speak_free): Nói tự do với AI
       - Live talk (speak_live_talk): Trò chuyện trực tiếp với AI coach
    
    4. Luyện thi TOPIK:
       - Luyện đề (topik_practice): Làm đề thi TOPIK
       - Nghe (topik_listening): Luyện phần nghe TOPIK
       - Đọc (topik_reading): Luyện phần đọc TOPIK
    
    5. Ngữ pháp (Grammar):
       - Học ngữ pháp (grammar_learn): Xem và học ngữ pháp
       - Bài tập ngữ pháp (grammar_exercise): Làm bài tập ngữ pháp
    """
    
    # Calculate number of periods (chia timeline thành các giai đoạn)
    # Adjust period length based on total days
    if total_days <= 60:
        # Short timeline: smaller periods (5-10 days each)
        days_per_period = max(5, total_days // 6)  # 6 periods for 60 days = 10 days each
        num_periods = max(4, (total_days // days_per_period))
    elif total_days <= 180:
        # Medium timeline: 10-15 days each
        days_per_period = 12
        num_periods = max(3, (total_days // days_per_period))
    else:
        # Long timeline: 15-20 days each
        days_per_period = 15
        num_periods = max(3, (total_days // days_per_period))
    
    # Build GPT prompt with timeline awareness
    level_gap = target_level - current_level
    is_short_timeline = total_days <= 60
    is_high_target = target_level >= 5
    
    timeline_warning = ""
    if is_short_timeline and is_high_target:
        timeline_warning = f"""
⚠️ CẢNH BÁO QUAN TRỌNG:
- Timeline rất ngắn ({total_days} ngày) để đạt mục tiêu cao (cấp độ {target_level})
- Cần tập trung vào các task hiệu quả nhất, ưu tiên luyện thi TOPIK
- Giảm số lượng task nhưng tăng cường độ luyện tập
- Tập trung vào các kỹ năng quan trọng nhất cho TOPIK {target_level}
"""
    
    # Build GPT prompt
    gpt_prompt = f"""Bạn là một chuyên gia giáo dục tiếng Hàn với nhiều năm kinh nghiệm. Hãy tạo một lộ trình học tập chi tiết (roadmap) để giúp người học từ cấp độ {current_level} lên cấp độ {target_level} trong {timeline_months} tháng ({total_days} ngày).
{timeline_warning}

THÔNG TIN NGƯỜI HỌC:
- Cấp độ hiện tại: {current_level}/6
- Mục tiêu: Đạt cấp độ {target_level}/6
- Thời gian: {timeline_months} tháng ({total_days} ngày)
- Đã học tiếng Hàn: {survey_data.get('hasLearnedKorean', False)}
- Lý do học: {survey_data.get('learningReason', 'N/A')}

{available_features}

YÊU CẦU:
1. Chia lộ trình thành {num_periods} giai đoạn, mỗi giai đoạn khoảng {days_per_period} ngày
2. Mỗi giai đoạn phải có:
   - Tên giai đoạn (ví dụ: "Giai đoạn nền tảng", "Giai đoạn nâng cao")
   - Mô tả ngắn gọn mục tiêu của giai đoạn
   - Focus chính (2-3 điểm)
   - Danh sách tasks cụ thể với số lượng và ngày thực hiện

3. Tasks phải:
   - Sử dụng CÁC TÍNH NĂNG CÓ SẴN trong app (không tạo tính năng mới)
   - Cụ thể về số lượng (ví dụ: "Học 3 bài học", "Làm 2 đề TOPIK")
   - Phân bố đều trong giai đoạn (chỉ định ngày cụ thể)
   - Tăng dần độ khó theo từng giai đoạn
   - Phù hợp với cấp độ hiện tại và mục tiêu

4. Giai đoạn đầu: Tập trung vào nền tảng (từ vựng, ngữ pháp cơ bản)
5. Giai đoạn giữa: Nâng cao và luyện tập nhiều hơn
6. Giai đoạn cuối: Tập trung vào luyện thi TOPIK và củng cố kiến thức

{"7. LƯU Ý ĐẶC BIỆT CHO TIMELINE NGẮN:" if is_short_timeline else ""}
{"- Với timeline ngắn, cần tập trung vào các task hiệu quả nhất" if is_short_timeline else ""}
{"- Ưu tiên luyện đề TOPIK và củng cố kiến thức trọng tâm" if is_short_timeline else ""}
{"- Giảm số lượng task nhưng tăng cường độ luyện tập" if is_short_timeline else ""}
{"- Mỗi giai đoạn nên có ít task hơn nhưng tập trung hơn" if is_short_timeline else ""}

Trả lời theo format JSON:
{{
    "periods": [
        {{
            "period": "Ngày 1-15",
            "start_day": 1,
            "end_day": 15,
            "title": "Giai đoạn nền tảng",
            "description": "Mô tả ngắn gọn về giai đoạn này (2-3 câu)",
            "focus": ["từ vựng cơ bản", "ngữ pháp cơ bản", "phát âm"],
            "tasks": [
                {{
                    "id": "task_1_1",
                    "type": "textbook_learn",
                    "title": "Học bài 1-3 trong giáo trình",
                    "description": "Hoàn thành 3 bài học đầu tiên trong giáo trình",
                    "target": 3,
                    "current": 0,
                    "days": [1, 3, 5]  // Ngày cụ thể làm task này
                }},
                {{
                    "id": "task_1_2",
                    "type": "textbook_vocab",
                    "title": "Học từ vựng bài 1-3",
                    "description": "Học tất cả từ vựng của 3 bài học bằng flashcard",
                    "target": 50,  // Số từ vựng
                    "current": 0,
                    "days": [2, 4, 6]
                }},
                {{
                    "id": "task_1_3",
                    "type": "vocab_quiz",
                    "title": "Làm quiz từ vựng",
                    "description": "Làm 5 quiz từ vựng để kiểm tra",
                    "target": 5,
                    "current": 0,
                    "days": [7, 9, 11, 13, 15]
                }},
                {{
                    "id": "task_1_4",
                    "type": "speak_pronunciation",
                    "title": "Luyện phát âm",
                    "description": "Luyện phát âm 10 câu cơ bản",
                    "target": 10,
                    "current": 0,
                    "days": [8, 10, 12, 14]
                }}
            ]
        }},
        {{
            "period": "Ngày 16-30",
            "start_day": 16,
            "end_day": 30,
            "title": "Giai đoạn mở rộng",
            "description": "Mô tả giai đoạn",
            "focus": ["ngữ pháp nâng cao", "từ vựng mở rộng"],
            "tasks": [
                // Tương tự như trên, nhưng tăng độ khó
            ]
        }}
        // Tiếp tục cho đến hết {num_periods} giai đoạn
    ]
}}

QUAN TRỌNG:
- Phải tạo ĐÚNG {num_periods} giai đoạn
- Mỗi giai đoạn phải có ít nhất 4-6 tasks
- Tasks phải sử dụng các type có sẵn trong danh sách tính năng
- Phân bố tasks đều trong giai đoạn (không tập trung vào 1-2 ngày)
- Tăng dần độ khó và số lượng theo từng giai đoạn
- Chỉ trả về JSON, không có text thêm hay markdown formatting"""
    
    try:
        # Call GPT
        gpt_response = openai_service.chat_with_coach_ivy(
            user_message=gpt_prompt,
            conversation_history=[],
            use_system_prompt=False
        )
        
        # Parse GPT response
        import json
        import re
        
        # Extract JSON from response
        json_match = re.search(r'```json\s*(\{.*?\})\s*```', gpt_response, re.DOTALL)
        if not json_match:
            json_match = re.search(r'\{.*\}', gpt_response, re.DOTALL)
        
        if json_match:
            json_str = json_match.group(1) if json_match.groups() else json_match.group()
            roadmap_data = json.loads(json_str)
            periods = roadmap_data.get("periods", [])
            
            # Validate and fix periods if needed
            if len(periods) < num_periods:
                # Generate fallback periods
                periods = _generate_fallback_periods(
                    current_level, target_level, total_days, num_periods
                )
        else:
            # Fallback: generate basic roadmap
            periods = _generate_fallback_periods(
                current_level, target_level, total_days, num_periods
            )
        
        return {
            "periods": periods
        }
    except Exception as e:
        logger.warning(f"GPT roadmap generation failed: {e}, using fallback")
        # Fallback: generate basic roadmap
        periods = _generate_fallback_periods(
            current_level, target_level, total_days, num_periods
        )
        return {
            "periods": periods
        }


def _generate_fallback_periods(
    current_level: int,
    target_level: int,
    total_days: int,
    num_periods: int
) -> List[Dict[str, Any]]:
    """Generate fallback roadmap periods if GPT fails"""
    days_per_period = total_days // num_periods
    periods = []
    
    for i in range(num_periods):
        start_day = i * days_per_period + 1
        end_day = min((i + 1) * days_per_period, total_days)
        
        # Determine phase based on period index
        if i == 0:
            phase_name = "Giai đoạn nền tảng"
            phase_desc = "Tập trung vào từ vựng và ngữ pháp cơ bản"
            focus = ["từ vựng cơ bản", "ngữ pháp cơ bản", "phát âm"]
        elif i < num_periods // 2:
            phase_name = "Giai đoạn mở rộng"
            phase_desc = "Nâng cao kiến thức và luyện tập nhiều hơn"
            focus = ["ngữ pháp nâng cao", "từ vựng mở rộng", "luyện nói"]
        else:
            phase_name = "Giai đoạn luyện thi"
            phase_desc = "Tập trung vào luyện thi TOPIK và củng cố kiến thức"
            focus = ["luyện đề TOPIK", "củng cố kiến thức", "ôn tập"]
        
        # Generate tasks for this period
        tasks = []
        days_in_period = end_day - start_day + 1
        
        # Textbook tasks
        textbook_days = [start_day + j for j in range(0, days_in_period, 3)]
        tasks.append({
            "id": f"task_{i+1}_textbook",
            "type": "textbook_learn",
            "title": f"Học bài trong giáo trình (Giai đoạn {i+1})",
            "description": f"Hoàn thành {len(textbook_days)} bài học",
            "target": len(textbook_days),
            "current": 0,
            "days": textbook_days[:5]  # Limit to 5 days
        })
        
        # Vocabulary tasks
        vocab_days = [start_day + j for j in range(1, days_in_period, 2)]
        tasks.append({
            "id": f"task_{i+1}_vocab",
            "type": "vocab_flashcard",
            "title": f"Học từ vựng (Giai đoạn {i+1})",
            "description": f"Học {len(vocab_days) * 10} từ vựng mới",
            "target": len(vocab_days) * 10,
            "current": 0,
            "days": vocab_days[:7]  # Limit to 7 days
        })
        
        # Speaking tasks (for later periods)
        if i >= 1:
            speak_days = [start_day + j for j in range(2, days_in_period, 4)]
            tasks.append({
                "id": f"task_{i+1}_speak",
                "type": "speak_pronunciation",
                "title": f"Luyện phát âm (Giai đoạn {i+1})",
                "description": f"Luyện phát âm {len(speak_days) * 5} câu",
                "target": len(speak_days) * 5,
                "current": 0,
                "days": speak_days[:4]  # Limit to 4 days
            })
        
        # TOPIK tasks (for later periods)
        if i >= num_periods // 2:
            topik_days = [start_day + j for j in range(5, days_in_period, 7)]
            tasks.append({
                "id": f"task_{i+1}_topik",
                "type": "topik_practice",
                "title": f"Luyện đề TOPIK (Giai đoạn {i+1})",
                "description": f"Làm {len(topik_days)} đề thi TOPIK",
                "target": len(topik_days),
                "current": 0,
                "days": topik_days[:3]  # Limit to 3 days
            })
        
        periods.append({
            "period": f"Ngày {start_day}-{end_day}",
            "start_day": start_day,
            "end_day": end_day,
            "title": phase_name,
            "description": phase_desc,
            "focus": focus,
            "tasks": tasks
        })
    
    return periods


@router.get("/timeline/{user_id}")
async def get_roadmap_timeline(user_id: int) -> Dict[str, Any]:
    """
    Get roadmap timeline with progress from database
    
    Args:
        user_id: User ID
    
    Returns:
        Full roadmap timeline with merged progress from database
    """
    try:
        # Get roadmap from database
        roadmap_progress = database_service.get_roadmap_progress(user_id)
        
        if not roadmap_progress:
            raise HTTPException(status_code=404, detail="Roadmap not found for user")
        
        roadmap_id = roadmap_progress['roadmap_id']
        
        # Get task progress from database
        task_progress_list = database_service.get_roadmap_task_progress(user_id, roadmap_id)
        
        # Create a map of task_id -> progress
        task_progress_map = {
            t['task_id']: t for t in task_progress_list
        }
        
        # Get roadmap data and merge with progress
        roadmap_data = roadmap_progress.get('roadmap_data', {})
        periods = roadmap_data.get('periods', [])
        
        # Merge task progress into roadmap tasks
        for period in periods:
            for task in period.get('tasks', []):
                task_id = task.get('id')
                if task_id in task_progress_map:
                    progress = task_progress_map[task_id]
                    task['current'] = progress.get('current', 0)
                    task['completed'] = progress.get('completed', False)
        
        return {
            "roadmap_id": roadmap_id,
            "user_id": user_id,
            "current_level": roadmap_progress.get('current_level', 1),
            "target_level": roadmap_progress.get('target_level', 5),
            "timeline_months": roadmap_progress.get('timeline_months', 10),
            "total_days": roadmap_progress.get('total_days', 300),
            "periods": periods,
        }
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error getting roadmap timeline: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to get roadmap timeline: {str(e)}")


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
        # Get roadmap from database
        roadmap_progress = database_service.get_roadmap_progress(user_id)
        
        if not roadmap_progress:
            # Return default if no roadmap exists
            return {
                "user_id": user_id,
                "level": 1,
                "textbook_unlock": 0,
                "completed_tasks": 0,
                "total_tasks": 0,
                "progress": 0.0,
            }
        
        roadmap_id = roadmap_progress['roadmap_id']
        
        # Get task progress from database
        task_progress_list = database_service.get_roadmap_task_progress(user_id, roadmap_id)
        
        # Create a map of task_id -> progress
        task_progress_map = {
            t['task_id']: t for t in task_progress_list
        }
        
        # Get roadmap data and merge with progress
        roadmap_data = roadmap_progress.get('roadmap_data', {})
        periods = roadmap_data.get('periods', [])
        
        # Merge task progress into roadmap tasks
        for period in periods:
            for task in period.get('tasks', []):
                task_id = task.get('id')
                if task_id in task_progress_map:
                    progress = task_progress_map[task_id]
                    task['current'] = progress.get('current', 0)
                    task['completed'] = progress.get('completed', False)
        
        # Calculate statistics
        total_tasks = len(task_progress_list) if task_progress_list else 0
        completed_tasks = sum(1 for t in task_progress_list if t.get('completed', False))
        progress = (completed_tasks / total_tasks * 100) if total_tasks > 0 else 0.0
        
        return {
            "user_id": user_id,
            "level": roadmap_progress.get('current_level', 1),
            "textbook_unlock": roadmap_progress.get('current_level', 1),  # Unlock books 1 to current_level
            "completed_tasks": completed_tasks,
            "total_tasks": total_tasks,
            "progress": round(progress, 2),
            "roadmap_id": roadmap_id,
            "roadmap_data": roadmap_data,  # Include full roadmap with merged progress
        }
    except Exception as e:
        logger.error(f"Error getting user roadmap: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to get user roadmap: {str(e)}")

