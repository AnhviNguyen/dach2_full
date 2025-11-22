# Migration Guide - Entity Structure Changes

## Tổng quan thay đổi

Sau khi refactor entities, cần cập nhật database schema. Các thay đổi chính:

### 1. **course_enrollments** table
- ✅ **Thêm**: `completed_lessons INT DEFAULT 0`
- 📝 **Lý do**: Merge từ `course_cards.completed`

### 2. **course_cards** table
- ✅ **Thêm**: `course_id BIGINT NOT NULL` (FK to courses)
- ❌ **Xóa**: `title`, `progress`, `lessons`, `accent_color` (duplicate fields)
- 📝 **Lý do**: Tránh duplicate data, dùng từ `courses` table

### 3. **lesson_cards** table
- ✅ **Thêm**: `lesson_id BIGINT NOT NULL` (FK to lessons)
- ❌ **Xóa**: `title` (duplicate field)
- 📝 **Lý do**: Tránh duplicate data, dùng từ `lessons` table

---

## Các bước Migration

### Bước 1: Backup Database

```sql
-- Backup các table sẽ thay đổi
CREATE TABLE course_cards_backup AS SELECT * FROM course_cards;
CREATE TABLE lesson_cards_backup AS SELECT * FROM lesson_cards;
CREATE TABLE course_enrollments_backup AS SELECT * FROM course_enrollments;
```

### Bước 2: Cập nhật course_enrollments

```sql
-- Thêm column mới
ALTER TABLE course_enrollments 
ADD COLUMN completed_lessons INT DEFAULT 0;

-- Migrate data từ course_cards (nếu có)
UPDATE course_enrollments ce
INNER JOIN course_cards cc ON ce.user_id = cc.user_id 
    AND EXISTS (SELECT 1 FROM courses c WHERE c.title = cc.title LIMIT 1)
SET ce.completed_lessons = cc.completed
WHERE ce.completed_lessons = 0 AND cc.completed > 0;
```

### Bước 3: Cập nhật lesson_cards

```sql
-- 1. Thêm column lesson_id (nullable tạm thời)
ALTER TABLE lesson_cards 
ADD COLUMN lesson_id BIGINT NULL;

-- 2. Map title -> lesson_id (CẦN KIỂM TRA MANUALLY)
-- Xem các lesson_cards chưa có lesson_id:
SELECT DISTINCT lc.id, lc.title, l.id as lesson_id 
FROM lesson_cards lc
LEFT JOIN lessons l ON lc.title = l.title
WHERE lc.lesson_id IS NULL;

-- 3. Update lesson_id dựa trên title match
UPDATE lesson_cards lc
INNER JOIN lessons l ON lc.title = l.title
SET lc.lesson_id = l.id
WHERE lc.lesson_id IS NULL;

-- 4. Xử lý các record không match (có thể cần tạo lesson mới hoặc xóa)
-- Kiểm tra:
SELECT * FROM lesson_cards WHERE lesson_id IS NULL;

-- 5. Sau khi đảm bảo tất cả có lesson_id, set NOT NULL
ALTER TABLE lesson_cards 
MODIFY COLUMN lesson_id BIGINT NOT NULL;

-- 6. Thêm foreign key
ALTER TABLE lesson_cards 
ADD CONSTRAINT fk_lesson_cards_lesson 
FOREIGN KEY (lesson_id) REFERENCES lessons(id) ON DELETE CASCADE;

-- 7. Xóa column title (SAU KHI ĐÃ VERIFY)
ALTER TABLE lesson_cards DROP COLUMN title;
```

### Bước 4: Cập nhật course_cards

