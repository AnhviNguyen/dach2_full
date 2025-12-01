"""
TOPIK Service - Load and manage TOPIK exam questions

TOPIK 1 và TOPIK 2 có cấu trúc khác nhau:
===========================================
TOPIK 1:
- Listening: 30 câu (có audio)
- Reading: 40 câu (không audio)
- KHÔNG có file answers

TOPIK 2:
- Listening: 50 câu (có audio)
- Reading: 50 câu (không audio)
- CÓ file answers riêng:
  * topik{exam_number}_listening_answers.json
  * topik{exam_number}_reading_answers.json

CẤU TRÚC THƯ MỤC:
===========================================
topik/
  ├── topik1/
  │   ├── 35/
  │   │   ├── topik35_listen_questions.json
  │   │   └── topik35_reading_questions.json
  │   ├── 36/
  │   └── 37/
  └── topik2/
      ├── 35/
      │   ├── topik35_listen_questions.json
      │   ├── topik35_listening_answers.json
      │   ├── topik35_reading_questions.json
      │   └── topik35_reading_answers.json
      ├── 36/
      └── ...
"""
import json
import logging
from pathlib import Path
from typing import List, Dict, Optional, Any, Literal

logger = logging.getLogger(__name__)

# Path to TOPIK directory
# Cấu trúc: TOPIK_DIR/topik1/{exam_number}/...
#           TOPIK_DIR/topik2/{exam_number}/...
TOPIK_DIR = Path(__file__).parent.parent / "topik"

# Cache for loaded questions and answers
_questions_cache: Dict[str, Dict[str, Any]] = {}
_answers_cache: Dict[str, Dict[str, Any]] = {}


def load_topik_questions(
    topik_level: Literal["1", "2"],
    exam_number: str,
    question_type: Literal["listening", "reading"]
) -> Dict[str, Any]:
    """
    Load TOPIK questions from JSON file
    
    Args:
        topik_level: TOPIK level ("1" or "2")
        exam_number: Exam number (e.g., "35", "36", "37")
        question_type: Type of questions ("listening" or "reading")
    
    Returns:
        Dictionary containing questions data with structure:
        {
            "url": "...",
            "total": 30/40/50,  // 30 listening, 40 reading cho TOPIK 1; 50/50 cho TOPIK 2
            "question_type": "listening" or "reading",
            "has_audio": True/False,
            "topik_level": "1" or "2",
            "has_answers": True/False,  // True cho TOPIK 2
            "questions": [...]
        }
    """
    cache_key = f"{topik_level}_{exam_number}_{question_type}"
    
    if cache_key in _questions_cache:
        return _questions_cache[cache_key]
    
    # Map question_type to filename
    type_mapping = {
        "listening": "listen",
        "reading": "reading"
    }
    
    file_type = type_mapping.get(question_type, "listen")
    file_path = TOPIK_DIR / f"topik{topik_level}" / exam_number / f"topik{exam_number}_{file_type}_questions.json"
    
    if not file_path.exists():
        logger.warning(f"TOPIK file not found: {file_path}")
        return {
            "error": f"File not found for TOPIK {topik_level}, exam {exam_number}, type {question_type}",
            "questions": [],
            "total": 0,
            "question_type": question_type,
            "topik_level": topik_level,
            "has_audio": question_type == "listening",
            "has_answers": topik_level == "2"
        }
    
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        # Add metadata
        data["question_type"] = question_type
        data["topik_level"] = topik_level
        data["has_audio"] = question_type == "listening"
        data["has_answers"] = topik_level == "2"
        
        # Extract audio URLs from questions (for listening)
        if question_type == "listening":
            audio_count = 0
            for question in data.get("questions", []):
                context = question.get("context", {})
                audio_url = context.get("audio", "")
                if audio_url:
                    audio_count += 1
                    # Store audio URL in question for easy access
                    question["audio_url"] = audio_url
            logger.info(f"Found {audio_count} audio files in {data.get('total', 0)} listening questions")
        
        _questions_cache[cache_key] = data
        logger.info(f"✅ Loaded TOPIK {topik_level} exam {exam_number} {question_type}: {data.get('total', 0)} questions")
        return data
    except Exception as e:
        logger.error(f"Error loading TOPIK questions: {e}", exc_info=True)
        return {
            "error": str(e),
            "questions": [],
            "total": 0,
            "question_type": question_type,
            "topik_level": topik_level,
            "has_audio": question_type == "listening",
            "has_answers": topik_level == "2"
        }


def load_topik_answers(
    topik_level: Literal["1", "2"],
    exam_number: str,
    question_type: Literal["listening", "reading"]
) -> Optional[Dict[str, Any]]:
    """
    Load TOPIK answers from JSON file (chỉ có cho TOPIK 2)
    
    Args:
        topik_level: TOPIK level ("1" or "2")
        exam_number: Exam number
        question_type: Type of questions
    
    Returns:
        Dictionary with answers data or None if not found/not available
    """
    # TOPIK 1 không có answers
    if topik_level == "1":
        return None
    
    cache_key = f"{topik_level}_{exam_number}_{question_type}_answers"
    
    if cache_key in _answers_cache:
        return _answers_cache[cache_key]
    
    # Map question_type to filename
    type_mapping = {
        "listening": "listening",
        "reading": "reading"
    }
    
    file_type = type_mapping.get(question_type, "listening")
    file_path = TOPIK_DIR / f"topik{topik_level}" / exam_number / f"topik{exam_number}_{file_type}_answers.json"
    
    if not file_path.exists():
        logger.warning(f"TOPIK answers file not found: {file_path}")
        return None
    
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        _answers_cache[cache_key] = data
        logger.info(f"✅ Loaded TOPIK {topik_level} exam {exam_number} {question_type} answers: {data.get('total', 0)} answers")
        return data
    except Exception as e:
        logger.error(f"Error loading TOPIK answers: {e}", exc_info=True)
        return None


