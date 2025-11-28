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

