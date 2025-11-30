"""
Database Service - MySQL Connection for Korean Learning App
Connects to MySQL database to fetch vocabulary and other data
"""
import logging
from typing import List, Dict, Any, Optional
import pymysql
from pymysql.cursors import DictCursor
from config import settings

logger = logging.getLogger(__name__)

# Database connection pool
_connection_pool = None


def get_db_connection():
    """
    Get MySQL database connection
    Creates a new connection each time (simpler for now)
    """
    try:
        conn = pymysql.connect(
            host=getattr(settings, 'mysql_host', 'localhost'),
            port=getattr(settings, 'mysql_port', 3306),
            user=getattr(settings, 'mysql_user', 'root'),
            password=getattr(settings, 'mysql_password', ''),
            database=getattr(settings, 'mysql_database', 'koreanhwa'),
            charset='utf8mb4',
            cursorclass=DictCursor,
            autocommit=False  # Manual commit for transactions
        )
        return conn
    except Exception as e:
        logger.error(f"❌ Failed to connect to MySQL: {e}")
        raise


def get_vocabulary_by_lesson(lesson_id: int) -> List[Dict[str, Any]]:
    """
    Get vocabulary for a specific curriculum lesson
    
    Args:
        lesson_id: Curriculum lesson ID
        
    Returns:
        List of vocabulary items with korean, vietnamese, pronunciation, example
    """
    try:
        conn = get_db_connection()
        with conn.cursor() as cursor:
            # Use DISTINCT to avoid duplicates, and GROUP BY to get unique vocabulary
            # Keep the minimum ID for each unique combination of korean, vietnamese, pronunciation
            query = """
                SELECT 
                    MIN(id) as id,
                    korean,
                    vietnamese,
                    pronunciation,
                    example
                FROM curriculum_vocabulary
                WHERE curriculum_lesson_id = %s
                GROUP BY korean, vietnamese, pronunciation, example
                ORDER BY MIN(id) ASC
            """
            cursor.execute(query, (lesson_id,))
            results = cursor.fetchall()
            
            # Convert to list of dicts
            vocab_list = []
            seen = set()  # Track seen vocabulary to avoid duplicates
            for row in results:
                # Create a unique key from korean and vietnamese
                vocab_key = (row['korean'], row['vietnamese'])
                if vocab_key not in seen:
                    seen.add(vocab_key)
                    vocab_list.append({
                        'id': row['id'],
                        'korean': row['korean'],
                        'vietnamese': row['vietnamese'],
                        'pronunciation': row['pronunciation'] or '',
                        'example': row['example'] or ''
                    })
            
            logger.info(f"Fetched {len(vocab_list)} unique vocabulary items for lesson {lesson_id}")
            return vocab_list
            
    except Exception as e:
        logger.error(f"Error fetching vocabulary for lesson {lesson_id}: {e}")
        raise


def get_lesson_by_book_and_lesson_number(book_number: int, lesson_number: int) -> Optional[Dict[str, Any]]:
    """
    Get curriculum lesson by book number and lesson number
    
    Args:
        book_number: Book number (curriculum.book_number)
        lesson_number: Lesson number (curriculum_lessons.lesson_number)
        
    Returns:
        Lesson data with id, title, etc. or None if not found
    """
    try:
        conn = get_db_connection()
        with conn.cursor() as cursor:
            query = """
                SELECT 
                    cl.id,
                    cl.curriculum_id,
                    cl.title,
                    cl.level,
                    cl.duration,
                    cl.progress,
                    cl.lesson_number,
                    cl.video_url
                FROM curriculum_lessons cl
                INNER JOIN curriculum c ON cl.curriculum_id = c.id
                WHERE c.book_number = %s AND cl.lesson_number = %s
                LIMIT 1
            """
            cursor.execute(query, (book_number, lesson_number))
            result = cursor.fetchone()
            
            if result:
                return {
                    'id': result['id'],
                    'curriculum_id': result['curriculum_id'],
                    'title': result['title'],
                    'level': result['level'],
                    'duration': result['duration'],
                    'progress': result['progress'],
                    'lesson_number': result['lesson_number'],
                    'video_url': result['video_url']
                }
            else:
                logger.warning(f"Lesson not found: book={book_number}, lesson={lesson_number}")
                return None
                
    except Exception as e:
        logger.error(f"Error fetching lesson: {e}")
        raise


