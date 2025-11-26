-- KoreanHwa Sample Data
-- Password for all users: 123456 (bcrypt hashed)
-- Hash: $2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy

-- Insert Users
INSERT INTO users (username, email, password, name, avatar, level, points, streak_days) VALUES
                                                                                            ('nguyenvana', 'nguyenvana@email.com', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'Nguyễn Văn A', 'https://i.pravatar.cc/150?img=1', 'Intermediate', 1250, 15),
                                                                                            ('tranthib', 'tranthib@email.com', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'Trần Thị B', 'https://i.pravatar.cc/150?img=2', 'Beginner', 450, 7),
                                                                                            ('levanc', 'levanc@email.com', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'Lê Văn C', 'https://i.pravatar.cc/150?img=3', 'Advanced', 2800, 30),
                                                                                            ('phamthid', 'phamthid@email.com', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'Phạm Thị D', 'https://i.pravatar.cc/150?img=4', 'Beginner', 200, 3),
                                                                                            ('hoangvane', 'hoangvane@email.com', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'Hoàng Văn E', 'https://i.pravatar.cc/150?img=5', 'Intermediate', 1650, 20);

-- Insert Curriculum (Textbooks)
INSERT INTO curriculum (book_number, title, subtitle, total_lessons, color) VALUES
                                                                                (1, 'Giáo trình Tiếng Hàn Tổng Hợp', 'Sơ cấp 1', 25, '#FF6B6B'),
                                                                                (2, 'Giáo trình Tiếng Hàn Tổng Hợp', 'Sơ cấp 2', 25, '#4ECDC4'),
                                                                                (3, 'Giáo trình Tiếng Hàn Tổng Hợp', 'Trung cấp 1', 30, '#95E1D3'),
                                                                                (4, 'Giáo trình Tiếng Hàn Tổng Hợp', 'Trung cấp 2', 30, '#F38181'),
                                                                                (5, 'Giáo trình Tiếng Hàn Tổng Hợp', 'Cao cấp 1', 35, '#AA96DA'),
                                                                                (6, 'Giáo trình Tiếng Hàn Tổng Hợp', 'Cao cấp 2', 35, '#FCBAD3');

-- Insert Curriculum Progress
INSERT INTO curriculum_progress (user_id, curriculum_id, completed_lessons, is_completed, is_locked) VALUES
                                                                                                         (1, 1, 25, TRUE, FALSE),
                                                                                                         (1, 2, 18, FALSE, FALSE),
                                                                                                         (1, 3, 0, FALSE, TRUE),
                                                                                                         (2, 1, 10, FALSE, FALSE),
                                                                                                         (2, 2, 0, FALSE, TRUE),
                                                                                                         (3, 1, 25, TRUE, FALSE),
                                                                                                         (3, 2, 25, TRUE, FALSE),
                                                                                                         (3, 3, 30, TRUE, FALSE),
                                                                                                         (3, 4, 15, FALSE, FALSE);

-- Insert Curriculum Lessons (Sample for Book 1)
INSERT INTO curriculum_lessons (curriculum_id, title, level, duration, progress, lesson_number, video_url) VALUES
                                                                                                               (1, 'Bài 1: Chào hỏi và giới thiệu bản thân', 'Beginner', '45 phút', 100, 1, 'https://youtube.com/watch?v=sample1'),
                                                                                                               (1, 'Bài 2: Gia đình', 'Beginner', '50 phút', 100, 2, 'https://youtube.com/watch?v=sample2'),
                                                                                                               (1, 'Bài 3: Thời gian và ngày tháng', 'Beginner', '45 phút', 80, 3, 'https://youtube.com/watch?v=sample3'),
                                                                                                               (1, 'Bài 4: Đi mua sắm', 'Beginner', '50 phút', 60, 4, 'https://youtube.com/watch?v=sample4'),
                                                                                                               (1, 'Bài 5: Hoạt động hàng ngày', 'Beginner', '45 phút', 40, 5, 'https://youtube.com/watch?v=sample5'),
                                                                                                               (2, 'Bài 1: Giao tiếp hàng ngày nâng cao', 'Beginner', '50 phút', 75, 1, 'https://youtube.com/watch?v=sample6'),
                                                                                                               (2, 'Bài 2: Đặt phòng khách sạn', 'Beginner', '45 phút', 50, 2, 'https://youtube.com/watch?v=sample7'),
                                                                                                               (2, 'Bài 3: Hỏi đường', 'Beginner', '40 phút', 30, 3, 'https://youtube.com/watch?v=sample8'),
                                                                                                               (3, 'Bài 1: Văn hóa Hàn Quốc', 'Intermediate', '60 phút', 0, 1, 'https://youtube.com/watch?v=sample9'),
                                                                                                               (3, 'Bài 2: Lễ hội truyền thống', 'Intermediate', '55 phút', 0, 2, 'https://youtube.com/watch?v=sample10');

-- Insert Courses (Instructor-led courses)
INSERT INTO courses (title, instructor, level, rating, students, lessons, duration_start, duration_end, price, image, accent_color) VALUES
                                                                                                                                        ('Tiếng Hàn Giao Tiếp Cơ Bản', 'Park Ji-won', 'Beginner', 4.8, 1250, 20, '2024-01-01', '2024-03-31', 'Miễn phí', 'https://picsum.photos/400/250?random=1', '#FF6B6B'),
                                                                                                                                        ('Ngữ Pháp Tiếng Hàn Nâng Cao', 'Kim Min-soo', 'Advanced', 4.9, 850, 25, '2024-02-01', '2024-05-31', '500,000 VNĐ', 'https://picsum.photos/400/250?random=2', '#4ECDC4'),
                                                                                                                                        ('TOPIK II Luyện Thi', 'Lee Soo-jin', 'Intermediate', 4.7, 2100, 30, '2024-01-15', '2024-06-30', '800,000 VNĐ', 'https://picsum.photos/400/250?random=3', '#95E1D3'),
                                                                                                                                        ('Tiếng Hàn Thương Mại', 'Choi Yeon-hee', 'Advanced', 4.6, 650, 22, '2024-03-01', '2024-07-31', '1,000,000 VNĐ', 'https://picsum.photos/400/250?random=4', '#F38181'),
                                                                                                                                        ('Hội Thoại Tiếng Hàn Hàng Ngày', 'Jung Ho-seok', 'Beginner', 4.9, 1800, 18, '2024-01-10', '2024-04-30', 'Miễn phí', 'https://picsum.photos/400/250?random=5', '#AA96DA');

