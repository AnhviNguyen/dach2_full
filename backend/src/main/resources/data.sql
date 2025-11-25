-- KoreanHwa Database Seed Data
-- Sample data for testing

-- Insert sample users
INSERT IGNORE INTO users (username, email, password, name, avatar, level, points, streak_days) VALUES
('user1', 'user1@example.com', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'Nguyễn Văn A', '👤', 'Beginner', 150, 5),
('user2', 'user2@example.com', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'Trần Thị B', '👩', 'Intermediate', 320, 12),
('user3', 'user3@example.com', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'Lê Văn C', '👨', 'Advanced', 580, 25);

-- Insert sample curriculum (replaces textbooks)
INSERT IGNORE INTO curriculum (book_number, title, subtitle, total_lessons, color) VALUES
(1, 'Giáo trình tiếng Hàn 1', 'Cơ bản cho người mới bắt đầu', 20, '#FFD700'),
(2, 'Giáo trình tiếng Hàn 2', 'Nâng cao trình độ cơ bản', 25, '#FF6B6B'),
(3, 'Giáo trình tiếng Hàn 3', 'Trung cấp', 30, '#4ECDC4'),
(4, 'Giáo trình tiếng Hàn 4', 'Trung cấp nâng cao', 30, '#95E1D3'),
(5, 'Giáo trình tiếng Hàn 5', 'Cao cấp', 35, '#F38181'),
(6, 'Giáo trình tiếng Hàn 6', 'Cao cấp nâng cao', 35, '#AA96DA');

-- Insert sample curriculum lessons for book 1
INSERT IGNORE INTO curriculum_lessons (curriculum_id, title, level, duration, progress, lesson_number, video_url) VALUES
(1, 'Bài 1: Chào hỏi', 'Beginner', '30 phút', 0, 1, 'https://example.com/video/lesson1'),
(1, 'Bài 2: Giới thiệu bản thân', 'Beginner', '35 phút', 0, 2, 'https://example.com/video/lesson2'),
(1, 'Bài 3: Số đếm', 'Beginner', '40 phút', 0, 3, 'https://example.com/video/lesson3'),
(1, 'Bài 4: Thời gian', 'Beginner', '35 phút', 0, 4, 'https://example.com/video/lesson4'),
(1, 'Bài 5: Gia đình', 'Beginner', '40 phút', 0, 5, 'https://example.com/video/lesson5');

-- Insert sample curriculum vocabulary for lesson 1
INSERT IGNORE INTO curriculum_vocabulary (curriculum_lesson_id, korean, vietnamese, pronunciation, example) VALUES
(1, '안녕하세요', 'Xin chào', 'an-nyeong-ha-se-yo', '안녕하세요. 만나서 반갑습니다.'),
(1, '감사합니다', 'Cảm ơn', 'gam-sa-ham-ni-da', '감사합니다.'),
(1, '죄송합니다', 'Xin lỗi', 'joe-song-ham-ni-da', '죄송합니다.'),
(1, '네', 'Vâng', 'ne', '네, 맞습니다.'),
(1, '아니요', 'Không', 'a-ni-yo', '아니요, 아닙니다.');

-- Insert sample curriculum vocabulary for lesson 2
INSERT IGNORE INTO curriculum_vocabulary (curriculum_lesson_id, korean, vietnamese, pronunciation, example) VALUES
(2, '이름', 'Tên', 'i-reum', '제 이름은 민수입니다.'),
(2, '나이', 'Tuổi', 'na-i', '저는 스물다섯 살입니다.'),
(2, '직업', 'Nghề nghiệp', 'ji-geop', '저는 학생입니다.'),
(2, '국적', 'Quốc tịch', 'guk-jeok', '저는 베트남 사람입니다.'),
(2, '거주지', 'Nơi ở', 'geo-ju-ji', '저는 하노이에 살고 있습니다.');

-- Insert sample grammar for curriculum lesson 1
INSERT IGNORE INTO grammar (curriculum_lesson_id, title, explanation) VALUES
(1, '입니다/입니까', 'Được dùng để kết thúc câu khẳng định và câu hỏi lịch sự'),
(1, '이/가', 'Trợ từ chủ ngữ, dùng để chỉ chủ thể của hành động');

