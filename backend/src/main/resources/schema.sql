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
CREATE TABLE IF NOT EXISTS course_enrollments (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    course_id BIGINT NOT NULL,
    progress DECIMAL(5,4) DEFAULT 0.0,
    is_enrolled BOOLEAN DEFAULT TRUE,
    enrolled_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE,
    UNIQUE KEY unique_enrollment (user_id, course_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Textbooks Table
CREATE TABLE IF NOT EXISTS textbooks (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    book_number INT NOT NULL UNIQUE,
    title VARCHAR(500) NOT NULL,
    subtitle VARCHAR(255),
    total_lessons INT DEFAULT 0,
    color VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Textbook Progress Table
CREATE TABLE IF NOT EXISTS textbook_progress (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    textbook_id BIGINT NOT NULL,
    completed_lessons INT DEFAULT 0,
    is_completed BOOLEAN DEFAULT FALSE,
    is_locked BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (textbook_id) REFERENCES textbooks(id) ON DELETE CASCADE,
    UNIQUE KEY unique_textbook_progress (user_id, textbook_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Lessons Table
CREATE TABLE IF NOT EXISTS lessons (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    textbook_id BIGINT,
    course_id BIGINT,
    title VARCHAR(500) NOT NULL,
    level VARCHAR(100),
    duration VARCHAR(50),
    progress INT DEFAULT 0,
    lesson_number INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (textbook_id) REFERENCES textbooks(id) ON DELETE SET NULL,
    FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Vocabulary Table
CREATE TABLE IF NOT EXISTS vocabulary (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    lesson_id BIGINT,
    korean VARCHAR(500) NOT NULL,
    vietnamese VARCHAR(500) NOT NULL,
    pronunciation VARCHAR(500),
    example TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (lesson_id) REFERENCES lessons(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Grammar Table
CREATE TABLE IF NOT EXISTS grammar (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    lesson_id BIGINT,
    title VARCHAR(500) NOT NULL,
    explanation TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (lesson_id) REFERENCES lessons(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Grammar Examples Table
CREATE TABLE IF NOT EXISTS grammar_examples (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    grammar_id BIGINT NOT NULL,
    example_text TEXT NOT NULL,
    FOREIGN KEY (grammar_id) REFERENCES grammar(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Exercises Table
CREATE TABLE IF NOT EXISTS exercises (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    lesson_id BIGINT,
    type VARCHAR(50) NOT NULL,
    question TEXT NOT NULL,
    answer VARCHAR(500),
    correct_index INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (lesson_id) REFERENCES lessons(id) ON DELETE CASCADE
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
    progress DECIMAL(5,4) DEFAULT 0.0,
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
    progress_percent DECIMAL(5,4) DEFAULT 0.0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Lesson Cards Table
CREATE TABLE IF NOT EXISTS lesson_cards (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    title VARCHAR(500) NOT NULL,
    date VARCHAR(50),
    tag VARCHAR(100),
    accent_color VARCHAR(50),
    background_color VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Course Cards Table
CREATE TABLE IF NOT EXISTS course_cards (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    title VARCHAR(500) NOT NULL,
    progress DECIMAL(5,4) DEFAULT 0.0,
    lessons INT DEFAULT 0,
    completed INT DEFAULT 0,
    accent_color VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Skill Progress Table
CREATE TABLE IF NOT EXISTS skill_progress (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    label VARCHAR(100) NOT NULL,
    percent DECIMAL(5,4) DEFAULT 0.0,
    color VARCHAR(50),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