-- Insert Course Enrollments
INSERT INTO course_enrollments (user_id, course_id, progress, is_enrolled, completed_lessons) VALUES
                                                                                                  (1, 1, 85.5, TRUE, 17),
                                                                                                  (1, 3, 40.0, TRUE, 12),
                                                                                                  (2, 1, 30.0, TRUE, 6),
                                                                                                  (2, 5, 55.5, TRUE, 10),
                                                                                                  (3, 2, 92.0, TRUE, 23),
                                                                                                  (3, 3, 100.0, TRUE, 30),
                                                                                                  (3, 4, 68.2, TRUE, 15),
                                                                                                  (4, 1, 15.0, TRUE, 3),
                                                                                                  (5, 3, 50.0, TRUE, 15),
                                                                                                  (5, 5, 88.9, TRUE, 16);

-- Insert Course Lessons (Sample for Course 1)
INSERT INTO course_lessons (course_id, title, level, duration, progress, lesson_number, video_url) VALUES
                                                                                                       (1, 'Bài 1: Chữ cái và phát âm', 'Beginner', '30 phút', 100, 1, 'https://youtube.com/watch?v=course1-1'),
                                                                                                       (1, 'Bài 2: Giới thiệu bản thân', 'Beginner', '35 phút', 100, 2, 'https://youtube.com/watch?v=course1-2'),
                                                                                                       (1, 'Bài 3: Gia đình tôi', 'Beginner', '40 phút', 90, 3, 'https://youtube.com/watch?v=course1-3'),
                                                                                                       (1, 'Bài 4: Nghề nghiệp', 'Beginner', '35 phút', 75, 4, 'https://youtube.com/watch?v=course1-4'),
                                                                                                       (1, 'Bài 5: Sở thích', 'Beginner', '40 phút', 50, 5, 'https://youtube.com/watch?v=course1-5'),
                                                                                                       (2, 'Bài 1: Cấu trúc câu cơ bản', 'Advanced', '50 phút', 100, 1, 'https://youtube.com/watch?v=course2-1'),
                                                                                                       (2, 'Bài 2: Thì và thể', 'Advanced', '55 phút', 85, 2, 'https://youtube.com/watch?v=course2-2'),
                                                                                                       (3, 'Bài 1: Chiến lược làm bài TOPIK', 'Intermediate', '45 phút', 100, 1, 'https://youtube.com/watch?v=course3-1'),
                                                                                                       (3, 'Bài 2: Đọc hiểu nâng cao', 'Intermediate', '50 phút', 80, 2, 'https://youtube.com/watch?v=course3-2');

-- Insert Curriculum Vocabulary (for curriculum lessons)
INSERT INTO curriculum_vocabulary (curriculum_lesson_id, korean, vietnamese, pronunciation, example) VALUES
                                                                                                         (1, '안녕하세요', 'Xin chào', 'an-nyeong-ha-se-yo', '안녕하세요? 저는 민수입니다.'),
                                                                                                         (1, '저', 'Tôi (khiêm tốn)', 'jeo', '저는 학생입니다.'),
                                                                                                         (1, '이름', 'Tên', 'i-reum', '제 이름은 김민수입니다.'),
                                                                                                         (1, '입니다', 'Là (kính ngữ)', 'im-ni-da', '저는 선생님입니다.'),
                                                                                                         (2, '가족', 'Gia đình', 'ga-jok', '우리 가족은 네 명입니다.'),
                                                                                                         (2, '아버지', 'Cha', 'a-beo-ji', '제 아버지는 회사원입니다.'),
                                                                                                         (2, '어머니', 'Mẹ', 'eo-meo-ni', '제 어머니는 선생님입니다.'),
                                                                                                         (2, '형제', 'Anh em', 'hyeong-je', '형제가 있어요?'),
                                                                                                         (3, '시간', 'Thời gian', 'si-gan', '지금 몇 시예요?'),
                                                                                                         (3, '날짜', 'Ngày tháng', 'nal-jja', '오늘 날짜가 어떻게 돼요?');

-- Insert Course Vocabulary (for course lessons)
INSERT INTO course_vocabulary (course_lesson_id, korean, vietnamese, pronunciation, example) VALUES
                                                                                                 (1, '한글', 'Chữ Hàn', 'han-geul', '한글은 배우기 쉬워요.'),
                                                                                                 (1, '자음', 'Phụ âm', 'ja-eum', '한글에는 14개의 자음이 있습니다.'),
                                                                                                 (1, '모음', 'Nguyên âm', 'mo-eum', '한글에는 10개의 모음이 있습니다.'),
                                                                                                 (2, '직업', 'Nghề nghiệp', 'ji-geop', '당신의 직업이 무엇입니까?'),
                                                                                                 (2, '학생', 'Học sinh', 'hak-saeng', '저는 대학생입니다.'),
                                                                                                 (3, '취미', 'Sở thích', 'chwi-mi', '취미가 무엇입니까?'),
                                                                                                 (3, '운동', 'Vận động', 'un-dong', '저는 운동을 좋아합니다.');

-- Insert Grammar (for curriculum lessons)
INSERT INTO grammar (curriculum_lesson_id, title, explanation) VALUES
                                                                   (1, '입니다/이에요', 'Động từ "là" trong tiếng Hàn. Sử dụng 입니다 (cách nói lịch sự) sau danh từ kết thúc bằng phụ âm, và 이에요 sau danh từ kết thúc bằng nguyên âm.'),
                                                                   (2, '이/가', '조사 chủ ngữ. Sử dụng 이 sau danh từ kết thúc bằng phụ âm, 가 sau danh từ kết thúc bằng nguyên âm.'),
                                                                   (3, '시', 'Từ chỉ giờ. Ví dụ: 한 시 (1 giờ), 두 시 (2 giờ)');

