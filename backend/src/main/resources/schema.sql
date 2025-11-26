-- KoreanHwa Database Schema
-- MySQL Database Schema with BIGINT AUTO_INCREMENT (equivalent to BIGSERIAL)

-- Users Table
CREATE TABLE IF NOT EXISTS users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(100) NOT NULL UNIQUE,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    name VARCHAR(255) NOT NULL,
    avatar VARCHAR(500),
    level VARCHAR(50),
    points INT DEFAULT 0,
    streak_days INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Courses Table
CREATE TABLE IF NOT EXISTS courses (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(500) NOT NULL,
    instructor VARCHAR(255) NOT NULL,
    level VARCHAR(100) NOT NULL,
    rating DECIMAL(3,2) DEFAULT 0.0,
    students INT DEFAULT 0,
    lessons INT DEFAULT 0,
    duration_start DATE,
    duration_end DATE,
    price VARCHAR(100),
    image VARCHAR(500),
    accent_color VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Course Enrollments Table
-- FIXED: Added completed_lessons field (merged from CourseCard)
CREATE TABLE IF NOT EXISTS course_enrollments (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    course_id BIGINT NOT NULL,
    progress DECIMAL(5,2) DEFAULT 0.0,
    is_enrolled BOOLEAN DEFAULT TRUE,
    completed_lessons INT DEFAULT 0,
    enrolled_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE,
    UNIQUE KEY unique_enrollment (user_id, course_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Curriculum Table (replaces textbooks)
CREATE TABLE IF NOT EXISTS curriculum (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    book_number INT NOT NULL UNIQUE,
    title VARCHAR(500) NOT NULL,
    subtitle VARCHAR(255),
    total_lessons INT DEFAULT 0,
    color VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Curriculum Progress Table (replaces textbook_progress)
CREATE TABLE IF NOT EXISTS curriculum_progress (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    curriculum_id BIGINT NOT NULL,
    completed_lessons INT DEFAULT 0,
    is_completed BOOLEAN DEFAULT FALSE,
    is_locked BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (curriculum_id) REFERENCES curriculum(id) ON DELETE CASCADE,
    UNIQUE KEY unique_curriculum_progress (user_id, curriculum_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Curriculum Lessons Table (lessons for curriculum/textbook)
CREATE TABLE IF NOT EXISTS curriculum_lessons (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    curriculum_id BIGINT NOT NULL,
    title VARCHAR(500) NOT NULL,
    level VARCHAR(100),
    duration VARCHAR(50),
    progress INT DEFAULT 0,
    lesson_number INT,
    video_url VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (curriculum_id) REFERENCES curriculum(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Course Lessons Table (lessons for instructor courses)
CREATE TABLE IF NOT EXISTS course_lessons (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    course_id BIGINT NOT NULL,
    title VARCHAR(500) NOT NULL,
    level VARCHAR(100),
    duration VARCHAR(50),
    progress INT DEFAULT 0,
    lesson_number INT,
    video_url VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================================
-- VOCABULARY TABLES - 3 LOẠI VOCABULARY KHÁC NHAU:
-- ============================================================================
-- 1. CurriculumVocabulary: Vocabulary trong giáo trình (chuẩn hóa, không phụ thuộc giảng viên)
-- 2. CourseVocabulary: Vocabulary trong khóa học với thầy cô (do giảng viên quản lý)
-- 3. VocabularyFolder/Word: Vocabulary do người dùng tự tạo và quản lý
-- ============================================================================

-- Curriculum Vocabulary Table
-- Vocabulary trong giáo trình (chuẩn hóa, gắn với CurriculumLesson)
-- Được quản lý bởi hệ thống, không phụ thuộc vào giảng viên cụ thể
CREATE TABLE IF NOT EXISTS curriculum_vocabulary (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    curriculum_lesson_id BIGINT NOT NULL,
    korean VARCHAR(500) NOT NULL,
    vietnamese VARCHAR(500) NOT NULL,
    pronunciation VARCHAR(500),
    example TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (curriculum_lesson_id) REFERENCES curriculum_lessons(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Course Vocabulary Table
-- Vocabulary trong khóa học với thầy cô (do giảng viên quản lý, gắn với CourseLesson)
-- Được tạo/sửa bởi giảng viên, thuộc về khóa học cụ thể
CREATE TABLE IF NOT EXISTS course_vocabulary (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    course_lesson_id BIGINT NOT NULL,
    korean VARCHAR(500) NOT NULL,
    vietnamese VARCHAR(500) NOT NULL,
    pronunciation VARCHAR(500),
    example TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (course_lesson_id) REFERENCES course_lessons(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Grammar Table (can be linked to either curriculum_lesson or course_lesson)
CREATE TABLE IF NOT EXISTS grammar (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    curriculum_lesson_id BIGINT,
    course_lesson_id BIGINT,
    title VARCHAR(500) NOT NULL,
    explanation TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (curriculum_lesson_id) REFERENCES curriculum_lessons(id) ON DELETE CASCADE,
    FOREIGN KEY (course_lesson_id) REFERENCES course_lessons(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Grammar Examples Table
CREATE TABLE IF NOT EXISTS grammar_examples (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    grammar_id BIGINT NOT NULL,
    example_text TEXT NOT NULL,
    FOREIGN KEY (grammar_id) REFERENCES grammar(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Exercises Table (can be linked to either curriculum_lesson or course_lesson)
CREATE TABLE IF NOT EXISTS exercises (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    curriculum_lesson_id BIGINT,
    course_lesson_id BIGINT,
    type VARCHAR(50) NOT NULL,
    question TEXT NOT NULL,
    answer VARCHAR(500),
    correct_index INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (curriculum_lesson_id) REFERENCES curriculum_lessons(id) ON DELETE CASCADE,
    FOREIGN KEY (course_lesson_id) REFERENCES course_lessons(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Exercise Options Table
CREATE TABLE IF NOT EXISTS exercise_options (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    exercise_id BIGINT NOT NULL,
    option_text VARCHAR(500) NOT NULL,
    option_order INT NOT NULL,
    FOREIGN KEY (exercise_id) REFERENCES exercises(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Rankings Table
CREATE TABLE IF NOT EXISTS rankings (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    points INT DEFAULT 0,
    days INT DEFAULT 0,
    color VARCHAR(50),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY unique_user_ranking (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Achievements Table
CREATE TABLE IF NOT EXISTS achievements (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    icon_label VARCHAR(10) NOT NULL,
    title VARCHAR(500) NOT NULL,
    subtitle VARCHAR(500),
    color VARCHAR(50),
    target_count INT DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- User Achievements Table
CREATE TABLE IF NOT EXISTS user_achievements (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    achievement_id BIGINT NOT NULL,
    current_count INT DEFAULT 0,
    is_completed BOOLEAN DEFAULT FALSE,
    progress DECIMAL(5,2) DEFAULT 0.0,
    completed_at TIMESTAMP NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (achievement_id) REFERENCES achievements(id) ON DELETE CASCADE,
    UNIQUE KEY unique_user_achievement (user_id, achievement_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Blog Posts Table
CREATE TABLE IF NOT EXISTS blog_posts (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(500) NOT NULL,
    content TEXT NOT NULL,
    author_id BIGINT NOT NULL,
    skill VARCHAR(100),
    likes INT DEFAULT 0,
    comments INT DEFAULT 0,
    views INT DEFAULT 0,
    featured_image VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (author_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Blog Tags Table
CREATE TABLE IF NOT EXISTS blog_tags (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    post_id BIGINT NOT NULL,
    tag VARCHAR(100) NOT NULL,
    FOREIGN KEY (post_id) REFERENCES blog_posts(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Blog Likes Table
CREATE TABLE IF NOT EXISTS blog_likes (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    post_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    FOREIGN KEY (post_id) REFERENCES blog_posts(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY unique_blog_like (post_id, user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Blog Comments Table
CREATE TABLE IF NOT EXISTS blog_comments (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    post_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    content TEXT NOT NULL,
    likes INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (post_id) REFERENCES blog_posts(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Blog Comment Likes Table
CREATE TABLE IF NOT EXISTS blog_comment_likes (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    comment_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    FOREIGN KEY (comment_id) REFERENCES blog_comments(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY unique_comment_like (comment_id, user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Dashboard Stats Table (aggregated data per user)
CREATE TABLE IF NOT EXISTS dashboard_stats (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    total_courses INT DEFAULT 0,
    completed_courses INT DEFAULT 0,
    total_videos INT DEFAULT 0,
    watched_videos INT DEFAULT 0,
    total_exams INT DEFAULT 0,
    completed_exams INT DEFAULT 0,
    total_watch_time VARCHAR(50),
    completed_watch_time VARCHAR(50),
    last_access TIMESTAMP,
    end_date DATE,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY unique_user_stats (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Competition Categories Table
CREATE TABLE IF NOT EXISTS competition_categories (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    category_id VARCHAR(50) NOT NULL UNIQUE,
    name VARCHAR(255) NOT NULL,
    icon_name VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Speak Practice Stats Table
CREATE TABLE IF NOT EXISTS speak_practice_stats (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    label VARCHAR(100) NOT NULL,
    value VARCHAR(100) NOT NULL,
    subtitle VARCHAR(255),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Speak Practice Missions Table
CREATE TABLE IF NOT EXISTS speak_practice_missions (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    title VARCHAR(500) NOT NULL,
    subtitle VARCHAR(500),
    icon_name VARCHAR(100),
    color VARCHAR(50),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Tasks Table
CREATE TABLE IF NOT EXISTS tasks (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    title VARCHAR(255) NOT NULL,
    icon_name VARCHAR(100),
    color VARCHAR(50),
    progress_color VARCHAR(50),
    progress_percent DECIMAL(5,2) DEFAULT 0.0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Lesson Cards Table
-- Can reference either curriculum_lesson or course_lesson
CREATE TABLE IF NOT EXISTS lesson_cards (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    curriculum_lesson_id BIGINT,
    course_lesson_id BIGINT,
    date VARCHAR(50),
    tag VARCHAR(100),
    accent_color VARCHAR(50),
    background_color VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (curriculum_lesson_id) REFERENCES curriculum_lessons(id) ON DELETE CASCADE,
    FOREIGN KEY (course_lesson_id) REFERENCES course_lessons(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Course Cards Table
-- FIXED: Added course_id FK, removed duplicate fields (title, progress, lessons, accent_color)
-- FIXED: These fields are now accessed via course relationship or CourseEnrollment
-- NOTE: This table is deprecated - use CourseEnrollment instead
CREATE TABLE IF NOT EXISTS course_cards (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    course_id BIGINT NOT NULL,
    completed INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Skill Progress Table
CREATE TABLE IF NOT EXISTS skill_progress (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    label VARCHAR(100) NOT NULL,
    percent DECIMAL(5,2) DEFAULT 0.0,
    color VARCHAR(50),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Materials Table
CREATE TABLE IF NOT EXISTS materials (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(500) NOT NULL,
    description TEXT,
    level VARCHAR(50) NOT NULL,
    skill VARCHAR(50) NOT NULL,
    type VARCHAR(50) NOT NULL,
    thumbnail VARCHAR(10),
    downloads INT DEFAULT 0,
    rating DECIMAL(3,2) DEFAULT 0.0,
    size VARCHAR(50),
    points INT DEFAULT 0,
    is_featured BOOLEAN DEFAULT FALSE,
    duration VARCHAR(50),
    pdf_url VARCHAR(500),
    video_url VARCHAR(500),
    audio_url VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Material Downloads Table (track user downloads)
CREATE TABLE IF NOT EXISTS material_downloads (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    material_id BIGINT NOT NULL,
    downloaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (material_id) REFERENCES materials(id) ON DELETE CASCADE,
    UNIQUE KEY unique_material_download (user_id, material_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Competitions Table
CREATE TABLE IF NOT EXISTS competitions (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(500) NOT NULL,
    description TEXT,
    category_id VARCHAR(50),
    start_date TIMESTAMP NULL DEFAULT NULL,
    end_date TIMESTAMP NULL DEFAULT NULL,
    status VARCHAR(50) DEFAULT 'upcoming',
    prize VARCHAR(500),
    participants INT DEFAULT 0,
    image VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES competition_categories(category_id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Competition Participants Table
CREATE TABLE IF NOT EXISTS competition_participants (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    competition_id BIGINT NOT NULL,
    score INT DEFAULT 0,
    rank INT,
    submitted_at TIMESTAMP NULL DEFAULT NULL,
    status VARCHAR(50) DEFAULT 'registered',
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (competition_id) REFERENCES competitions(id) ON DELETE CASCADE,
    UNIQUE KEY unique_competition_participant (user_id, competition_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Competition Questions Table
CREATE TABLE IF NOT EXISTS competition_questions (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    competition_id BIGINT NOT NULL,
    question_text TEXT NOT NULL,
    question_type VARCHAR(50),
    correct_answer VARCHAR(500),
    points INT DEFAULT 1,
    question_order INT,
    FOREIGN KEY (competition_id) REFERENCES competitions(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Competition Question Options Table
CREATE TABLE IF NOT EXISTS competition_question_options (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    question_id BIGINT NOT NULL,
    option_text VARCHAR(500) NOT NULL,
    option_order INT NOT NULL,
    is_correct BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (question_id) REFERENCES competition_questions(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Competition Submissions Table
CREATE TABLE IF NOT EXISTS competition_submissions (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    competition_id BIGINT NOT NULL,
    question_id BIGINT NOT NULL,
    answer VARCHAR(500),
    is_correct BOOLEAN DEFAULT FALSE,
    submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (competition_id) REFERENCES competitions(id) ON DELETE CASCADE,
    FOREIGN KEY (question_id) REFERENCES competition_questions(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Vocabulary Folders Table
-- Thư mục từ vựng của người dùng (user tự tạo và quản lý)
-- Người dùng có thể tạo các thư mục để tổ chức từ vựng cá nhân
-- KHÔNG gắn với lesson nào, hoàn toàn do người dùng quản lý
CREATE TABLE IF NOT EXISTS vocabulary_folders (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    name VARCHAR(255) NOT NULL,
    icon VARCHAR(10) DEFAULT '📁',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Vocabulary Words Table
-- Từ vựng của người dùng (user tự tạo, thuộc về VocabularyFolder)
-- Người dùng có thể thêm, sửa, xóa các từ vựng này để học tập cá nhân
-- KHÔNG gắn với lesson nào, hoàn toàn do người dùng quản lý
CREATE TABLE IF NOT EXISTS vocabulary_words (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    folder_id BIGINT NOT NULL,
    korean VARCHAR(500) NOT NULL,
    vietnamese VARCHAR(500) NOT NULL,
    pronunciation VARCHAR(500),
    example TEXT,
    is_learned BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (folder_id) REFERENCES vocabulary_folders(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;