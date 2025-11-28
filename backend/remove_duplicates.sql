-- ============================================
-- SQL Script để xóa dữ liệu duplicate trong XAMPP
-- Chạy từng phần một và kiểm tra kết quả trước khi chạy phần tiếp theo
-- ============================================

-- ============================================
-- PHẦN 1: XÓA DUPLICATE BLOG POSTS
-- ============================================
-- Xóa các bản ghi liên quan trước
DELETE t1 FROM blog_tags t1
INNER JOIN blog_posts p1 ON t1.post_id = p1.id
INNER JOIN blog_posts p2 ON p1.title = p2.title 
    AND p1.content = p2.content 
    AND p1.id > p2.id;

DELETE l1 FROM blog_likes l1
INNER JOIN blog_posts p1 ON l1.post_id = p1.id
INNER JOIN blog_posts p2 ON p1.title = p2.title 
    AND p1.content = p2.content 
    AND p1.id > p2.id;

DELETE c1 FROM blog_comments c1
INNER JOIN blog_posts p1 ON c1.post_id = p1.id
INNER JOIN blog_posts p2 ON p1.title = p2.title 
    AND p1.content = p2.content 
    AND p1.id > p2.id;

-- Xóa duplicate blog posts (giữ lại ID nhỏ nhất)
DELETE p1 FROM blog_posts p1
INNER JOIN blog_posts p2 
WHERE p1.id > p2.id 
    AND p1.title = p2.title 
    AND p1.content = p2.content;

-- ============================================
-- PHẦN 2: XÓA DUPLICATE COMPETITIONS
-- ============================================
-- Xóa các bản ghi liên quan trước
DELETE cp1 FROM competition_participants cp1
INNER JOIN competitions c1 ON cp1.competition_id = c1.id
INNER JOIN competitions c2 ON c1.title = c2.title 
    AND c1.description = c2.description 
    AND c1.id > c2.id;

DELETE cq1 FROM competition_questions cq1
INNER JOIN competitions c1 ON cq1.competition_id = c1.id
INNER JOIN competitions c2 ON c1.title = c2.title 
    AND c1.description = c2.description 
    AND c1.id > c2.id;

DELETE cs1 FROM competition_submissions cs1
INNER JOIN competitions c1 ON cs1.competition_id = c1.id
INNER JOIN competitions c2 ON c1.title = c2.title 
    AND c1.description = c2.description 
    AND c1.id > c2.id;

-- Xóa duplicate competitions (giữ lại ID nhỏ nhất)
DELETE c1 FROM competitions c1
INNER JOIN competitions c2 
WHERE c1.id > c2.id 
    AND c1.title = c2.title 
    AND (c1.description = c2.description OR (c1.description IS NULL AND c2.description IS NULL));

-- ============================================
-- PHẦN 3: XÓA DUPLICATE COURSES
-- ============================================
-- Xóa các bản ghi liên quan trước
DELETE ce1 FROM course_enrollments ce1
INNER JOIN courses c1 ON ce1.course_id = c1.id
INNER JOIN courses c2 ON c1.title = c2.title 
    AND c1.instructor = c2.instructor 
    AND c1.id > c2.id;

DELETE cl1 FROM course_lessons cl1
INNER JOIN courses c1 ON cl1.course_id = c1.id
INNER JOIN courses c2 ON c1.title = c2.title 
    AND c1.instructor = c2.instructor 
    AND c1.id > c2.id;

-- Xóa duplicate courses (giữ lại ID nhỏ nhất)
DELETE c1 FROM courses c1
INNER JOIN courses c2 
WHERE c1.id > c2.id 
    AND c1.title = c2.title 
    AND c1.instructor = c2.instructor;

-- ============================================
-- PHẦN 4: XÓA DUPLICATE CURRICULUM
-- ============================================
-- Xóa các bản ghi liên quan trước
DELETE cp1 FROM curriculum_progress cp1
INNER JOIN curriculum c1 ON cp1.curriculum_id = c1.id
INNER JOIN curriculum c2 ON c1.book_number = c2.book_number 
    AND c1.id > c2.id;

DELETE cl1 FROM curriculum_lessons cl1
INNER JOIN curriculum c1 ON cl1.curriculum_id = c1.id
INNER JOIN curriculum c2 ON c1.book_number = c2.book_number 
    AND c1.id > c2.id;

-- Xóa duplicate curriculum (giữ lại ID nhỏ nhất)
DELETE c1 FROM curriculum c1
INNER JOIN curriculum c2 
WHERE c1.id > c2.id 
    AND c1.book_number = c2.book_number;

-- ============================================
-- PHẦN 5: XÓA DUPLICATE TEXTBOOKS
-- ============================================
-- Xóa các bản ghi liên quan trước
DELETE tp1 FROM textbook_progress tp1
INNER JOIN textbooks t1 ON tp1.textbook_id = t1.id
INNER JOIN textbooks t2 ON t1.book_number = t2.book_number 
    AND t1.id > t2.id;