-- Insert Grammar Examples
INSERT INTO grammar_examples (grammar_id, example_text) VALUES
                                                            (1, '저는 학생입니다. (Tôi là học sinh.)'),
                                                            (1, '이것은 책이에요. (Đây là quyển sách.)'),
                                                            (2, '친구가 왔어요. (Bạn đã đến.)'),
                                                            (2, '사과가 맛있어요. (Táo ngon.)'),
                                                            (3, '지금 세 시입니다. (Bây giờ là 3 giờ.)'),
                                                            (3, '몇 시에 만날까요? (Mấy giờ gặp nhau?)');

-- Insert Exercises
INSERT INTO exercises (curriculum_lesson_id, type, question, answer, correct_index) VALUES
                                                                                        (1, 'multiple-choice', 'Chọn cách nói "Xin chào" đúng trong tiếng Hàn:', NULL, 0),
                                                                                        (1, 'fill-blank', 'Điền vào chỗ trống: 저는 ___입니다. (Tôi là học sinh)', '학생', NULL),
                                                                                        (2, 'multiple-choice', '"아버지" trong tiếng Việt là gì?', NULL, 1),
                                                                                        (3, 'matching', 'Ghép từ tiếng Hàn với nghĩa tiếng Việt', NULL, NULL);

-- Insert Exercise Options
INSERT INTO exercise_options (exercise_id, option_text, option_order) VALUES
                                                                          (1, '안녕하세요', 0),
                                                                          (1, '안녕히 가세요', 1),
                                                                          (1, '감사합니다', 2),
                                                                          (1, '죄송합니다', 3),
                                                                          (3, 'Cha', 0),
                                                                          (3, 'Bố', 1),
                                                                          (3, 'Ba', 2),
                                                                          (3, 'Tất cả đều đúng', 3);

-- Insert Rankings
INSERT INTO rankings (user_id, points, days, color) VALUES
                                                        (3, 2800, 30, '#FFD700'),
                                                        (1, 1250, 15, '#C0C0C0'),
                                                        (5, 1650, 20, '#CD7F32'),
                                                        (2, 450, 7, '#E8E8E8'),
                                                        (4, 200, 3, '#F5F5F5');

-- Insert Achievements
INSERT INTO achievements (icon_label, title, subtitle, color, target_count) VALUES
                                                                                ('🔥', 'Streak Master', 'Học liên tục 7 ngày', '#FF6B6B', 7),
                                                                                ('📚', 'Book Worm', 'Hoàn thành 1 giáo trình', '#4ECDC4', 1),
                                                                                ('⭐', 'Rising Star', 'Đạt 1000 điểm', '#FFD700', 1000),
                                                                                ('🎯', 'Perfect Score', 'Đạt 100% trong 10 bài kiểm tra', '#95E1D3', 10),
                                                                                ('👥', 'Social Butterfly', 'Kết bạn với 10 người', '#AA96DA', 10),
                                                                                ('🏆', 'Champion', 'Giành giải nhất trong cuộc thi', '#F38181', 1);

-- Insert User Achievements
INSERT INTO user_achievements (user_id, achievement_id, current_count, is_completed, progress, completed_at) VALUES
                                                                                                                 (1, 1, 7, TRUE, 100.0, '2024-11-01 10:00:00'),
                                                                                                                 (1, 3, 1250, TRUE, 100.0, '2024-11-10 15:30:00'),
                                                                                                                 (3, 1, 30, TRUE, 100.0, '2024-10-15 09:00:00'),
                                                                                                                 (3, 2, 3, TRUE, 100.0, '2024-11-05 14:20:00'),
                                                                                                                 (3, 3, 2800, TRUE, 100.0, '2024-11-15 11:45:00'),
                                                                                                                 (2, 1, 5, FALSE, 71.4, NULL),
                                                                                                                 (5, 1, 20, TRUE, 100.0, '2024-11-12 16:00:00');

-- Insert Blog Posts
INSERT INTO blog_posts (title, content, author_id, skill, likes, comments, views, featured_image) VALUES
                                                                                                      ('5 Mẹo Học Tiếng Hàn Hiệu Quả', 'Học tiếng Hàn không khó nếu bạn biết phương pháp đúng. Trong bài viết này, tôi sẽ chia sẻ 5 mẹo giúp bạn học tiếng Hàn hiệu quả hơn...', 1, 'Speaking', 45, 12, 450, 'https://picsum.photos/800/400?random=11'),
                                                                                                      ('Kinh Nghiệm Thi TOPIK II', 'Sau khi thi TOPIK II và đạt 250 điểm, tôi muốn chia sẻ kinh nghiệm của mình để giúp các bạn chuẩn bị tốt hơn...', 3, 'Reading', 128, 34, 1250, 'https://picsum.photos/800/400?random=12'),
                                                                                                      ('Văn Hóa Ăn Uống Hàn Quốc', 'Văn hóa ẩm thực Hàn Quốc rất phong phú và đa dạng. Hãy cùng khám phá những điều thú vị về văn hóa ăn uống tại xứ sở kim chi...', 5, 'Listening', 67, 18, 780, 'https://picsum.photos/800/400?random=13'),
                                                                                                      ('Cách Phát Âm Tiếng Hàn Chuẩn', 'Phát âm là nền tảng quan trọng khi học tiếng Hàn. Dưới đây là những lưu ý để phát âm chuẩn hơn...', 1, 'Speaking', 89, 23, 920, 'https://picsum.photos/800/400?random=14');

-- Insert Blog Tags
INSERT INTO blog_tags (post_id, tag) VALUES
                                         (1, 'Học tập'),
                                         (1, 'Mẹo hay'),
                                         (1, 'Tiếng Hàn'),
                                         (2, 'TOPIK'),
                                         (2, 'Kinh nghiệm'),
                                         (2, 'Thi cử'),
                                         (3, 'Văn hóa'),
                                         (3, 'Ẩm thực'),
                                         (3, 'Hàn Quốc'),
                                         (4, 'Phát âm'),
                                         (4, 'Kỹ năng');

