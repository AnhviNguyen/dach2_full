"""
Vocabulary Router - Endpoints for vocabulary learning methods
Provides flashcard, match, pronunciation, listen_write, quiz, and test modes
Also provides word lookup and save functionality
"""
from fastapi import APIRouter, HTTPException, Query, Form
from typing import List, Dict, Any, Optional
import logging
from services import database_service, openai_service
from services.error_handlers import handle_openai_error
from services.vocabulary_lookup_service import lookup_word
import random

logger = logging.getLogger(__name__)

router = APIRouter(
    prefix="/api/vocabulary",
    tags=["vocabulary"]
)


@router.get("/learning-methods")
async def get_vocabulary_learning_methods(
    book_id: int = Query(..., description="Book number"),
    lesson_id: int = Query(..., description="Lesson number")
) -> Dict[str, Any]:
    """
    Get vocabulary learning methods for a specific lesson
    
    Returns vocabulary data formatted for different learning modes:
    - flashcard: List of vocabulary cards
    - match: Korean-Vietnamese pairs for matching game
    - pronunciation: Vocabulary with pronunciation guides
    - listen_write: Vocabulary for listen and write practice
    - quiz: Multiple choice questions
    - test: Comprehensive test questions
    
    Args:
        book_id: Book number (curriculum.book_number)
        lesson_id: Lesson number (curriculum_lessons.lesson_number)
        
    Returns:
        Dictionary with vocabulary data for all learning methods
    """
    try:
        # Get lesson by book_id and lesson_id
        lesson = database_service.get_lesson_by_book_and_lesson_number(book_id, lesson_id)
        
        if not lesson:
            raise HTTPException(
                status_code=404,
                detail=f"Lesson not found: book={book_id}, lesson={lesson_id}"
            )
        
        lesson_db_id = lesson['id']
        
        # Get vocabulary for this lesson
        vocab_list = database_service.get_vocabulary_by_lesson(lesson_db_id)
        
        if not vocab_list:
            raise HTTPException(
                status_code=404,
                detail=f"No vocabulary found for lesson: book={book_id}, lesson={lesson_id}"
            )
        
        # Format vocabulary for different learning methods
        result = {
            'book_id': book_id,
            'lesson_id': lesson_id,
            'lesson_title': lesson['title'],
            'total_words': len(vocab_list),
            'flashcard': _format_flashcard(vocab_list),
            'match': _format_match(vocab_list),
            'pronunciation': _format_pronunciation(vocab_list),
            'listen_write': _format_listen_write(vocab_list),
            'quiz': _format_quiz(vocab_list),
            'test': _format_test(vocab_list)
        }
        
        logger.info(f"Generated learning methods for book={book_id}, lesson={lesson_id}, words={len(vocab_list)}")
        return result
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error in get_vocabulary_learning_methods: {e}")
        raise HTTPException(
            status_code=500,
            detail=f"Failed to get vocabulary learning methods: {str(e)}"
        )


@router.post("/test/submit")
async def submit_vocabulary_test(
    book_id: int,
    lesson_id: int,
    answers: Dict[str, str]  # question_id -> answer
) -> Dict[str, Any]:
    """
    Submit vocabulary test and get results
    
    Args:
        book_id: Book number
        lesson_id: Lesson number
        answers: Dictionary mapping question IDs to user answers
        
    Returns:
        Test results with score, percentage, and whether user can proceed (>=80%)
    """
    try:
        # Get lesson and vocabulary
        lesson = database_service.get_lesson_by_book_and_lesson_number(book_id, lesson_id)
        if not lesson:
            raise HTTPException(status_code=404, detail="Lesson not found")
        
        vocab_list = database_service.get_vocabulary_by_lesson(lesson['id'])
        if not vocab_list:
            raise HTTPException(status_code=404, detail="Vocabulary not found")
        
        # Calculate score
        correct_count = 0
        total_questions = len(answers)
        
        for vocab in vocab_list:
            question_id = f"q_{vocab['id']}"
            if question_id in answers:
                user_answer = answers[question_id].strip()
                correct_answer = vocab['vietnamese'].strip()
                if user_answer.lower() == correct_answer.lower():
                    correct_count += 1
        
        score_percentage = (correct_count / total_questions * 100) if total_questions > 0 else 0
        can_proceed = score_percentage >= 80.0
        
        result = {
            'book_id': book_id,
            'lesson_id': lesson_id,
            'total_questions': total_questions,
            'correct_answers': correct_count,
            'wrong_answers': total_questions - correct_count,
            'score_percentage': round(score_percentage, 2),
            'can_proceed': can_proceed,
            'message': 'Chúc mừng! Bạn có thể chuyển sang bài tiếp theo.' if can_proceed else 'Hãy luyện tập thêm để đạt 80% trở lên.'
        }
        
        logger.info(f"Test submitted: book={book_id}, lesson={lesson_id}, score={score_percentage}%")
        return result
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error in submit_vocabulary_test: {e}")
        raise HTTPException(
            status_code=500,
            detail=f"Failed to submit test: {str(e)}"
        )