DELETE tl1 FROM textbook_lessons tl1
INNER JOIN textbooks t1 ON tl1.textbook_id = t1.id
INNER JOIN textbooks t2 ON t1.book_number = t2.book_number 
    AND t1.id > t2.id;

-- Xóa duplicate textbooks (giữ lại ID nhỏ nhất)
DELETE t1 FROM textbooks t1
INNER JOIN textbooks t2 
WHERE t1.id > t2.id 
    AND t1.book_number = t2.book_number;

-- ============================================
-- PHẦN 6: XÓA DUPLICATE COURSE LESSONS
-- ============================================
-- Xóa các bản ghi liên quan trước
DELETE cv1 FROM course_vocabulary cv1
INNER JOIN course_lessons cl1 ON cv1.course_lesson_id = cl1.id
INNER JOIN course_lessons cl2 ON cl1.course_id = cl2.course_id 
    AND cl1.title = cl2.title 
    AND cl1.id > cl2.id;

DELETE g1 FROM grammar g1
INNER JOIN course_lessons cl1 ON g1.course_lesson_id = cl1.id
INNER JOIN course_lessons cl2 ON cl1.course_id = cl2.course_id 
    AND cl1.title = cl2.title 
    AND cl1.id > cl2.id;

DELETE e1 FROM exercises e1
INNER JOIN course_lessons cl1 ON e1.course_lesson_id = cl1.id
INNER JOIN course_lessons cl2 ON cl1.course_id = cl2.course_id 
    AND cl1.title = cl2.title 
    AND cl1.id > cl2.id;

-- Xóa duplicate course lessons (giữ lại ID nhỏ nhất)
DELETE cl1 FROM course_lessons cl1
INNER JOIN course_lessons cl2 
WHERE cl1.id > cl2.id 
    AND cl1.course_id = cl2.course_id 
    AND cl1.title = cl2.title;

-- ============================================
-- PHẦN 7: XÓA DUPLICATE CURRICULUM LESSONS
-- ============================================
-- Xóa các bản ghi liên quan trước
DELETE cv1 FROM curriculum_vocabulary cv1
INNER JOIN curriculum_lessons cl1 ON cv1.curriculum_lesson_id = cl1.id
INNER JOIN curriculum_lessons cl2 ON cl1.curriculum_id = cl2.curriculum_id 
    AND cl1.title = cl2.title 
    AND cl1.id > cl2.id;

DELETE g1 FROM grammar g1
INNER JOIN curriculum_lessons cl1 ON g1.curriculum_lesson_id = cl1.id
INNER JOIN curriculum_lessons cl2 ON cl1.curriculum_id = cl2.curriculum_id 
    AND cl1.title = cl2.title 
    AND cl1.id > cl2.id;

DELETE e1 FROM exercises e1
INNER JOIN curriculum_lessons cl1 ON e1.curriculum_lesson_id = cl1.id
INNER JOIN curriculum_lessons cl2 ON cl1.curriculum_id = cl2.curriculum_id 
    AND cl1.title = cl2.title 
    AND cl1.id > cl2.id;

-- Xóa duplicate curriculum lessons (giữ lại ID nhỏ nhất)
DELETE cl1 FROM curriculum_lessons cl1
INNER JOIN curriculum_lessons cl2 
WHERE cl1.id > cl2.id 
    AND cl1.curriculum_id = cl2.curriculum_id 
    AND cl1.title = cl2.title;

-- ============================================
-- PHẦN 8: KIỂM TRA SỐ LƯỢNG SAU KHI XÓA
-- ============================================
SELECT 'blog_posts' as table_name, COUNT(*) as total_records FROM blog_posts
UNION ALL
SELECT 'competitions', COUNT(*) FROM competitions
UNION ALL
SELECT 'courses', COUNT(*) FROM courses
UNION ALL
SELECT 'curriculum', COUNT(*) FROM curriculum
UNION ALL
SELECT 'textbooks', COUNT(*) FROM textbooks
UNION ALL
SELECT 'course_lessons', COUNT(*) FROM course_lessons
UNION ALL
SELECT 'curriculum_lessons', COUNT(*) FROM curriculum_lessons;

-- ============================================
-- PHẦN 9: RESET AUTO_INCREMENT (Tùy chọn)
-- ============================================
-- Chỉ chạy nếu bạn muốn reset ID về số nhỏ nhất
-- ALTER TABLE blog_posts AUTO_INCREMENT = 1;
-- ALTER TABLE competitions AUTO_INCREMENT = 1;
-- ALTER TABLE courses AUTO_INCREMENT = 1;
-- ALTER TABLE curriculum AUTO_INCREMENT = 1;
-- ALTER TABLE textbooks AUTO_INCREMENT = 1;
-- ALTER TABLE course_lessons AUTO_INCREMENT = 1;
-- ALTER TABLE curriculum_lessons AUTO_INCREMENT = 1;