-- Insert Blog Likes
INSERT INTO blog_likes (post_id, user_id) VALUES
                                              (1, 2), (1, 3), (1, 4),
                                              (2, 1), (2, 2), (2, 4), (2, 5),
                                              (3, 1), (3, 3), (3, 4),
                                              (4, 2), (4, 3), (4, 5);

-- Insert Dashboard Stats
INSERT INTO dashboard_stats (user_id, total_courses, completed_courses, total_videos, watched_videos, total_exams, completed_exams, total_watch_time, completed_watch_time, last_access, end_date) VALUES
                                                                                                                                                                                                       (1, 2, 0, 50, 29, 20, 12, '25:00:00', '14:30:00', '2024-11-26 08:30:00', '2024-12-31'),
                                                                                                                                                                                                       (2, 2, 0, 38, 16, 15, 6, '19:00:00', '08:00:00', '2024-11-25 18:45:00', '2024-12-31'),
                                                                                                                                                                                                       (3, 3, 1, 77, 68, 35, 31, '38:30:00', '34:00:00', '2024-11-26 07:15:00', '2024-12-31'),
                                                                                                                                                                                                       (4, 1, 0, 20, 3, 10, 1, '10:00:00', '01:30:00', '2024-11-24 20:00:00', '2024-12-31'),
                                                                                                                                                                                                       (5, 2, 0, 48, 26, 22, 13, '24:00:00', '13:00:00', '2024-11-26 09:00:00', '2024-12-31');

-- Insert Competition Categories
INSERT INTO competition_categories (category_id, name, icon_name) VALUES
                                                                      ('grammar', 'Ngữ Pháp', 'Book'),
                                                                      ('vocabulary', 'Từ Vựng', 'FileText'),
                                                                      ('listening', 'Nghe', 'Headphones'),
                                                                      ('speaking', 'Nói', 'Mic'),
                                                                      ('reading', 'Đọc', 'BookOpen'),
                                                                      ('writing', 'Viết', 'PenTool');

-- Insert Competitions
INSERT INTO competitions (title, description, category_id, start_date, end_date, status, prize, participants, image) VALUES
                                                                                                                         ('Cuộc Thi Ngữ Pháp Tháng 11', 'Thử thách kiến thức ngữ pháp tiếng Hàn của bạn!', 'grammar', '2024-11-01 00:00:00', '2024-11-30 23:59:59', 'active', 'Giải nhất: 1,000,000 VNĐ', 245, 'https://picsum.photos/400/250?random=21'),
                                                                                                                         ('Vocabulary Challenge 2024', 'Ai là người có vốn từ vựng phong phú nhất?', 'vocabulary', '2024-12-01 00:00:00', '2024-12-31 23:59:59', 'upcoming', 'Giải nhất: 500,000 VNĐ + Khóa học Premium', 0, 'https://picsum.photos/400/250?random=22'),
                                                                                                                         ('TOPIK Listening Practice', 'Luyện tập kỹ năng nghe cho kỳ thi TOPIK', 'listening', '2024-10-01 00:00:00', '2024-10-31 23:59:59', 'completed', 'Giải nhất: Voucher học 300,000 VNĐ', 189, 'https://picsum.photos/400/250?random=23');

-- Insert Competition Participants
INSERT INTO competition_participants (user_id, competition_id, score, rank, submitted_at, status) VALUES
                                                                                                      (1, 1, 85, 3, '2024-11-15 14:30:00', 'completed'),
                                                                                                      (3, 1, 95, 1, '2024-11-16 10:20:00', 'completed'),
                                                                                                      (5, 1, 90, 2, '2024-11-17 16:45:00', 'completed'),
                                                                                                      (2, 1, 70, 8, '2024-11-18 09:15:00', 'completed'),
                                                                                                      (3, 3, 88, 2, '2024-10-28 11:30:00', 'completed');

-- Insert Materials
INSERT INTO materials (title, description, level, skill, type, thumbnail, downloads, rating, size, points, is_featured, duration, pdf_url) VALUES
                                                                                                                                               ('Bảng Chữ Cái Tiếng Hàn', 'Tài liệu học bảng chữ cái Hangul đầy đủ với hướng dẫn viết', 'Beginner', 'Writing', 'PDF', '📝', 1250, 4.8, '2.5 MB', 0, TRUE, NULL, 'https://example.com/hangul-chart.pdf'),
                                                                                                                                               ('100 Mẫu Câu Giao Tiếp', 'Tổng hợp 100 mẫu câu giao tiếp thông dụng nhất', 'Beginner', 'Speaking', 'PDF', '💬', 980, 4.7, '1.8 MB', 50, TRUE, NULL, 'https://example.com/100-sentences.pdf'),
                                                                                                                                               ('Ngữ Pháp TOPIK II', 'Tổng hợp toàn bộ ngữ pháp cho kỳ thi TOPIK II', 'Advanced', 'Grammar', 'PDF', '📚', 2100, 4.9, '5.2 MB', 100, TRUE, NULL, 'https://example.com/topik-grammar.pdf'),
                                                                                                                                               ('Từ Vựng Theo Chủ Đề', '1000 từ vựng được phân loại theo 20 chủ đề', 'Intermediate', 'Vocabulary', 'PDF', '📖', 1560, 4.6, '3.1 MB', 75, FALSE, NULL, 'https://example.com/vocab-topics.pdf'),
                                                                                                                                               ('Luyện Nghe TOPIK I', 'Bài tập luyện nghe cho TOPIK I với file audio', 'Beginner', 'Listening', 'Audio', '🎧', 890, 4.5, '45 MB', 80, FALSE, '60 phút', 'https://example.com/topik1-listening.mp3');

-- Insert Material Downloads
INSERT INTO material_downloads (user_id, material_id) VALUES
                                                          (1, 1), (1, 2), (1, 3),
                                                          (2, 1), (2, 2),
                                                          (3, 1), (3, 2), (3, 3), (3, 4),
                                                          (4, 1),
                                                          (5, 1), (5, 2), (5, 4);

