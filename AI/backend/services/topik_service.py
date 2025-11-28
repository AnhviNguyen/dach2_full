"""
TOPIK Service - Load and manage TOPIK exam questions

TOPIK 1 có 2 phần thi chính:
===========================================
1. PHẦN NGHE (LISTENING):
   - Số lượng câu hỏi: 30 câu (cố định cho TOPIK 1)
   - Mỗi câu hỏi có file audio riêng
   - Audio URL được lưu trong context.audio
   - Format: topik{exam_number}_listen_questions.json
   - Ví dụ: topik35_listen_questions.json

2. PHẦN ĐỌC (READING):
   - Số lượng câu hỏi: 40 câu (cố định cho TOPIK 1)
   - KHÔNG có audio (chỉ text)
   - Format: topik{exam_number}_reading_questions.json
   - Ví dụ: topik35_reading_questions.json

CẤU TRÚC THƯ MỤC:
===========================================
TOPIK_DIR/
  ├── 35/
  │   ├── topik35_listen_questions.json (30 câu, có audio)
  │   └── topik35_reading_questions.json (40 câu, không audio)
  ├── 36/
  │   ├── topik36_listen_questions.json
  │   └── topik36_reading_questions.json
  └── 37/
      ├── topik37_listen_questions.json
      └── topik37_reading_questions.json

CẤU TRÚC JSON:
===========================================
{
  "url": "...",
  "total": 30,  // Số lượng câu hỏi (30 cho listening, 40 cho reading)
  "questions": [
    {
      "question_id": "...",
      "number": 1,  // Số thứ tự câu hỏi (1-30 cho listening, 1-40 cho reading)
      "prompt": "...",
      "answers": [...],
      "context": {
        "audio": "https://...",  // CHỈ CÓ trong listening questions
        "images": []
      }
    }
  ]
}
"""
import json
import logging
from pathlib import Path
from typing import List, Dict, Optional, Any, Literal

logger = logging.getLogger(__name__)

# Path to TOPIK directory
# Cấu trúc: TOPIK_DIR/{exam_number}/topik{exam_number}_listen_questions.json
#           TOPIK_DIR/{exam_number}/topik{exam_number}_reading_questions.json
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
        Dictionary containing questions data with structure:
        {
            "url": "...",
            "total": 30 or 40,  // 30 cho listening, 40 cho reading
            "question_type": "listening" or "reading",
            "has_audio": True/False,  // True cho listening, False cho reading
            "questions": [...]
        }
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
            "total": 0,
            "question_type": question_type,
            "has_audio": question_type == "listening"
        }
    
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        # Add metadata
        data["question_type"] = question_type
        data["has_audio"] = question_type == "listening"
        
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
        logger.info(f"✅ Loaded TOPIK {exam_number} {question_type}: {data.get('total', 0)} questions")
        return data
    except Exception as e:
        logger.error(f"Error loading TOPIK questions: {e}", exc_info=True)
        return {
            "error": str(e),
            "questions": [],
            "total": 0,
            "question_type": question_type,
            "has_audio": question_type == "listening"
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
        Dictionary with statistics including:
        - Total exams available
        - For each exam: listening questions (30) and reading questions (40)
        - Total questions across all exams
    """
    exams = list_available_exams()
    stats = {
        "total_exams": len(exams),
        "exams": [],
        "directory": str(TOPIK_DIR),
        "total_listening_questions": 0,
        "total_reading_questions": 0,
        "question_counts": {
            "listening": 30,  # TOPIK 1 listening has 30 questions
            "reading": 40     # TOPIK 1 reading has 40 questions
        }
    }
    
    for exam in exams:
        listening_data = load_topik_questions(exam, "listening")
        reading_data = load_topik_questions(exam, "reading")
        
        listening_count = listening_data.get("total", 0)
        reading_count = reading_data.get("total", 0)
        
        stats["total_listening_questions"] += listening_count
        stats["total_reading_questions"] += reading_count
        
        stats["exams"].append({
            "exam_number": exam,
            "listening_questions": listening_count,  # Should be 30 for TOPIK 1
            "reading_questions": reading_count,      # Should be 40 for TOPIK 1
            "has_listening_audio": listening_data.get("has_audio", False),
            "has_reading_audio": reading_data.get("has_audio", False)
        })
    
    stats["total_questions"] = stats["total_listening_questions"] + stats["total_reading_questions"]
    
    return stats