```sql
-- 1. Thêm column course_id (nullable tạm thời)
ALTER TABLE course_cards 
ADD COLUMN course_id BIGINT NULL;

-- 2. Map title -> course_id (CẦN KIỂM TRA MANUALLY)
-- Xem các course_cards chưa có course_id:
SELECT DISTINCT cc.id, cc.title, c.id as course_id 
FROM course_cards cc
LEFT JOIN courses c ON cc.title = c.title
WHERE cc.course_id IS NULL;

-- 3. Update course_id dựa trên title match
UPDATE course_cards cc
INNER JOIN courses c ON cc.title = c.title
SET cc.course_id = c.id
WHERE cc.course_id IS NULL;

-- 4. Xử lý các record không match
-- Kiểm tra:
SELECT * FROM course_cards WHERE course_id IS NULL;

-- 5. Sau khi đảm bảo tất cả có course_id, set NOT NULL
ALTER TABLE course_cards 
MODIFY COLUMN course_id BIGINT NOT NULL;

-- 6. Thêm foreign key
ALTER TABLE course_cards 
ADD CONSTRAINT fk_course_cards_course 
FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE;

-- 7. Xóa các duplicate columns (SAU KHI ĐÃ VERIFY)
ALTER TABLE course_cards DROP COLUMN title;
ALTER TABLE course_cards DROP COLUMN progress;
ALTER TABLE course_cards DROP COLUMN lessons;
ALTER TABLE course_cards DROP COLUMN accent_color;
```

### Bước 5: Verify Migration

```sql
-- Kiểm tra orphaned records
SELECT 'lesson_cards without lesson_id' as check_type, COUNT(*) as count
FROM lesson_cards WHERE lesson_id IS NULL
UNION ALL
SELECT 'course_cards without course_id' as check_type, COUNT(*) as count
FROM course_cards WHERE course_id IS NULL;

-- Kiểm tra foreign key integrity
SELECT 'Invalid lesson_cards' as check_type, COUNT(*) as count
FROM lesson_cards lc
LEFT JOIN lessons l ON lc.lesson_id = l.id
WHERE l.id IS NULL
UNION ALL
SELECT 'Invalid course_cards' as check_type, COUNT(*) as count
FROM course_cards cc
LEFT JOIN courses c ON cc.course_id = c.id
WHERE c.id IS NULL;
```

---

## Lưu ý quan trọng

### ⚠️ Trước khi migration:

1. **BACKUP DATABASE** - Bắt buộc!
2. Test trong môi trường development trước
3. Kiểm tra data hiện tại có match với courses/lessons không

### ⚠️ Trong quá trình migration:

1. **Mapping title -> id**: 
   - Cần kiểm tra manually vì có thể có nhiều courses/lessons cùng title
   - Có thể cần thêm logic để match chính xác hơn

2. **Orphaned records**:
   - Các `lesson_cards` hoặc `course_cards` không match với `lessons`/`courses` cần xử lý:
     - Tạo lesson/course mới
     - Hoặc xóa record nếu không cần thiết

3. **Data loss risk**:
   - Các column bị xóa (`title`, `progress`, etc.) sẽ mất data
   - Đảm bảo đã migrate hết data cần thiết trước khi DROP COLUMN

### ⚠️ Sau khi migration:

1. **Test application**:
   - Test tất cả API endpoints liên quan
   - Verify data hiển thị đúng
   - Check foreign key constraints

2. **Update application code**:
   - Service layer cần update để dùng relationship thay vì duplicate fields
   - DTO mapping cần update

---

## Rollback Plan

Nếu có vấn đề, có thể rollback:

```sql
-- Restore từ backup
DROP TABLE IF EXISTS course_cards;
DROP TABLE IF EXISTS lesson_cards;
DROP TABLE IF EXISTS course_enrollments;

CREATE TABLE course_cards AS SELECT * FROM course_cards_backup;
CREATE TABLE lesson_cards AS SELECT * FROM lesson_cards_backup;
CREATE TABLE course_enrollments AS SELECT * FROM course_enrollments_backup;
```

---

## Checklist Migration

- [ ] Backup database
- [ ] Test migration script trong dev environment
- [ ] Update course_enrollments (thêm completed_lessons)
- [ ] Map và update lesson_cards.lesson_id
- [ ] Map và update course_cards.course_id
- [ ] Verify không có orphaned records
- [ ] Xóa duplicate columns
- [ ] Test application
- [ ] Update application code
- [ ] Deploy to production (nếu dev OK)