-- Insert Speak Practice Stats
INSERT INTO speak_practice_stats (user_id, label, value, subtitle) VALUES
                                                                       (1, 'Thời gian luyện tập', '45 phút', 'Tuần này'),
                                                                       (1, 'Câu đã nói', '127', 'Tổng cộng'),
                                                                       (1, 'Độ chính xác', '85%', 'Trung bình'),
                                                                       (3, 'Thời gian luyện tập', '120 phút', 'Tuần này'),
                                                                       (3, 'Câu đã nói', '456', 'Tổng cộng'),
                                                                       (3, 'Độ chính xác', '92%', 'Trung bình');

-- Insert Speak Practice Missions
INSERT INTO speak_practice_missions (user_id, title, subtitle, icon_name, color) VALUES
                                                                                     (1, 'Nói 50 câu mỗi ngày', 'Hoàn thành 35/50 câu', 'Target', '#FF6B6B'),
                                                                                     (1, 'Luyện phát âm 30 phút', 'Còn 15 phút', 'Clock', '#4ECDC4'),
                                                                                     (3, 'Đạt 90% độ chính xác', 'Hiện tại: 92%', 'Award', '#FFD700');

-- Insert Tasks
INSERT INTO tasks (user_id, title, icon_name, color, progress_color, progress_percent) VALUES
                                                                                           (1, 'Hoàn thành Bài 5 - Giáo trình 1', 'BookOpen', '#FF6B6B', '#FFB6B6', 75.0),
                                                                                           (1, 'Luyện tập từ vựng Bài 3', 'FileText', '#4ECDC4', '#9EDDD8', 60.0),
                                                                                           (1, 'Xem video bài giảng mới', 'Play', '#95E1D3', '#C5F1E8', 30.0),
                                                                                           (2, 'Học 20 từ vựng mới', 'Book', '#F38181', '#F9B1B1', 45.0),
                                                                                           (3, 'Ôn tập ngữ pháp TOPIK', 'Award', '#AA96DA', '#CABDEA', 90.0),
                                                                                           (5, 'Hoàn thành bài kiểm tra', 'CheckSquare', '#FCBAD3', '#FDD5E7', 50.0);

-- Insert Skill Progress
INSERT INTO skill_progress (user_id, label, percent, color) VALUES
                                                                (1, 'Nghe', 75.5, '#FF6B6B'),
                                                                (1, 'Nói', 68.0, '#4ECDC4'),
                                                                (1, 'Đọc', 82.5, '#95E1D3'),
                                                                (1, 'Viết', 71.0, '#F38181'),
                                                                (2, 'Nghe', 45.0, '#FF6B6B'),
                                                                (2, 'Nói', 38.5, '#4ECDC4'),
                                                                (2, 'Đọc', 52.0, '#95E1D3'),
                                                                (2, 'Viết', 41.5, '#F38181'),
                                                                (3, 'Nghe', 92.0, '#FF6B6B'),
                                                                (3, 'Nói', 88.5, '#4ECDC4'),
                                                                (3, 'Đọc', 95.0, '#95E1D3'),
                                                                (3, 'Viết', 90.0, '#F38181'),
                                                                (5, 'Nghe', 80.0, '#FF6B6B'),
                                                                (5, 'Nói', 75.5, '#4ECDC4'),
                                                                (5, 'Đọc', 85.5, '#95E1D3'),
                                                                (5, 'Viết', 78.0, '#F38181');

-- Insert Vocabulary Folders (User-created folders)
INSERT INTO vocabulary_folders (user_id, name, icon) VALUES
                                                         (1, 'Từ vựng hàng ngày', '📅'),
                                                         (1, 'Từ vựng công việc', '💼'),
                                                         (1, 'Từ vựng du lịch', '✈️'),
                                                         (2, 'Từ vựng cơ bản', '📚'),
                                                         (3, 'Từ vựng TOPIK', '🎯'),
                                                         (3, 'Từ vựng kinh doanh', '💰'),
                                                         (5, 'Từ vựng yêu thích', '⭐');

-- Insert Vocabulary Words (User-created vocabulary)
INSERT INTO vocabulary_words (folder_id, korean, vietnamese, pronunciation, example, is_learned) VALUES
-- Folder 1: Từ vựng hàng ngày (user 1)
(1, '일어나다', 'Thức dậy', 'i-reo-na-da', '아침에 일찍 일어나요.', FALSE),
(1, '씻다', 'Rửa, tắm', 'ssit-da', '아침에 일어나서 씻어요.', TRUE),
(1, '밥을 먹다', 'Ăn cơm', 'bab-eul meok-da', '저녁에 밥을 먹어요.', FALSE),
(1, '자다', 'Ngủ', 'ja-da', '밤에 일찍 자요.', TRUE),
-- Folder 2: Từ vựng công việc (user 1)
(2, '회사', 'Công ty', 'hoe-sa', '회사에 다녀요.', FALSE),
(2, '회의', 'Cuộc họp', 'hoe-ui', '오늘 회의가 있어요.', FALSE),
(2, '보고서', 'Báo cáo', 'bo-go-seo', '보고서를 작성해요.', TRUE),
(2, '동료', 'Đồng nghiệp', 'dong-ryo', '동료들과 일해요.', FALSE),
-- Folder 3: Từ vựng du lịch (user 1)
(3, '여행', 'Du lịch', 'yeo-haeng', '여름에 여행을 가요.', FALSE),
(3, '호텔', 'Khách sạn', 'ho-tel', '호텔에서 묵어요.', FALSE),
(3, '공항', 'Sân bay', 'gong-hang', '공항에 가요.', FALSE),
(3, '비행기', 'Máy bay', 'bi-haeng-gi', '비행기를 타요.', FALSE),
-- Folder 4: Từ vựng cơ bản (user 2)
(4, '사랑', 'Yêu', 'sa-rang', '당신을 사랑해요.', TRUE),
(4, '친구', 'Bạn bè', 'chin-gu', '친구를 만나요.', TRUE),
(4, '행복', 'Hạnh phúc', 'haeng-bok', '저는 행복해요.', FALSE),
-- Folder 5: Từ vựng TOPIK (user 3)
(5, '교육', 'Giáo dục', 'gyo-yuk', '교육이 중요해요.', FALSE),
(5, '환경', 'Môi trường', 'hwan-gyeong', '환경을 보호해야 해요.', FALSE),
(5, '경제', 'Kinh tế', 'gyeong-je', '경제가 발전해요.', TRUE),
(5, '정치', 'Chính trị', 'jeong-chi', '정치에 관심이 있어요.', FALSE),
-- Folder 6: Từ vựng kinh doanh (user 3)
(6, '계약', 'Hợp đồng', 'gye-yak', '계약서에 서명해요.', FALSE),
(6, '투자', 'Đầu tư', 'tu-ja', '사업에 투자해요.', FALSE),
(6, '이익', 'Lợi nhuận', 'i-ik', '이익이 많아요.', FALSE),
-- Folder 7: Từ vựng yêu thích (user 5)
(7, '음악', 'Âm nhạc', 'eum-ak', '음악을 들어요.', TRUE),
(7, '영화', 'Phim', 'yeong-hwa', '영화를 봐요.', TRUE),
(7, '운동', 'Thể thao', 'un-dong', '운동을 해요.', FALSE);

