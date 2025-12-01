"""
TOPIK Router - Endpoints for TOPIK exam questions
Hỗ trợ cả TOPIK 1 và TOPIK 2
"""
from fastapi import APIRouter, HTTPException, Query
from typing import List, Dict, Any, Optional, Literal
import logging

from services import topik_service
from services import vocabulary_lookup_service as dictionary_service
from services import openai_service

logger = logging.getLogger(__name__)

router = APIRouter(
    prefix="/api/topik",
    tags=["topik"]
)


@router.get("/exams")
async def list_exams(
    topik_level: Optional[Literal["1", "2"]] = Query(None, description="TOPIK level (1 or 2). If not provided, returns both")
) -> Dict[str, Any]:
    """
    List all available TOPIK exam numbers
    
    Args:
        topik_level: TOPIK level ("1" or "2") - if None, returns both
    
    Returns:
        Dictionary with exam numbers for each TOPIK level
    """
    try:
        exams = topik_service.list_available_exams(topik_level)
        return {
            "exams": exams,
            "total": sum(len(v) for v in exams.values()) if isinstance(exams, dict) else len(exams)
        }
    except Exception as e:
        logger.error(f"Error listing exams: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to list exams: {str(e)}")


@router.get("/exams/{exam_number}/questions")
async def get_topik_questions(
    exam_number: str,
    topik_level: Literal["1", "2"] = Query(..., description="TOPIK level: '1' or '2'"),
    question_type: Literal["listening", "reading"] = Query(..., description="Type of questions: 'listening' or 'reading'"),
    limit: Optional[int] = Query(None, ge=1, le=100, description="Limit number of questions returned"),
    offset: int = Query(0, ge=0, description="Offset for pagination")
) -> Dict[str, Any]:
    """
    Get TOPIK questions for a specific exam
    
    TOPIK Structure:
    - TOPIK 1: Listening (30 questions with audio), Reading (40 questions, no audio)
    - TOPIK 2: Listening (50 questions with audio), Reading (50 questions, no audio)
    - TOPIK 2 có file answers riêng
    
    Args:
        exam_number: Exam number (e.g., "35", "36", "37")
        topik_level: TOPIK level ("1" or "2")
        question_type: "listening" (with audio) or "reading" (no audio)
        limit: Maximum number of questions to return
        offset: Offset for pagination
    
    Returns:
        Dictionary with questions data including audio URLs for listening questions
    """
    try:
        # Validate exam exists for this level
        available_exams = topik_service.list_available_exams(topik_level)
        level_exams = available_exams.get(topik_level, [])
        
        if exam_number not in level_exams:
            raise HTTPException(
                status_code=404,
                detail=f"Exam {exam_number} not found for TOPIK {topik_level}. Available exams: {', '.join(level_exams) if level_exams else 'None'}"
            )
        
        data = topik_service.load_topik_questions(topik_level, exam_number, question_type)
        
        if "error" in data:
            error_msg = data["error"]
            logger.warning(f"Failed to load questions: {error_msg}")
            raise HTTPException(
                status_code=404, 
                detail=error_msg
            )
        
        questions = data.get("questions", [])
        total = data.get("total", len(questions))
        has_audio = data.get("has_audio", question_type == "listening")
        has_answers = data.get("has_answers", topik_level == "2")
        
        # Validate that we have questions
        if not questions:
            raise HTTPException(
                status_code=404,
                detail=f"No questions found for TOPIK {topik_level}, exam {exam_number}, type {question_type}"
            )
        
        # Apply pagination
        if limit is not None:
            questions = questions[offset:offset + limit]
        else:
            questions = questions[offset:]
        
        # Add correct_answer to each question if TOPIK 2
        if topik_level == "2" and has_answers:
            for question in questions:
                question_id = question.get("question_id")
                if question_id:
                    correct_answer = topik_service.get_correct_answer(topik_level, exam_number, question_type, question_id)
                    if correct_answer:
                        question["correct_answer"] = correct_answer
        
        # Log audio information for listening
        if question_type == "listening":
            audio_count = sum(1 for q in questions if q.get("audio_url"))
            logger.info(f"Returning {len(questions)} listening questions, {audio_count} with audio URLs")
        
        return {
            "topik_level": topik_level,
            "exam_number": exam_number,
            "question_type": question_type,
            "total_questions": total,  # Total questions in exam
            "has_audio": has_audio,  # True for listening, False for reading
            "has_answers": has_answers,  # True for TOPIK 2, False for TOPIK 1
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
    topik_level: Literal["1", "2"] = Query(..., description="TOPIK level: '1' or '2'"),
    question_type: Literal["listening", "reading"] = Query(..., description="Type of questions: 'listening' or 'reading'")
) -> Dict[str, Any]:
    """
    Get a specific TOPIK question by ID
    
    For listening questions, includes audio_url for playback.
    For TOPIK 2, includes correct_answer if available.
    
    Args:
        exam_number: Exam number (e.g., "35", "36", "37")
        question_id: Question ID
        topik_level: TOPIK level ("1" or "2")
        question_type: "listening" (has audio) or "reading" (no audio)
    
    Returns:
        Question data with audio_url if listening question, and correct_answer if TOPIK 2
    """
    try:
        question = topik_service.get_topik_question(topik_level, exam_number, question_type, question_id)
        if question is None:
            raise HTTPException(
                status_code=404,
                detail=f"Question {question_id} not found in TOPIK {topik_level} exam {exam_number}"
            )
        
        # Extract audio URL if listening question
        audio_url = None
        if question_type == "listening":
            context = question.get("context", {})
            audio_url = context.get("audio") or question.get("audio_url")
            if audio_url:
                logger.info(f"Question {question_id} has audio: {audio_url}")
        
        # Get correct answer if TOPIK 2
        correct_answer = None
        if topik_level == "2":
            correct_answer = topik_service.get_correct_answer(topik_level, exam_number, question_type, question_id)
        
        return {
            "topik_level": topik_level,
            "exam_number": exam_number,
            "question_type": question_type,
            "has_audio": question_type == "listening" and audio_url is not None,
            "has_answer": topik_level == "2",
            "audio_url": audio_url,  # Audio URL for listening questions (None for reading)
            "correct_answer": correct_answer,  # Correct answer for TOPIK 2 (None for TOPIK 1)
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
    topik_level: Literal["1", "2"] = Query(..., description="TOPIK level: '1' or '2'"),
    question_type: Literal["listening", "reading"] = Query(..., description="Type of questions: 'listening' or 'reading'")
) -> Dict[str, Any]:
    """
    Get a specific TOPIK question by question number
    
    Question number ranges:
    - TOPIK 1: Listening (1-30), Reading (1-40)
    - TOPIK 2: Listening (1-50), Reading (1-50)
    
    For listening questions, includes audio_url for playback.
    For TOPIK 2, includes correct_answer if available.
    
    Args:
        exam_number: Exam number (e.g., "35", "36", "37")
        number: Question number (1-indexed)
        topik_level: TOPIK level ("1" or "2")
        question_type: "listening" or "reading"
    
    Returns:
        Question data with audio_url if listening question, and correct_answer if TOPIK 2
    """
    try:
        # Validate question number range
        if topik_level == "1":
            if question_type == "listening" and (number < 1 or number > 30):
                raise HTTPException(
                    status_code=400,
                    detail=f"TOPIK 1 listening question number must be between 1 and 30, got {number}"
                )
            elif question_type == "reading" and (number < 1 or number > 40):
                raise HTTPException(
                    status_code=400,
                    detail=f"TOPIK 1 reading question number must be between 1 and 40, got {number}"
                )
        else:  # TOPIK 2
            if question_type == "listening" and (number < 1 or number > 50):
                raise HTTPException(
                    status_code=400,
                    detail=f"TOPIK 2 listening question number must be between 1 and 50, got {number}"
                )
            elif question_type == "reading" and (number < 1 or number > 50):
                raise HTTPException(
                    status_code=400,
                    detail=f"TOPIK 2 reading question number must be between 1 and 50, got {number}"
                )
        
        question = topik_service.get_topik_question_by_number(topik_level, exam_number, question_type, number)
        if question is None:
            raise HTTPException(
                status_code=404,
                detail=f"Question number {number} not found in TOPIK {topik_level} exam {exam_number}"
            )
        
        # Extract audio URL if listening question
        audio_url = None
        if question_type == "listening":
            context = question.get("context", {})
            audio_url = context.get("audio") or question.get("audio_url")
            if audio_url:
                logger.info(f"Question #{number} has audio: {audio_url}")
        
        # Get correct answer if TOPIK 2
        correct_answer = None
        question_id = question.get("question_id")
        if topik_level == "2" and question_id:
            correct_answer = topik_service.get_correct_answer(topik_level, exam_number, question_type, question_id)
        
        return {
            "topik_level": topik_level,
            "exam_number": exam_number,
            "question_type": question_type,
            "question_number": number,
            "has_audio": question_type == "listening" and audio_url is not None,
            "has_answer": topik_level == "2",
            "audio_url": audio_url,  # Audio URL for listening questions (None for reading)
            "correct_answer": correct_answer,  # Correct answer for TOPIK 2 (None for TOPIK 1)
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
    topik_level: Literal["1", "2"] = Query(..., description="TOPIK level: '1' or '2'"),
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
        topik_level: TOPIK level ("1" or "2")
        question_type: Type of questions
        max_words: Maximum number of words to translate
    
    Returns:
        Dictionary with question data and vocabulary translations
    """
    try:
        # Get the question
        question = topik_service.get_topik_question(topik_level, exam_number, question_type, question_id)
        if question is None:
            raise HTTPException(
                status_code=404,
                detail=f"Question {question_id} not found in TOPIK {topik_level} exam {exam_number}"
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
            "topik_level": topik_level,
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
async def get_topik_stats(
    topik_level: Optional[Literal["1", "2"]] = Query(None, description="TOPIK level (1 or 2). If not provided, returns stats for both")
) -> Dict[str, Any]:
    """
    Get statistics about available TOPIK data
    
    Args:
        topik_level: TOPIK level ("1" or "2") - if None, returns stats for both
    
    Returns:
        Dictionary with statistics
    """
    try:
        stats = topik_service.get_topik_stats(topik_level)
        return stats
    except Exception as e:
        logger.error(f"Error getting TOPIK stats: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to get stats: {str(e)}")


@router.get("/competition/questions")
async def get_competition_questions(
    count: int = Query(20, ge=1, le=50, description="Number of questions to return"),
    mix_types: bool = Query(True, description="Mix listening and reading questions"),
    mix_levels: bool = Query(True, description="Mix TOPIK 1 and TOPIK 2 questions"),
    topik_level: Optional[Literal["1", "2"]] = Query(None, description="Specific TOPIK level (if None and mix_levels=True, uses both)")
) -> Dict[str, Any]:
    """
    Get random TOPIK questions for competition
    
    This endpoint returns a mix of listening and reading questions from different exams.
    Questions are randomly selected and shuffled.
    Có thể mix cả TOPIK 1 và TOPIK 2 nếu mix_levels=True.
    
    Args:
        count: Number of questions to return (default: 20, max: 50)
        mix_types: Whether to mix listening and reading questions (default: True)
        mix_levels: Whether to mix TOPIK 1 and TOPIK 2 questions (default: True)
        topik_level: Specific TOPIK level ("1" or "2") - if provided, only uses that level
    
    Returns:
        Dictionary with mixed questions from different exams and levels
    """
    try:
        import random
        
        # Determine which levels to use
        if topik_level:
            levels = [topik_level]
        elif mix_levels:
            levels = ["1", "2"]
        else:
            levels = ["1"]  # Default to TOPIK 1 if not mixing
        
        all_questions = []
        
        # Collect questions from all levels and exams
        for level in levels:
            exams = topik_service.list_available_exams(level).get(level, [])
            if not exams:
                continue
            
            for exam_number in exams:
                # Get listening questions
                listening_data = topik_service.load_topik_questions(level, exam_number, "listening")
                listening_questions = listening_data.get("questions", [])
                
                # Get reading questions
                reading_data = topik_service.load_topik_questions(level, exam_number, "reading")
                reading_questions = reading_data.get("questions", [])
                
                # Add metadata to questions
                for q in listening_questions:
                    q["question_type"] = "listening"
                    q["topik_level"] = level
                    q["exam_number"] = exam_number
                    # Extract audio URL
                    context = q.get("context", {})
                    audio_url = context.get("audio") or q.get("audio_url")
                    if audio_url:
                        q["audio_url"] = audio_url
                    # Get correct answer if TOPIK 2
                    if level == "2":
                        question_id = q.get("question_id")
                        if question_id:
                            correct_answer = topik_service.get_correct_answer(level, exam_number, "listening", question_id)
                            if correct_answer:
                                q["correct_answer"] = correct_answer
                
                for q in reading_questions:
                    q["question_type"] = "reading"
                    q["topik_level"] = level
                    q["exam_number"] = exam_number
                    q["audio_url"] = None
                    # Get correct answer if TOPIK 2
                    if level == "2":
                        question_id = q.get("question_id")
                        if question_id:
                            correct_answer = topik_service.get_correct_answer(level, exam_number, "reading", question_id)
                            if correct_answer:
                                q["correct_answer"] = correct_answer
                
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
        
        # Count by type and level
        listening_count = sum(1 for q in selected_questions if q.get("question_type") == "listening")
        reading_count = sum(1 for q in selected_questions if q.get("question_type") == "reading")
        topik1_count = sum(1 for q in selected_questions if q.get("topik_level") == "1")
        topik2_count = sum(1 for q in selected_questions if q.get("topik_level") == "2")
        
        logger.info(f"Returning {len(selected_questions)} competition questions: {listening_count} listening, {reading_count} reading, {topik1_count} TOPIK 1, {topik2_count} TOPIK 2")
        
        return {
            "total": len(selected_questions),
            "listening_count": listening_count,
            "reading_count": reading_count,
            "topik1_count": topik1_count,
            "topik2_count": topik2_count,
            "questions": selected_questions
        }
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error getting competition questions: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to get competition questions: {str(e)}")


@router.get("/exams/{exam_number}/questions/{question_id}/explain")
async def explain_topik_question(
    exam_number: str,
    question_id: str,
    topik_level: Literal["1", "2"] = Query(..., description="TOPIK level: '1' or '2'"),
    question_type: Literal["listening", "reading"] = Query(..., description="Type of questions: 'listening' or 'reading'")
) -> Dict[str, Any]:
    """
    Giải thích câu hỏi TOPIK bằng GPT
    
    GPT sẽ giải thích:
    - Nội dung câu hỏi
    - Các đáp án và ý nghĩa
    - Đáp án đúng và lý do (nếu là TOPIK 2)
    - Từ vựng và ngữ pháp quan trọng
    
    Args:
        exam_number: Exam number (e.g., "35", "36", "37")
        question_id: Question ID
        topik_level: TOPIK level ("1" or "2")
        question_type: "listening" or "reading"
    
    Returns:
        Dictionary with question data and GPT explanation
    """
    try:
        # Get the question
        question = topik_service.get_topik_question(topik_level, exam_number, question_type, question_id)
        if question is None:
            raise HTTPException(
                status_code=404,
                detail=f"Question {question_id} not found in TOPIK {topik_level} exam {exam_number}"
            )
        
        # Get correct answer if TOPIK 2
        correct_answer = None
        if topik_level == "2":
            correct_answer = topik_service.get_correct_answer(topik_level, exam_number, question_type, question_id)
        
        # Build prompt for GPT
        prompt_parts = []
        prompt_parts.append(f"Đây là một câu hỏi TOPIK {topik_level} ({question_type}):\n\n")
        
        # Add question number
        question_number = question.get("number", "")
        if question_number:
            prompt_parts.append(f"Câu {question_number}:\n")
        
        # Add prompt text
        prompt_text = question.get("prompt", "")
        if prompt_text:
            prompt_parts.append(f"Yêu cầu: {prompt_text}\n\n")
        
        # Add intro text if available
        intro_text = question.get("intro_text", "")
        if intro_text:
            prompt_parts.append(f"Đoạn văn/Đoạn hội thoại:\n{intro_text}\n\n")
        
        # Add answer options
        answers = question.get("answers", [])
        if answers:
            prompt_parts.append("Các đáp án:\n")
            for answer in answers:
                option = answer.get("option", "")
                text = answer.get("text", "")
                prompt_parts.append(f"{option}. {text}\n")
            prompt_parts.append("\n")
        
        # Add correct answer if available
        if correct_answer:
            prompt_parts.append(f"Đáp án đúng: {correct_answer}\n\n")
        
        prompt_parts.append("""Hãy giải thích ngắn gọn đáp án đúng bằng tiếng Việt (chỉ 2-3 câu):
- Giải thích tại sao đáp án đúng là đáp án đó
- Nếu có thể, giải thích ngắn gọn tại sao các đáp án khác sai
- Giữ giải thích ngắn gọn, dễ hiểu, phù hợp với người học tiếng Hàn

QUAN TRỌNG: Chỉ viết 2-3 câu, không cần giải thích dài dòng.""")
        
        full_prompt = "".join(prompt_parts)
        
        # Call GPT to explain
        try:
            explanation = await openai_service.chat_with_coach_ivy(
                user_message=full_prompt,
                conversation_history=None,
                use_system_prompt=True
            )
        except Exception as e:
            logger.error(f"Error calling GPT for explanation: {e}")
            explanation = f"Không thể tạo giải thích tự động. Lỗi: {str(e)}"
        
        # Extract audio URL if listening
        audio_url = None
        if question_type == "listening":
            context = question.get("context", {})
            audio_url = context.get("audio") or question.get("audio_url")
        
        return {
            "topik_level": topik_level,
            "exam_number": exam_number,
            "question_type": question_type,
            "question_id": question_id,
            "question_number": question.get("number"),
            "has_audio": question_type == "listening" and audio_url is not None,
            "audio_url": audio_url,
            "correct_answer": correct_answer,
            "question": question,
            "explanation": explanation
        }
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error explaining TOPIK question: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to explain question: {str(e)}")


@router.get("/exams/{exam_number}/questions/number/{number}/explain")
async def explain_topik_question_by_number(
    exam_number: str,
    number: int,
    topik_level: Literal["1", "2"] = Query(..., description="TOPIK level: '1' or '2'"),
    question_type: Literal["listening", "reading"] = Query(..., description="Type of questions: 'listening' or 'reading'")
) -> Dict[str, Any]:
    """
    Giải thích câu hỏi TOPIK bằng GPT (theo số thứ tự câu)
    
    GPT sẽ giải thích:
    - Nội dung câu hỏi
    - Các đáp án và ý nghĩa
    - Đáp án đúng và lý do (nếu là TOPIK 2)
    - Từ vựng và ngữ pháp quan trọng
    
    Args:
        exam_number: Exam number (e.g., "35", "36", "37")
        number: Question number (1-indexed)
        topik_level: TOPIK level ("1" or "2")
        question_type: "listening" or "reading"
    
    Returns:
        Dictionary with question data and GPT explanation
    """
    try:
        # Validate question number range
        if topik_level == "1":
            if question_type == "listening" and (number < 1 or number > 30):
                raise HTTPException(
                    status_code=400,
                    detail=f"TOPIK 1 listening question number must be between 1 and 30, got {number}"
                )
            elif question_type == "reading" and (number < 1 or number > 40):
                raise HTTPException(
                    status_code=400,
                    detail=f"TOPIK 1 reading question number must be between 1 and 40, got {number}"
                )
        else:  # TOPIK 2
            if question_type == "listening" and (number < 1 or number > 50):
                raise HTTPException(
                    status_code=400,
                    detail=f"TOPIK 2 listening question number must be between 1 and 50, got {number}"
                )
            elif question_type == "reading" and (number < 1 or number > 50):
                raise HTTPException(
                    status_code=400,
                    detail=f"TOPIK 2 reading question number must be between 1 and 50, got {number}"
                )
        
        question = topik_service.get_topik_question_by_number(topik_level, exam_number, question_type, number)
        if question is None:
            raise HTTPException(
                status_code=404,
                detail=f"Question number {number} not found in TOPIK {topik_level} exam {exam_number}"
            )
        
        question_id = question.get("question_id")
        if not question_id:
            raise HTTPException(
                status_code=404,
                detail=f"Question number {number} does not have a question_id"
            )
        
        # Use the question_id endpoint
        return await explain_topik_question(
            exam_number=exam_number,
            question_id=question_id,
            topik_level=topik_level,
            question_type=question_type
        )
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error explaining TOPIK question by number: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to explain question: {str(e)}")