def get_grammar_by_lesson(lesson_id: int) -> List[Dict[str, Any]]:
    """
    Get grammar for a specific curriculum lesson
    
    Args:
        lesson_id: Curriculum lesson ID
        
    Returns:
        List of grammar items with title, explanation, examples
    """
    try:
        conn = get_db_connection()
        with conn.cursor() as cursor:
            # Get grammar
            query = """
                SELECT 
                    id,
                    title,
                    explanation
                FROM grammar
                WHERE curriculum_lesson_id = %s
                ORDER BY id ASC
            """
            cursor.execute(query, (lesson_id,))
            grammar_results = cursor.fetchall()
            
            grammar_list = []
            for row in grammar_results:
                grammar_id = row['id']
                
                # Get examples for this grammar
                examples_query = """
                    SELECT example_text
                    FROM grammar_examples
                    WHERE grammar_id = %s
                    ORDER BY id ASC
                """
                cursor.execute(examples_query, (grammar_id,))
                examples = [ex['example_text'] for ex in cursor.fetchall()]
                
                grammar_list.append({
                    'id': grammar_id,
                    'title': row['title'],
                    'explanation': row['explanation'],
                    'examples': examples
                })
            
            logger.info(f"Fetched {len(grammar_list)} grammar items for lesson {lesson_id}")
            return grammar_list
            
    except Exception as e:
        logger.error(f"Error fetching grammar for lesson {lesson_id}: {e}")
        raise


def save_lesson_progress(
    user_id: int,
    book_id: int,
    lesson_id: int,
    completed: bool = True
) -> bool:
    """
    Save lesson progress for a user
    
    Args:
        user_id: User ID
        book_id: Book number (curriculum.book_number)
        lesson_id: Lesson number (curriculum_lessons.lesson_number)
        completed: Whether the lesson is completed
        
    Returns:
        True if successful, False otherwise
    """
    try:
        conn = get_db_connection()
        with conn.cursor() as cursor:
            # Get curriculum ID from book_number
            curriculum_query = "SELECT id FROM curriculum WHERE book_number = %s"
            cursor.execute(curriculum_query, (book_id,))
            curriculum_result = cursor.fetchone()
            
            if not curriculum_result:
                logger.error(f"Curriculum not found for book_number: {book_id}")
                return False
            
            curriculum_id = curriculum_result['id']
            
            # Get or create curriculum progress
            progress_query = """
                SELECT id, completed_lessons 
                FROM curriculum_progress 
                WHERE user_id = %s AND curriculum_id = %s
            """
            cursor.execute(progress_query, (user_id, curriculum_id))
            progress = cursor.fetchone()
            
            if progress:
                # Update existing progress
                if completed:
                    # Check if this lesson is already counted
                    lesson_query = """
                        SELECT id FROM curriculum_lessons 
                        WHERE curriculum_id = %s AND lesson_number = %s
                    """
                    cursor.execute(lesson_query, (curriculum_id, lesson_id))
                    lesson_result = cursor.fetchone()
                    
                    if lesson_result:
                        # Update completed_lessons if this lesson is new
                        current_completed = progress['completed_lessons'] or 0
                        # Only increment if lesson is newly completed
                        # For simplicity, we'll set it to the lesson_id if it's higher
                        new_completed = max(current_completed, lesson_id)
                        
                        update_query = """
                            UPDATE curriculum_progress 
                            SET completed_lessons = %s,
                                is_completed = CASE 
                                    WHEN (SELECT COUNT(*) FROM curriculum_lessons WHERE curriculum_id = %s) <= %s 
                                    THEN TRUE 
                                    ELSE FALSE 
                                END
                            WHERE id = %s
                        """
                        cursor.execute(update_query, (new_completed, curriculum_id, new_completed, progress['id']))
            else:
                # Create new progress
                insert_query = """
                    INSERT INTO curriculum_progress 
                    (user_id, curriculum_id, completed_lessons, is_completed, is_locked)
                    VALUES (%s, %s, %s, %s, %s)
                """
                completed_lessons = lesson_id if completed else 0
                is_completed = False  # Will be set based on total lessons
                is_locked = book_id > 1  # Lock if not first book
                
                cursor.execute(insert_query, (
                    user_id, 
                    curriculum_id, 
                    completed_lessons, 
                    is_completed, 
                    is_locked
                ))
            
            conn.commit()
            logger.info(f"Saved progress: user={user_id}, book={book_id}, lesson={lesson_id}, completed={completed}")
            return True
            
    except Exception as e:
        logger.error(f"Error saving lesson progress: {e}")
        return False