-- Insert grammar examples
INSERT IGNORE INTO grammar_examples (grammar_id, example_text) VALUES
(1, '저는 학생입니다.'),
(1, '당신은 학생입니까?'),
(2, '제가 한국어를 공부합니다.'),
(2, '그가 선생님입니다.');

-- Insert sample exercises for curriculum lesson 1
INSERT IGNORE INTO exercises (curriculum_lesson_id, type, question, answer, correct_index) VALUES
(1, 'multiple_choice', '안녕하세요 có nghĩa là gì?', 'Xin chào', 0),
(1, 'multiple_choice', '감사합니다 có nghĩa là gì?', 'Cảm ơn', 1);

-- Insert exercise options
INSERT IGNORE INTO exercise_options (exercise_id, option_text, option_order) VALUES
(1, 'Xin chào', 0),
(1, 'Cảm ơn', 1),
(1, 'Xin lỗi', 2),
(1, 'Tạm biệt', 3),
(2, 'Xin lỗi', 0),
(2, 'Cảm ơn', 1),
(2, 'Xin chào', 2),
(2, 'Không có gì', 3);

-- Insert sample courses
INSERT IGNORE INTO courses (title, instructor, level, rating, students, lessons, duration_start, duration_end, price, image, accent_color) VALUES
('Khóa học tiếng Hàn giao tiếp', 'Cô Kim Min-ji', 'Beginner', 4.5, 150, 20, '2024-01-01', '2024-03-31', '2,500,000 VNĐ', 'https://example.com/course1.jpg', '#FFD700'),
('Khóa học luyện thi TOPIK', 'Thầy Park Seung-ho', 'Intermediate', 4.8, 200, 30, '2024-02-01', '2024-05-31', '3,500,000 VNĐ', 'https://example.com/course2.jpg', '#FF6B6B'),
('Khóa học tiếng Hàn thương mại', 'Cô Lee So-young', 'Advanced', 4.7, 80, 25, '2024-03-01', '2024-06-30', '4,000,000 VNĐ', 'https://example.com/course3.jpg', '#4ECDC4');

-- Insert sample course lessons
INSERT IGNORE INTO course_lessons (course_id, title, level, duration, progress, lesson_number, video_url) VALUES
(1, 'Bài 1: Chào hỏi trong công việc', 'Beginner', '45 phút', 0, 1, 'https://example.com/course1/lesson1'),
(1, 'Bài 2: Giới thiệu công ty', 'Beginner', '50 phút', 0, 2, 'https://example.com/course1/lesson2'),
(2, 'Bài 1: Cấu trúc đề thi TOPIK', 'Intermediate', '60 phút', 0, 1, 'https://example.com/course2/lesson1'),
(2, 'Bài 2: Kỹ năng đọc hiểu', 'Intermediate', '65 phút', 0, 2, 'https://example.com/course2/lesson2');

-- Insert sample course vocabulary for course lesson 1
INSERT IGNORE INTO course_vocabulary (course_lesson_id, korean, vietnamese, pronunciation, example) VALUES
(1, '회의', 'Cuộc họp', 'hoe-ui', '오늘 회의가 있습니다.'),
(1, '프로젝트', 'Dự án', 'peu-ro-jek-teu', '이 프로젝트는 중요합니다.'),
(1, '발표', 'Thuyết trình', 'bal-pyo', '내일 발표를 해야 합니다.'),
(2, '회사', 'Công ty', 'hoe-sa', '저는 대기업에서 일합니다.'),
(2, '부서', 'Phòng ban', 'bu-seo', '마케팅 부서에 있습니다.');

-- Insert sample grammar for course lessons
INSERT IGNORE INTO grammar (course_lesson_id, title, explanation) VALUES
(1, 'V-아/어요', 'Đuôi câu thân mật, dùng trong giao tiếp hàng ngày'),
(2, 'N-은/는', 'Trợ từ chủ đề, dùng để nhấn mạnh chủ đề của câu');

-- Insert grammar examples for course lessons
INSERT IGNORE INTO grammar_examples (grammar_id, example_text) VALUES
(3, '저는 한국어를 배워요.'),
(3, '오늘 날씨가 좋아요.'),
(4, '저는 학생이에요.'),
(4, '한국어는 어려워요.');