def get_topik_question(
    topik_level: Literal["1", "2"],
    exam_number: str,
    question_type: Literal["listening", "reading"],
    question_id: str
) -> Optional[Dict[str, Any]]:
    """
    Get a specific question by ID
    
    Args:
        topik_level: TOPIK level ("1" or "2")
        exam_number: Exam number
        question_type: Type of questions
        question_id: Question ID
    
    Returns:
        Question data if found, None otherwise
    """
    data = load_topik_questions(topik_level, exam_number, question_type)
    questions = data.get("questions", [])
    
    for question in questions:
        if question.get("question_id") == question_id:
            return question
    
    return None


def get_topik_question_by_number(
    topik_level: Literal["1", "2"],
    exam_number: str,
    question_type: Literal["listening", "reading"],
    number: int
) -> Optional[Dict[str, Any]]:
    """
    Get a specific question by question number
    
    Args:
        topik_level: TOPIK level ("1" or "2")
        exam_number: Exam number
        question_type: Type of questions
        number: Question number (1-indexed)
    
    Returns:
        Question data if found, None otherwise
    """
    data = load_topik_questions(topik_level, exam_number, question_type)
    questions = data.get("questions", [])
    
    for question in questions:
        if question.get("number") == number:
            return question
    
    return None


def get_correct_answer(
    topik_level: Literal["1", "2"],
    exam_number: str,
    question_type: Literal["listening", "reading"],
    question_id: str
) -> Optional[str]:
    """
    Get correct answer for a question (chỉ có cho TOPIK 2)
    
    Args:
        topik_level: TOPIK level ("1" or "2")
        exam_number: Exam number
        question_type: Type of questions
        question_id: Question ID
    
    Returns:
        Correct answer option (e.g., "A", "B", "C", "D") or None
    """
    if topik_level == "1":
        return None
    
    answers_data = load_topik_answers(topik_level, exam_number, question_type)
    if not answers_data:
        return None
    
    answers = answers_data.get("answers", [])
    for answer in answers:
        if answer.get("question_id") == question_id:
            return answer.get("correct_option")
    
    return None


def list_available_exams(topik_level: Optional[Literal["1", "2"]] = None) -> Dict[str, List[str]]:
    """
    List all available exam numbers
    
    Args:
        topik_level: TOPIK level ("1" or "2") - if None, returns both
    
    Returns:
        Dictionary with "1" and/or "2" as keys, each containing list of exam numbers
    """
    result = {}
    
    if topik_level is None:
        levels = ["1", "2"]
    else:
        levels = [topik_level]
    
    for level in levels:
        level_dir = TOPIK_DIR / f"topik{level}"
        if not level_dir.exists():
            result[level] = []
            continue
        
        exams = []
        for item in level_dir.iterdir():
            if item.is_dir() and item.name.isdigit():
                exams.append(item.name)
        
        result[level] = sorted(exams)
    
    return result


def get_topik_stats(topik_level: Optional[Literal["1", "2"]] = None) -> Dict[str, Any]:
    """
    Get statistics about available TOPIK data
    
    Args:
        topik_level: TOPIK level ("1" or "2") - if None, returns stats for both
    
    Returns:
        Dictionary with statistics
    """
    if topik_level is None:
        levels = ["1", "2"]
    else:
        levels = [topik_level]
    
    stats = {
        "topik_levels": {},
        "total_exams": 0,
        "total_listening_questions": 0,
        "total_reading_questions": 0,
        "directory": str(TOPIK_DIR)
    }
    
    for level in levels:
        exams = list_available_exams(level).get(level, [])
        level_stats = {
            "total_exams": len(exams),
            "exams": [],
            "total_listening_questions": 0,
            "total_reading_questions": 0,
            "question_counts": {
                "listening": 30 if level == "1" else 50,
                "reading": 40 if level == "1" else 50
            },
            "has_answers": level == "2"
        }
        
        for exam in exams:
            listening_data = load_topik_questions(level, exam, "listening")
            reading_data = load_topik_questions(level, exam, "reading")
            
            listening_count = listening_data.get("total", 0)
            reading_count = reading_data.get("total", 0)
            
            level_stats["total_listening_questions"] += listening_count
            level_stats["total_reading_questions"] += reading_count
            
            level_stats["exams"].append({
                "exam_number": exam,
                "listening_questions": listening_count,
                "reading_questions": reading_count,
                "has_listening_audio": listening_data.get("has_audio", False),
                "has_reading_audio": reading_data.get("has_audio", False),
                "has_answers": level == "2"
            })
        
        level_stats["total_questions"] = level_stats["total_listening_questions"] + level_stats["total_reading_questions"]
        stats["topik_levels"][level] = level_stats
        stats["total_exams"] += len(exams)
        stats["total_listening_questions"] += level_stats["total_listening_questions"]
        stats["total_reading_questions"] += level_stats["total_reading_questions"]
    
    stats["total_questions"] = stats["total_listening_questions"] + stats["total_reading_questions"]
    
    return stats