-- Insert Lesson Cards
INSERT INTO lesson_cards (user_id, curriculum_lesson_id, date, tag, accent_color, background_color) VALUES
                                                                                                        (1, 1, '2024-11-20', 'Đã hoàn thành', '#4ECDC4', '#E8F8F5'),
                                                                                                        (1, 2, '2024-11-22', 'Đã hoàn thành', '#4ECDC4', '#E8F8F5'),
                                                                                                        (1, 3, '2024-11-24', 'Đang học', '#FFD700', '#FFFBEA'),
                                                                                                        (2, 1, '2024-11-18', 'Đã hoàn thành', '#4ECDC4', '#E8F8F5'),
                                                                                                        (3, 1, '2024-10-15', 'Đã hoàn thành', '#4ECDC4', '#E8F8F5'),
                                                                                                        (3, 9, '2024-11-10', 'Đang học', '#FFD700', '#FFFBEA');

-- Insert Course Cards (Legacy - use CourseEnrollment instead)
INSERT INTO course_cards (user_id, course_id, completed) VALUES
                                                             (1, 1, 17),
                                                             (1, 3, 12),
                                                             (2, 1, 6),
                                                             (2, 5, 10),
                                                             (3, 2, 23);

-- Insert Competition Questions
INSERT INTO competition_questions (competition_id, question_text, question_type, correct_answer, points, question_order) VALUES
-- Questions for Competition 1 (Grammar)
(1, '다음 문장에서 맞는 조사를 고르세요: 친구___ 만났어요.', 'multiple-choice', '를', 2, 1),
(1, '"입니다"와 "이에요"의 차이점은 무엇입니까?', 'multiple-choice', '입니다는 격식체, 이에요는 비격식체', 3, 2),
(1, '다음 중 과거형이 올바른 것은?', 'multiple-choice', '먹었어요', 2, 3),
(1, '존댓말로 "가다"의 현재형은?', 'multiple-choice', '가십니다', 3, 4),
-- Questions for Competition 3 (Listening)
(3, '대화를 듣고 남자가 어디에 가는지 고르세요.', 'multiple-choice', '도서관', 2, 1),
(3, '여자의 직업은 무엇입니까?', 'multiple-choice', '선생님', 2, 2);

-- Insert Competition Question Options
INSERT INTO competition_question_options (question_id, option_text, option_order, is_correct) VALUES
-- Options for Question 1
(1, '를', 0, TRUE),
(1, '이', 1, FALSE),
(1, '가', 2, FALSE),
(1, '은', 3, FALSE),
-- Options for Question 2
(2, '입니다는 격식체, 이에요는 비격식체', 0, TRUE),
(2, '둘 다 같은 의미', 1, FALSE),
(2, '입니다는 과거형, 이에요는 현재형', 2, FALSE),
(2, '입니다는 존댓말, 이에요는 반말', 3, FALSE),
-- Options for Question 3
(3, '먹어요', 0, FALSE),
(3, '먹었어요', 1, TRUE),
(3, '먹을 거예요', 2, FALSE),
(3, '먹고 있어요', 3, FALSE),
-- Options for Question 4
(4, '갑니다', 0, FALSE),
(4, '가요', 1, FALSE),
(4, '가십니다', 2, TRUE),
(4, '가세요', 3, FALSE),
-- Options for Question 5
(5, '병원', 0, FALSE),
(5, '도서관', 1, TRUE),
(5, '학교', 2, FALSE),
(5, '공원', 3, FALSE),
-- Options for Question 6
(6, '의사', 0, FALSE),
(6, '선생님', 1, TRUE),
(6, '간호사', 2, FALSE),
(6, '학생', 3, FALSE);

-- Insert Competition Submissions
INSERT INTO competition_submissions (user_id, competition_id, question_id, answer, is_correct) VALUES
-- User 1's submissions for Competition 1
(1, 1, 1, '를', TRUE),
(1, 1, 2, '입니다는 격식체, 이에요는 비격식체', TRUE),
(1, 1, 3, '먹었어요', TRUE),
(1, 1, 4, '가요', FALSE),
-- User 3's submissions for Competition 1
(3, 1, 1, '를', TRUE),
(3, 1, 2, '입니다는 격식체, 이에요는 비격식체', TRUE),
(3, 1, 3, '먹었어요', TRUE),
(3, 1, 4, '가십니다', TRUE),
-- User 5's submissions for Competition 1
(5, 1, 1, '를', TRUE),
(5, 1, 2, '입니다는 격식체, 이에요는 비격식체', TRUE),
(5, 1, 3, '먹었어요', TRUE),
(5, 1, 4, '가십니다', TRUE),
-- User 3's submissions for Competition 3
(3, 3, 5, '도서관', TRUE),
(3, 3, 6, '선생님', TRUE);

