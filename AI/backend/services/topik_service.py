"""
TOPIK Service - Load and manage TOPIK exam questions
"""
import json
import logging
from pathlib import Path
from typing import List, Dict, Optional, Any, Literal

logger = logging.getLogger(__name__)

# Path to TOPIK directory
TOPIK_DIR = Path(r"C:\Users\admin\Downloads\topik1")

# Cache for loaded questions
_questions_cache: Dict[str, Dict[str, Any]] = {}


def load_topik_questions(exam_number: str, question_type: Literal["listening", "reading"]) -> Dict[str, Any]:
    """
    Load TOPIK questions from JSON file
    
    Args:
        exam_number: Exam number (e.g., "35", "36", "37")
        question_type: Type of questions ("listening" or "reading")
    
    Returns:
        Dictionary containing questions data
    """
    cache_key = f"{exam_number}_{question_type}"
    
    if cache_key in _questions_cache:
        return _questions_cache[cache_key]
    
    # Map question_type to filename
    type_mapping = {
        "listening": "listen",
        "reading": "reading"
    }
    
    file_type = type_mapping.get(question_type, "listen")
    file_path = TOPIK_DIR / exam_number / f"topik{exam_number}_{file_type}_questions.json"
    
    if not file_path.exists():
        logger.warning(f"TOPIK file not found: {file_path}")
        return {
            "error": f"File not found for exam {exam_number}, type {question_type}",
            "questions": [],
            "total": 0
        }
    
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        _questions_cache[cache_key] = data
        logger.info(f"Loaded TOPIK {exam_number} {question_type}: {data.get('total', 0)} questions")
        return data
    except Exception as e:
        logger.error(f"Error loading TOPIK questions: {e}")
        return {
            "error": str(e),
            "questions": [],
            "total": 0
        }


def get_topik_question(exam_number: str, question_type: Literal["listening", "reading"], question_id: str) -> Optional[Dict[str, Any]]:
    """
    Get a specific question by ID
    
    Args:
        exam_number: Exam number
        question_type: Type of questions
        question_id: Question ID
    
    Returns:
        Question data if found, None otherwise
    """
    data = load_topik_questions(exam_number, question_type)
    questions = data.get("questions", [])
    
    for question in questions:
        if question.get("question_id") == question_id:
            return question
    
    return None


def get_topik_question_by_number(exam_number: str, question_type: Literal["listening", "reading"], number: int) -> Optional[Dict[str, Any]]:
    """
    Get a specific question by question number
    
    Args:
        exam_number: Exam number
        question_type: Type of questions
        number: Question number (1-indexed)
    
    Returns:
        Question data if found, None otherwise
    """
    data = load_topik_questions(exam_number, question_type)
    questions = data.get("questions", [])
    
    for question in questions:
        if question.get("number") == number:
            return question
    
    return None


def list_available_exams() -> List[str]:
    """
    List all available exam numbers
    
    Returns:
        List of exam numbers (as strings)
    """
    if not TOPIK_DIR.exists():
        return []
    
    exams = []
    for item in TOPIK_DIR.iterdir():
        if item.is_dir() and item.name.isdigit():
            exams.append(item.name)
    
    return sorted(exams)


def get_topik_stats() -> Dict[str, Any]:
    """
    Get statistics about available TOPIK data
    
    Returns:
        Dictionary with statistics
    """
    exams = list_available_exams()
    stats = {
        "total_exams": len(exams),
        "exams": [],
        "directory": str(TOPIK_DIR)
    }
    
    for exam in exams:
        listening_data = load_topik_questions(exam, "listening")
        reading_data = load_topik_questions(exam, "reading")
        
        stats["exams"].append({
            "exam_number": exam,
            "listening_questions": listening_data.get("total", 0),
            "reading_questions": reading_data.get("total", 0)
        })
    
    return stats