-- Insert sample exercises for course lessons
INSERT IGNORE INTO exercises (course_lesson_id, type, question, answer, correct_index) VALUES
(1, 'multiple_choice', 'Chọn đáp án đúng cho "안녕하세요"', 'Xin chào', 0),
(2, 'multiple_choice', 'Cấu trúc đề thi TOPIK có mấy phần?', '3 phần', 1);

-- Insert exercise options for course lessons
INSERT IGNORE INTO exercise_options (exercise_id, option_text, option_order) VALUES
(3, 'Xin chào', 0),
(3, 'Cảm ơn', 1),
(3, 'Xin lỗi', 2),
(4, '2 phần', 0),
(4, '3 phần', 1),
(4, '4 phần', 2);

-- Insert sample curriculum progress
INSERT IGNORE INTO curriculum_progress (user_id, curriculum_id, completed_lessons, is_completed, is_locked) VALUES
(1, 1, 2, FALSE, FALSE),
(1, 2, 0, FALSE, TRUE),
(2, 1, 5, FALSE, FALSE),
(2, 2, 3, FALSE, FALSE);

-- Insert sample course enrollments
INSERT IGNORE INTO course_enrollments (user_id, course_id, progress, is_enrolled, completed_lessons) VALUES
(1, 1, 25.5, TRUE, 5),
(1, 2, 0.0, TRUE, 0),
(2, 1, 50.0, TRUE, 10),
(2, 2, 30.0, TRUE, 9);

-- Insert sample rankings
INSERT IGNORE INTO rankings (user_id, points, days, color) VALUES
(1, 150, 5, '#FFD700'),
(2, 320, 12, '#FF6B6B'),
(3, 580, 25, '#4ECDC4');

-- Insert sample achievements
INSERT IGNORE INTO achievements (icon_label, title, subtitle, color, target_count) VALUES
('🏆', 'Người mới bắt đầu', 'Hoàn thành bài học đầu tiên', '#FFD700', 1),
('📚', 'Học viên chăm chỉ', 'Hoàn thành 10 bài học', '#4ECDC4', 10),
('🔥', 'Chuỗi ngày học tập', 'Học liên tiếp 7 ngày', '#FF6B6B', 7),
('⭐', 'Ngôi sao sáng', 'Đạt 100 điểm', '#FFD700', 100);

-- Insert sample user achievements
INSERT IGNORE INTO user_achievements (user_id, achievement_id, current_count, is_completed, progress) VALUES
(1, 1, 1, TRUE, 100.0),
(1, 2, 5, FALSE, 50.0),
(2, 1, 1, TRUE, 100.0),
(2, 2, 10, TRUE, 100.0),
(2, 3, 12, TRUE, 100.0);

-- Insert sample tasks
INSERT IGNORE INTO tasks (user_id, title, icon_name, color, progress_color, progress_percent) VALUES
(1, 'Học từ vựng', 'book', '#FFD700', '#FFD700', 70.0),
(1, 'Học ngữ pháp', 'translate', '#4ECDC4', '#4ECDC4', 45.0),
(2, 'Luyện nghe', 'hearing', '#FF6B6B', '#FF6B6B', 80.0),
(2, 'Luyện nói', 'mic', '#95E1D3', '#95E1D3', 60.0);

-- Insert sample skill progress
INSERT IGNORE INTO skill_progress (user_id, label, percent, color) VALUES
(1, 'Nghe', 75.0, '#FFD700'),
(1, 'Nói', 60.0, '#FF6B6B'),
(1, 'Đọc', 85.0, '#4ECDC4'),
(1, 'Viết', 45.0, '#95E1D3'),
(2, 'Nghe', 90.0, '#FFD700'),
(2, 'Nói', 75.0, '#FF6B6B'),
(2, 'Đọc', 95.0, '#4ECDC4'),
(2, 'Viết', 70.0, '#95E1D3');