def save_user_vocabulary(
    user_id: str,
    word: str,
    vietnamese: str,
    vi_word: str = "",
    vi_def: str = "",
    source: str = "lookup"
) -> bool:
    """
    Lưu từ vựng vào database cho user
    
    Args:
        user_id: User identifier
        word: Từ tiếng Hàn
        vietnamese: Nghĩa tiếng Việt
        vi_word: Từ tiếng Việt (nếu có)
        vi_def: Định nghĩa tiếng Việt (nếu có)
        source: Nguồn (lookup, file, gpt, etc.)
        
    Returns:
        True nếu lưu thành công, False nếu có lỗi
    """
    conn = None
    try:
        conn = get_db_connection()
        with conn.cursor() as cursor:
            # Kiểm tra xem bảng có tồn tại không, nếu không thì tạo
            create_table_query = """
            CREATE TABLE IF NOT EXISTS user_saved_vocabulary (
                id INT AUTO_INCREMENT PRIMARY KEY,
                user_id VARCHAR(255) NOT NULL,
                word VARCHAR(255) NOT NULL,
                vietnamese TEXT,
                vi_word VARCHAR(255),
                vi_def TEXT,
                source VARCHAR(50) DEFAULT 'lookup',
                saved_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                UNIQUE KEY unique_user_word (user_id, word),
                INDEX idx_user_id (user_id),
                INDEX idx_word (word)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
            """
            cursor.execute(create_table_query)
            
            # Kiểm tra xem từ đã được lưu chưa
            check_query = """
            SELECT id FROM user_saved_vocabulary 
            WHERE user_id = %s AND word = %s
            """
            cursor.execute(check_query, (user_id, word))
            existing = cursor.fetchone()
            
            if existing:
                # Cập nhật nếu đã tồn tại
                update_query = """
                UPDATE user_saved_vocabulary 
                SET vietnamese = %s, vi_word = %s, vi_def = %s, source = %s, saved_at = CURRENT_TIMESTAMP
                WHERE user_id = %s AND word = %s
                """
                cursor.execute(update_query, (vietnamese, vi_word, vi_def, source, user_id, word))
            else:
                # Thêm mới
                insert_query = """
                INSERT INTO user_saved_vocabulary (user_id, word, vietnamese, vi_word, vi_def, source)
                VALUES (%s, %s, %s, %s, %s, %s)
                """
                cursor.execute(insert_query, (user_id, word, vietnamese, vi_word, vi_def, source))
            
            conn.commit()
            logger.info(f"Saved vocabulary for user {user_id}: {word}")
            return True
            
    except Exception as e:
        logger.error(f"Error saving user vocabulary: {e}")
        if conn:
            conn.rollback()
        return False
    finally:
        if conn:
            conn.close()


def get_user_saved_vocabulary(user_id: str, limit: int = 100) -> List[Dict[str, Any]]:
    """
    Lấy danh sách từ vựng đã lưu của user
    
    Args:
        user_id: User identifier
        limit: Số lượng từ tối đa
        
    Returns:
        List of saved vocabulary items
    """
    try:
        conn = get_db_connection()
        with conn.cursor() as cursor:
            query = """
            SELECT id, word, vietnamese, vi_word, vi_def, source, saved_at
            FROM user_saved_vocabulary
            WHERE user_id = %s
            ORDER BY saved_at DESC
            LIMIT %s
            """
            cursor.execute(query, (user_id, limit))
            results = cursor.fetchall()
            
            vocab_list = []
            for row in results:
                vocab_list.append({
                    'id': row['id'],
                    'word': row['word'],
                    'vietnamese': row['vietnamese'],
                    'vi_word': row['vi_word'] or '',
                    'vi_def': row['vi_def'] or '',
                    'source': row['source'],
                    'saved_at': row['saved_at'].isoformat() if row['saved_at'] else None
                })
            
            logger.info(f"Fetched {len(vocab_list)} saved vocabulary items for user {user_id}")
            return vocab_list
            
    except Exception as e:
        logger.error(f"Error fetching user saved vocabulary: {e}")
        return []
    finally:
        if 'conn' in locals() and conn:
            conn.close()