def _format_flashcard(vocab_list: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
    """Format vocabulary for flashcard mode"""
    return [
        {
            'id': v['id'],
            'front': v['korean'],
            'back': {
                'vietnamese': v['vietnamese'],
                'pronunciation': v['pronunciation'],
                'example': v['example']
            }
        }
        for v in vocab_list
    ]


def _format_match(vocab_list: List[Dict[str, Any]]) -> Dict[str, Any]:
    """Format vocabulary for match mode (nối từ)"""
    korean_cards = [
        {'id': f"k_{v['id']}", 'text': v['korean'], 'match_id': v['id']}
        for v in vocab_list
    ]
    vietnamese_cards = [
        {'id': f"v_{v['id']}", 'text': v['vietnamese'], 'match_id': v['id']}
        for v in vocab_list
    ]
    
    # Shuffle for game
    random.shuffle(korean_cards)
    random.shuffle(vietnamese_cards)
    
    return {
        'korean_cards': korean_cards,
        'vietnamese_cards': vietnamese_cards,
        'pairs': {v['id']: {'korean': v['korean'], 'vietnamese': v['vietnamese']} for v in vocab_list}
    }


def _format_pronunciation(vocab_list: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
    """Format vocabulary for pronunciation mode"""
    return [
        {
            'id': v['id'],
            'korean': v['korean'],
            'vietnamese': v['vietnamese'],
            'pronunciation': v['pronunciation'],
            'example': v['example']
        }
        for v in vocab_list
    ]


def _format_listen_write(vocab_list: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
    """Format vocabulary for listen_write mode"""
    return [
        {
            'id': v['id'],
            'korean': v['korean'],
            'vietnamese': v['vietnamese'],
            'pronunciation': v['pronunciation'],
            'hint': v['korean'][0] if v['korean'] else ''  # First character as hint
        }
        for v in vocab_list
    ]


def _format_quiz(vocab_list: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
    """Format vocabulary for quiz mode (multiple choice)"""
    quiz_questions = []
    
    for vocab in vocab_list:
        # Get 3 random wrong answers
        wrong_options = [
            v['vietnamese'] for v in random.sample(
                [v for v in vocab_list if v['id'] != vocab['id']],
                min(3, len(vocab_list) - 1)
            )
        ]
        
        # Combine with correct answer and shuffle
        options = wrong_options + [vocab['vietnamese']]
        random.shuffle(options)
        
        correct_index = options.index(vocab['vietnamese'])
        
        quiz_questions.append({
            'id': f"quiz_{vocab['id']}",
            'question': f"Từ '{vocab['korean']}' có nghĩa là gì?",
            'options': options,
            'correct_index': correct_index,
            'correct_answer': vocab['vietnamese'],
            'pronunciation': vocab['pronunciation'],
            'example': vocab['example']
        })
    
    return quiz_questions


def _format_test(vocab_list: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
    """Format vocabulary for test mode (kiểm tra)"""
    test_questions = []
    
    for vocab in vocab_list:
        test_questions.append({
            'id': f"q_{vocab['id']}",
            'question': f"Từ '{vocab['korean']}' ({vocab['pronunciation']}) có nghĩa là gì?",
            'correct_answer': vocab['vietnamese'],
            'type': 'text_input'  # User types the answer
        })
    
    return test_questions


# ===== WORD LOOKUP & SAVE ENDPOINTS =====

@router.get("/lookup")
async def lookup_vocabulary_word(
    word: str = Query(..., description="Từ tiếng Hàn cần tra")
) -> Dict[str, Any]:
    """
    Tra từ vựng tiếng Hàn
    
    Tìm từ trong file jsonl trước, nếu không tìm thấy thì dùng GPT để tra.
    
    Args:
        word: Từ tiếng Hàn cần tra
        
    Returns:
        Dictionary với thông tin từ vựng:
        - word: Từ tiếng Hàn
        - vietnamese: Nghĩa tiếng Việt
        - vi_word: Từ tiếng Việt (nếu có)
        - vi_def: Định nghĩa (nếu có)
        - source: Nguồn ('file' hoặc 'gpt')
    """
    try:
        if not word or not word.strip():
            raise HTTPException(
                status_code=400,
                detail="Word parameter is required"
            )
        
        result = lookup_word(word.strip())
        
        logger.info(f"Looked up word: {word}, source: {result.get('source', 'unknown')}")
        return {
            "success": True,
            "data": result
        }
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error in lookup_vocabulary_word: {e}")
        raise HTTPException(
            status_code=500,
            detail=f"Failed to lookup word: {str(e)}"
        )


@router.post("/lookup")
async def lookup_vocabulary_word_post(
    word: str = Form(..., description="Từ tiếng Hàn cần tra")
) -> Dict[str, Any]:
    """
    Tra từ vựng tiếng Hàn (POST method)
    
    Tìm từ trong file jsonl trước, nếu không tìm thấy thì dùng GPT để tra.
    
    Args:
        word: Từ tiếng Hàn cần tra
        
    Returns:
        Dictionary với thông tin từ vựng
    """
    return await lookup_vocabulary_word(word=word)


@router.post("/save")
async def save_vocabulary_word(
    user_id: str = Form(..., description="User ID"),
    word: str = Form(..., description="Từ tiếng Hàn"),
    vietnamese: str = Form(..., description="Nghĩa tiếng Việt"),
    vi_word: str = Form(default="", description="Từ tiếng Việt (optional)"),
    vi_def: str = Form(default="", description="Định nghĩa (optional)"),
    source: str = Form(default="lookup", description="Nguồn (lookup, file, gpt, etc.)")
) -> Dict[str, Any]:
    """
    Lưu từ vựng vào database cho user
    
    Args:
        user_id: User identifier
        word: Từ tiếng Hàn
        vietnamese: Nghĩa tiếng Việt
        vi_word: Từ tiếng Việt (optional)
        vi_def: Định nghĩa (optional)
        source: Nguồn (optional, default: 'lookup')
        
    Returns:
        Success confirmation
    """
    try:
        if not word or not word.strip():
            raise HTTPException(
                status_code=400,
                detail="Word is required"
            )
        
        if not vietnamese or not vietnamese.strip():
            raise HTTPException(
                status_code=400,
                detail="Vietnamese translation is required"
            )
        
        success = database_service.save_user_vocabulary(
            user_id=user_id,
            word=word.strip(),
            vietnamese=vietnamese.strip(),
            vi_word=vi_word.strip() if vi_word else "",
            vi_def=vi_def.strip() if vi_def else "",
            source=source.strip() if source else "lookup"
        )
        
        if not success:
            raise HTTPException(
                status_code=500,
                detail="Failed to save vocabulary"
            )
        
        logger.info(f"Saved vocabulary for user {user_id}: {word}")
        return {
            "success": True,
            "message": "Từ vựng đã được lưu thành công",
            "word": word,
            "user_id": user_id
        }
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error in save_vocabulary_word: {e}")
        raise HTTPException(
            status_code=500,
            detail=f"Failed to save vocabulary: {str(e)}"
        )


@router.get("/saved")
async def get_saved_vocabulary(
    user_id: str = Query(..., description="User ID"),
    limit: int = Query(default=100, description="Số lượng từ tối đa")
) -> Dict[str, Any]:
    """
    Lấy danh sách từ vựng đã lưu của user
    
    Args:
        user_id: User identifier
        limit: Số lượng từ tối đa (default: 100)
        
    Returns:
        Dictionary với danh sách từ vựng đã lưu
    """
    try:
        vocab_list = database_service.get_user_saved_vocabulary(user_id, limit)
        
        return {
            "success": True,
            "user_id": user_id,
            "total": len(vocab_list),
            "vocabulary": vocab_list
        }
        
    except Exception as e:
        logger.error(f"Error in get_saved_vocabulary: {e}")
        raise HTTPException(
            status_code=500,
            detail=f"Failed to get saved vocabulary: {str(e)}"
        )


@router.post("/add-to-daily-folder")
async def add_word_to_daily_folder(
    user_id: int = Form(..., description="User ID (BIGINT)"),
    word: str = Form(..., description="Từ tiếng Hàn"),
    vietnamese: str = Form(..., description="Nghĩa tiếng Việt"),
    pronunciation: str = Form(default="", description="Cách phát âm (optional)"),
    example: str = Form(default="", description="Ví dụ (optional)"),
    date_str: Optional[str] = Form(default=None, description="Ngày YYYY-MM-DD (optional, mặc định hôm nay)")
) -> Dict[str, Any]:
    """
    Thêm từ vựng vào folder theo ngày (tự động tạo folder nếu chưa có)
    
    Args:
        user_id: User ID (BIGINT)
        word: Từ tiếng Hàn
        vietnamese: Nghĩa tiếng Việt
        pronunciation: Cách phát âm (optional)
        example: Ví dụ (optional)
        date_str: Ngày YYYY-MM-DD (optional, mặc định hôm nay)
        
    Returns:
        Success confirmation với thông tin folder và từ vựng
    """
    try:
        if not word or not word.strip():
            raise HTTPException(
                status_code=400,
                detail="Word is required"
            )
        
        if not vietnamese or not vietnamese.strip():
            raise HTTPException(
                status_code=400,
                detail="Vietnamese translation is required"
            )
        
        # Lấy hoặc tạo folder theo ngày
        folder = database_service.get_or_create_daily_folder(
            user_id=user_id,
            date_str=date_str
        )
        
        # Thêm từ vào folder
        vocab = database_service.add_word_to_folder(
            folder_id=folder['id'],
            korean=word.strip(),
            vietnamese=vietnamese.strip(),
            pronunciation=pronunciation.strip() if pronunciation else None,
            example=example.strip() if example else None
        )
        
        logger.info(f"Added word to daily folder: user={user_id}, folder={folder['name']}, word={word}")
        return {
            "success": True,
            "message": "Từ vựng đã được thêm vào folder theo ngày",
            "folder": folder,
            "vocabulary": vocab
        }
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error in add_word_to_daily_folder: {e}")
        raise HTTPException(
            status_code=500,
            detail=f"Failed to add word to daily folder: {str(e)}"
        )