-- Additional Curriculum Lessons for other books
INSERT INTO curriculum_lessons (curriculum_id, title, level, duration, progress, lesson_number, video_url) VALUES
-- Book 2 lessons
(2, 'Bài 4: Giao tiếp tại nhà hàng', 'Beginner', '45 phút', 25, 4, 'https://youtube.com/watch?v=sample11'),
(2, 'Bài 5: Đi du lịch', 'Beginner', '50 phút', 0, 5, 'https://youtube.com/watch?v=sample12'),
-- Book 3 lessons
(3, 'Bài 3: Kinh tế Hàn Quốc', 'Intermediate', '55 phút', 0, 3, 'https://youtube.com/watch?v=sample13'),
(3, 'Bài 4: Xã hội hiện đại', 'Intermediate', '60 phút', 0, 4, 'https://youtube.com/watch?v=sample14');

-- Additional Course Lessons
INSERT INTO course_lessons (course_id, title, level, duration, progress, lesson_number, video_url) VALUES
-- Course 2 more lessons
(2, 'Bài 3: Câu bị động', 'Advanced', '50 phút', 70, 3, 'https://youtube.com/watch?v=course2-3'),
(2, 'Bài 4: Câu sai khiến', 'Advanced', '55 phút', 60, 4, 'https://youtube.com/watch?v=course2-4'),
-- Course 3 more lessons
(3, 'Bài 3: Viết luận TOPIK', 'Intermediate', '55 phút', 65, 3, 'https://youtube.com/watch?v=course3-3'),
(3, 'Bài 4: Nghe hiểu hội thoại', 'Intermediate', '45 phút', 50, 4, 'https://youtube.com/watch?v=course3-4'),
-- Course 4 lessons
(4, 'Bài 1: Email công việc', 'Advanced', '45 phút', 100, 1, 'https://youtube.com/watch?v=course4-1'),
(4, 'Bài 2: Họp và thuyết trình', 'Advanced', '50 phút', 85, 2, 'https://youtube.com/watch?v=course4-2'),
(4, 'Bài 3: Đàm phán kinh doanh', 'Advanced', '55 phút', 70, 3, 'https://youtube.com/watch?v=course4-3'),
-- Course 5 lessons
(5, 'Bài 3: Mua sắm', 'Beginner', '35 phút', 100, 3, 'https://youtube.com/watch?v=course5-3'),
(5, 'Bài 4: Gặp gỡ bạn bè', 'Beginner', '40 phút', 90, 4, 'https://youtube.com/watch?v=course5-4'),
(5, 'Bài 5: Hỏi đường', 'Beginner', '35 phút', 75, 5, 'https://youtube.com/watch?v=course5-5');

-- More Curriculum Vocabulary
INSERT INTO curriculum_vocabulary (curriculum_lesson_id, korean, vietnamese, pronunciation, example) VALUES
                                                                                                         (4, '물건', 'Đồ vật', 'mul-geon', '이 물건은 얼마예요?'),
                                                                                                         (4, '사다', 'Mua', 'sa-da', '옷을 사요.'),
                                                                                                         (4, '팔다', 'Bán', 'pal-da', '가게에서 팔아요.'),
                                                                                                         (5, '아침', 'Buổi sáng', 'a-chim', '아침에 운동해요.'),
                                                                                                         (5, '점심', 'Buổi trưa', 'jeom-sim', '점심에 밥을 먹어요.'),
                                                                                                         (5, '저녁', 'Buổi tối', 'jeo-nyeok', '저녁에 텔레비전을 봐요.');

-- More Course Vocabulary
INSERT INTO course_vocabulary (course_lesson_id, korean, vietnamese, pronunciation, example) VALUES
                                                                                                 (4, '나이', 'Tuổi', 'na-i', '나이가 몇 살이에요?'),
                                                                                                 (4, '생일', 'Sinh nhật', 'saeng-il', '생일이 언제예요?'),
                                                                                                 (5, '좋아하다', 'Thích', 'jo-a-ha-da', '음악을 좋아해요.'),
                                                                                                 (5, '싫어하다', 'Ghét', 'sir-eo-ha-da', '매운 음식을 싫어해요.');

-- More Grammar
INSERT INTO grammar (curriculum_lesson_id, title, explanation) VALUES
                                                                   (4, '얼마예요?', 'Cấu trúc hỏi giá. Sử dụng khi muốn hỏi giá cả của một món đồ.'),
                                                                   (5, '에', 'Trợ từ chỉ thời gian. Sử dụng trước danh từ chỉ thời gian để biểu thị thời điểm.');

-- More Grammar Examples
INSERT INTO grammar_examples (grammar_id, example_text) VALUES
                                                            (4, '이 사과는 얼마예요? (Quả táo này giá bao nhiêu?)'),
                                                            (4, '저 가방은 얼마입니까? (Cái túi kia giá bao nhiêu?)'),
                                                            (5, '아침에 일어나요. (Thức dậy vào buổi sáng.)'),
                                                            (5, '저녁에 친구를 만나요. (Gặp bạn vào buổi tối.)');

-- More Exercises
INSERT INTO exercises (curriculum_lesson_id, type, question, answer, correct_index) VALUES
                                                                                        (4, 'multiple-choice', '"얼마예요?"의 의미는 무엇입니까?', NULL, 2),
                                                                                        (5, 'fill-blank', '___에 학교에 가요. (Tôi đi học vào buổi sáng)', '아침', NULL);

-- More Exercise Options
INSERT INTO exercise_options (exercise_id, option_text, option_order) VALUES
                                                                          (5, '얼마나', 0),
                                                                          (5, '어디', 1),
                                                                          (5, '얼마예요?는 giá bao nhiêu', 2),
                                                                          (5, '언제', 3);


-- Thêm dữ liệu mẫu cho blog_comments
INSERT INTO blog_comments (post_id, user_id, content, likes) VALUES
-- Comments cho post 1
(1, 2, 'Bài viết rất hay và bổ ích! Cảm ơn tác giả đã chia sẻ.', 15),
(1, 3, 'Mình đã áp dụng những tips này và thấy hiệu quả ngay. Thanks!', 8),
(1, 4, 'Có thể giải thích rõ hơn phần cuối được không ạ?', 3),
(1, 5, 'Nội dung chất lượng, đang chờ phần 2 của series này.', 12),