def get_or_create_daily_folder(user_id: int, date_str: Optional[str] = None) -> Dict[str, Any]:
    """
    Lấy hoặc tạo folder theo ngày cho user
    
    Args:
        user_id: User ID (BIGINT)
        date_str: Ngày dạng YYYY-MM-DD (nếu None thì dùng ngày hôm nay)
        
    Returns:
        Dictionary với thông tin folder: id, name, icon, created_at
    """
    from datetime import datetime
    
    conn = None
    try:
        if date_str is None:
            date_str = datetime.now().strftime('%Y-%m-%d')
        
        folder_name = f"Từ vựng {date_str}"
        folder_icon = "📅"
        
        conn = get_db_connection()
        with conn.cursor() as cursor:
            # Kiểm tra xem folder đã tồn tại chưa
            check_query = """
            SELECT id, name, icon, created_at
            FROM vocabulary_folders
            WHERE user_id = %s AND name = %s
            LIMIT 1
            """
            cursor.execute(check_query, (user_id, folder_name))
            existing = cursor.fetchone()
            
            if existing:
                logger.info(f"Found existing daily folder for user {user_id}: {folder_name}")
                return {
                    'id': existing['id'],
                    'name': existing['name'],
                    'icon': existing['icon'],
                    'created_at': existing['created_at'].isoformat() if existing['created_at'] else None
                }
            
            # Tạo folder mới
            insert_query = """
            INSERT INTO vocabulary_folders (user_id, name, icon, created_at, updated_at)
            VALUES (%s, %s, %s, NOW(), NOW())
            """
            cursor.execute(insert_query, (user_id, folder_name, folder_icon))
            folder_id = cursor.lastrowid
            
            conn.commit()
            logger.info(f"Created daily folder for user {user_id}: {folder_name} (id: {folder_id})")
            
            return {
                'id': folder_id,
                'name': folder_name,
                'icon': folder_icon,
                'created_at': datetime.now().isoformat()
            }
            
    except Exception as e:
        logger.error(f"Error getting/creating daily folder: {e}")
        if conn:
            conn.rollback()
        raise
    finally:
        if conn:
            conn.close()


def add_word_to_folder(
    folder_id: int,
    korean: str,
    vietnamese: str,
    pronunciation: Optional[str] = None,
    example: Optional[str] = None
) -> Dict[str, Any]:
    """
    Thêm từ vựng vào folder
    
    Args:
        folder_id: Folder ID
        korean: Từ tiếng Hàn
        vietnamese: Nghĩa tiếng Việt
        pronunciation: Cách phát âm (optional)
        example: Ví dụ (optional)
        
    Returns:
        Dictionary với thông tin từ vựng đã thêm: id, korean, vietnamese, etc.
    """
    conn = None
    try:
        conn = get_db_connection()
        with conn.cursor() as cursor:
            # Kiểm tra xem từ đã tồn tại trong folder chưa
            check_query = """
            SELECT id FROM vocabulary_words
            WHERE folder_id = %s AND korean = %s AND vietnamese = %s
            LIMIT 1
            """
            cursor.execute(check_query, (folder_id, korean, vietnamese))
            existing = cursor.fetchone()
            
            if existing:
                logger.info(f"Word already exists in folder {folder_id}: {korean}")
                # Cập nhật thông tin
                update_query = """
                UPDATE vocabulary_words
                SET pronunciation = %s, example = %s, updated_at = NOW()
                WHERE id = %s
                """
                cursor.execute(update_query, (pronunciation, example, existing['id']))
                word_id = existing['id']
            else:
                # Thêm từ mới
                insert_query = """
                INSERT INTO vocabulary_words (folder_id, korean, vietnamese, pronunciation, example, is_learned, created_at, updated_at)
                VALUES (%s, %s, %s, %s, %s, FALSE, NOW(), NOW())
                """
                cursor.execute(insert_query, (folder_id, korean, vietnamese, pronunciation, example))
                word_id = cursor.lastrowid
            
            conn.commit()
            logger.info(f"Added word to folder {folder_id}: {korean}")
            
            return {
                'id': word_id,
                'korean': korean,
                'vietnamese': vietnamese,
                'pronunciation': pronunciation or '',
                'example': example or '',
                'is_learned': False
            }
            
    except Exception as e:
        logger.error(f"Error adding word to folder: {e}")
        if conn:
            conn.rollback()
        raise
    finally:
        if conn:
            conn.close()