-- Insert sample materials
INSERT IGNORE INTO materials (title, description, level, skill, type, thumbnail, downloads, rating, size, points, is_featured, duration, pdf_url, video_url, audio_url) VALUES
('Từ vựng TOPIK 1', 'Danh sách từ vựng cần thiết cho kỳ thi TOPIK cấp độ 1', 'Beginner', 'vocabulary', 'pdf', '📄', 150, 4.5, '2.5 MB', 10, TRUE, '30 phút', 'https://example.com/topik1.pdf', NULL, NULL),
('Ngữ pháp tiếng Hàn cơ bản', 'Tổng hợp các ngữ pháp cơ bản trong tiếng Hàn', 'Beginner', 'grammar', 'pdf', '📚', 200, 4.7, '3.2 MB', 15, TRUE, '45 phút', 'https://example.com/grammar.pdf', NULL, NULL),
('Luyện nghe tiếng Hàn', 'Audio file luyện nghe tiếng Hàn', 'Intermediate', 'listening', 'audio', '🎧', 120, 4.6, '15 MB', 20, FALSE, '60 phút', NULL, NULL, 'https://example.com/listening.mp3');

-- Insert sample blog posts
INSERT IGNORE INTO blog_posts (title, content, author_id, skill, likes, comments, views, featured_image) VALUES
('5 cách học từ vựng tiếng Hàn hiệu quả', 'Bài viết chia sẻ các phương pháp học từ vựng hiệu quả...', 1, 'vocabulary', 25, 5, 150, 'https://example.com/blog1.jpg'),
('Kinh nghiệm thi TOPIK', 'Chia sẻ kinh nghiệm thi TOPIK từ người đã đạt điểm cao...', 2, 'exam', 40, 8, 300, 'https://example.com/blog2.jpg'),
('Văn hóa Hàn Quốc qua ngôn ngữ', 'Tìm hiểu về văn hóa Hàn Quốc thông qua ngôn ngữ...', 1, 'culture', 30, 6, 200, 'https://example.com/blog3.jpg');

-- Insert sample competition categories (must be inserted before competitions)
INSERT IGNORE INTO competition_categories (category_id, name, icon_name) VALUES
('vocabulary', 'Từ vựng', 'book'),
('grammar', 'Ngữ pháp', 'translate'),
('speaking', 'Nói', 'mic'),
('listening', 'Nghe', 'hearing'),
('reading', 'Đọc', 'menu_book'),
('writing', 'Viết', 'edit');

-- Insert sample competitions
INSERT IGNORE INTO competitions (title, description, category_id, start_date, end_date, status, prize, participants, image) VALUES
('Cuộc thi từ vựng tháng 1', 'Cuộc thi từ vựng tiếng Hàn dành cho người mới bắt đầu', 'vocabulary', '2024-01-01 00:00:00', '2024-01-31 23:59:59', 'completed', '1,000,000 VNĐ', 50, 'https://example.com/competition1.jpg'),
('Cuộc thi ngữ pháp tháng 2', 'Cuộc thi ngữ pháp tiếng Hàn trung cấp', 'grammar', '2024-02-01 00:00:00', '2024-02-28 23:59:59', 'ongoing', '1,500,000 VNĐ', 30, 'https://example.com/competition2.jpg'),
('Cuộc thi giao tiếp tháng 3', 'Cuộc thi giao tiếp tiếng Hàn', 'speaking', '2024-03-01 00:00:00', '2024-03-31 23:59:59', 'upcoming', '2,000,000 VNĐ', 0, 'https://example.com/competition3.jpg');

-- Insert sample vocabulary folders
INSERT IGNORE INTO vocabulary_folders (user_id, name, icon) VALUES
(1, 'Từ vựng bài 1', '📁'),
(1, 'Từ vựng bài 2', '📁'),
(2, 'Từ vựng TOPIK', '📚'),
(2, 'Từ vựng giao tiếp', '💬');

-- Insert sample vocabulary words
INSERT IGNORE INTO vocabulary_words (folder_id, korean, vietnamese, pronunciation, example) VALUES
(1, '안녕하세요', 'Xin chào', 'an-nyeong-ha-se-yo', '안녕하세요. 만나서 반갑습니다.'),
(1, '감사합니다', 'Cảm ơn', 'gam-sa-ham-ni-da', '감사합니다.'),
(2, '이름', 'Tên', 'i-reum', '제 이름은 민수입니다.'),
(2, '나이', 'Tuổi', 'na-i', '저는 스물다섯 살입니다.'),
(3, '시험', 'Kỳ thi', 'si-heom', '내일 시험이 있습니다.'),
(3, '공부하다', 'Học', 'gong-bu-ha-da', '한국어를 공부합니다.');