-- Comments cho post 2
(2, 1, 'Code example rất dễ hiểu, đã save lại để tham khảo.', 20),
(2, 3, 'Có vấn đề nhỏ ở dòng 15, nên sửa thành async/await.', 5),
(2, 4, 'Perfect timing! Đang cần học phần này. 👍', 10),
(2, 6, 'Bạn có thể làm video hướng dẫn được không?', 2),

-- Comments cho post 3
(3, 2, 'Tutorial rất chi tiết, follow từng bước đều work!', 18),
(3, 5, 'Mình gặp lỗi ở bước 3, ai giúp với.', 1),
(3, 1, 'Đã thử và chạy ngon lành. Cảm ơn bạn nhiều!', 14),
(3, 6, 'Có thể update thêm phần deployment không?', 4),

-- Comments cho post 4
(4, 3, 'So sánh rất khách quan và đầy đủ. Helpful!', 22),
(4, 4, 'Mình nghĩ phương án A vẫn tốt hơn trong trường hợp X.', 7),
(4, 2, 'Data analysis rất thuyết phục. Well done!', 16),

-- Comments cho post 5
(5, 5, 'Best practices này rất thực tế. Đã bookmark!', 25),
(5, 6, 'Team mình đang áp dụng những tips này. Great share!', 11),
(5, 1, 'Có case study thực tế nào không nhỉ?', 3),
(5, 4, 'Checklist ở cuối bài rất hữu ích. 💯', 19),

-- Comments cho post 6
(6, 2, 'Quick tip nhưng rất hay! Đã share cho team.', 13),
(6, 3, 'Ai đã thử cách này chưa? Mình đang cân nhắc.', 2),
(6, 5, 'Simple but effective. Love it!', 9),

-- Comments cho post 7
(7, 1, 'Bài review chi tiết và trung thực. Cảm ơn!', 21),
(7, 4, 'Mình có trải nghiệm khác một chút, nhưng overall đồng ý.', 6),
(7, 6, 'Đang chờ mua, xem review này càng quyết tâm hơn.', 15),

-- Comments cho post 8
(8, 3, 'Troubleshooting guide rất đầy đủ. Saved my day!', 28),
(8, 2, 'Solution 2 work perfect cho case của mình. Thanks!', 17),
(8, 5, 'Có thể thêm phần về error handling không?', 4),

-- Comments cho post 9
(9, 4, 'Trend analysis rất thú vị. Đúng là năm nay thay đổi nhiều.', 24),
(9, 6, 'Data source từ đâu vậy bạn? Muốn research thêm.', 5),
(9, 1, 'Predictions phần cuối rất bold nhưng có lý. 🎯', 20),

-- Comments cho post 10
(10, 5, 'Step by step rất rõ ràng. Newbie friendly!', 30),
(10, 2, 'Screenshot minh họa rất hữu ích. A+ tutorial!', 23),
(10, 3, 'Đã làm theo và success ngay lần đầu. Awesome!', 26);

-- Thêm dữ liệu mẫu cho blog_comment_likes
INSERT INTO blog_comment_likes (comment_id, user_id) VALUES
-- Likes cho comment 1
(1, 1), (1, 3), (1, 4), (1, 5), (1, 6),
-- Likes cho comment 2
(2, 1), (2, 2), (2, 4), (2, 6),
-- Likes cho comment 3
(3, 2), (3, 5), (3, 6),
-- Likes cho comment 4
(4, 1), (4, 3), (4, 4), (4, 6),
-- Likes cho comment 5
(5, 2), (5, 3), (5, 4), (5, 5), (5, 6),
-- Likes cho comment 6
(6, 1), (6, 2), (6, 4), (6, 5),
-- Likes cho comment 7
(7, 1), (7, 2), (7, 3), (7, 5), (7, 6),
-- Likes cho comment 8
(8, 3), (8, 5),
-- Likes cho comment 9
(9, 1), (9, 2), (9, 3), (9, 4), (9, 5),
-- Likes cho comment 10
(10, 2), (10, 3), (10, 4), (10, 6),
-- Likes cho comment 11
(11, 1), (11, 2), (11, 4), (11, 5), (11, 6),
-- Likes cho comment 12
(12, 2), (12, 3), (12, 5),
-- Likes cho comment 13
(13, 1), (13, 3), (13, 4), (13, 5), (13, 6),
-- Likes cho comment 14
(14, 3),
-- Likes cho comment 15
(15, 2), (15, 3), (15, 4), (15, 5), (15, 6),
-- Likes cho comment 16
(16, 1), (16, 3), (16, 5), (16, 6),
-- Likes cho comment 17
(17, 1), (17, 2), (17, 3), (17, 4), (17, 5),
-- Likes cho comment 18
(18, 1), (18, 2), (18, 3), (18, 5), (18, 6),
-- Likes cho comment 19
(19, 2), (19, 3),
-- Likes cho comment 20
(20, 1), (20, 2), (20, 3), (20, 4), (20, 5),
-- Likes cho comment 21
(21, 2), (21, 3), (21, 4), (21, 5), (21, 6),
-- Likes cho comment 22
(22, 1), (22, 2), (22, 5),
-- Likes cho comment 23
(23, 2), (23, 3), (23, 4), (23, 5),
-- Likes cho comment 24
(24, 1), (24, 2), (24, 3), (24, 4), (24, 5),
-- Likes cho comment 25
(25, 1), (25, 3), (25, 5),
-- Likes cho comment 26
(26, 1), (26, 2), (26, 3), (26, 4), (26, 6),
-- Likes cho comment 27
(27, 1), (27, 2), (27, 3), (27, 4), (27, 5),
-- Likes cho comment 28
(28, 1), (28, 2), (28, 4),
-- Likes cho comment 29
(29, 1), (29, 2), (29, 3), (29, 4), (29, 5),
-- Likes cho comment 30
(30, 1), (30, 3), (30, 4), (30, 6);


-- End of KoreanHwa Sample Data
-- Total records created:
-- - 5 Users (all with password: 123456)
-- - 6 Curriculum books
-- - 5 Courses with instructors
-- - Multiple lessons, vocabulary, grammar, exercises
-- - User progress, achievements, rankings
-- - Blog posts, competitions, materials
-- - User-created vocabulary folders and words