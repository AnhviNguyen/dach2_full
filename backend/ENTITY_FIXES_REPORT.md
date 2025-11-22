# Entity Fixes Report

## Summary of Changes

### 1. CourseCard Entity

**Issues Found:**
- ❌ Entity name contains "Course" but missing `@ManyToOne` to `Course`
- ❌ Duplicate fields: `title`, `lessons`, `progress`, `accentColor` (already in `Course`)
- ❌ Tracks same relationship as `CourseEnrollment` (user-course)

**Fixes Applied:**
- ✅ Added `@ManyToOne` to `Course` entity
- ✅ Removed duplicate fields: `title`, `lessons`, `progress`, `accentColor`
- ✅ Kept only `completed` field (user-specific data)
- ✅ Added `@Deprecated` annotation - functionality merged into `CourseEnrollment`
- ✅ Added `@Column(name = "id")` for consistency

**Result:**
- `CourseCard` now references `Course` via FK
- Duplicate data removed - accessed via `course.title`, `course.lessons`, etc.
- Deprecated in favor of `CourseEnrollment`

---

### 2. LessonCard Entity

**Issues Found:**
- ❌ Entity name contains "Lesson" but missing `@ManyToOne` to `Lesson`
- ❌ Duplicate field: `title` (already in `Lesson`)

**Fixes Applied:**
- ✅ Added `@ManyToOne` to `Lesson` entity
- ✅ Removed duplicate `title` field - now accessed via `lesson.title`
- ✅ Added `@Column(name = "id")` for consistency

**Result:**
- `LessonCard` now references `Lesson` via FK
- Duplicate `title` removed - accessed via relationship

---

### 3. CourseEnrollment Entity

**Issues Found:**
- ❌ Missing fields from `CourseCard` that track same relationship

**Fixes Applied:**
- ✅ Added `completedLessons` field (merged from `CourseCard.completed`)
- ✅ Added comment explaining merge from `CourseCard`

**Result:**
- `CourseEnrollment` now contains all user-course relationship data
- Single source of truth for user-course tracking

---

## Entities Checked (No Issues Found)

✅ **Task** - No duplicates, proper structure
✅ **DashboardStats** - OneToOne with User, no duplicates
✅ **SkillProgress** - ManyToOne with User, no duplicates
✅ **BlogTag** - ManyToOne with BlogPost, no duplicates
✅ **BlogLike** - ManyToOne with BlogPost and User, no duplicates
✅ **ExerciseOption** - ManyToOne with Exercise, no duplicates
✅ **GrammarExample** - ManyToOne with Grammar, no duplicates
✅ **CompetitionCategory** - Standalone entity, no issues
✅ **SpeakPracticeMission** - ManyToOne with User, no duplicates
✅ **SpeakPracticeStat** - ManyToOne with User, no duplicates

---

## Migration Notes

### Database Changes Required

1. **course_cards table:**
   - Add `course_id` column (FK to `courses.id`)
   - Remove `title` column (use `courses.title`)
   - Remove `lessons` column (use `courses.lessons`)
   - Remove `progress` column (use `course_enrollments.progress`)
   - Remove `accent_color` column (use `courses.accent_color`)

2. **lesson_cards table:**
   - Add `lesson_id` column (FK to `lessons.id`)
   - Remove `title` column (use `lessons.title`)

3. **course_enrollments table:**
   - Add `completed_lessons` column (INT DEFAULT 0)

### Code Changes Required

1. **Update Service Layer:**
   - Update `CourseCardService` to use `course.title`, `course.lessons`, etc.
   - Update `LessonCardService` to use `lesson.title`
   - Migrate `CourseCard` logic to `CourseEnrollment`

2. **Update DTOs:**
   - `CourseCardDataResponse` should map from `CourseEnrollment` + `Course`
   - `LessonCardDataResponse` should map from `LessonCard` + `Lesson`

3. **Consider Deprecation:**
   - `CourseCard` entity is deprecated - migrate to `CourseEnrollment`
   - Update all references to use `CourseEnrollment` instead

---

## Benefits

1. **Eliminated Data Duplication:**
   - No more duplicate `title`, `lessons`, `progress` fields
   - Single source of truth for course/lesson data

2. **Proper Relationships:**
   - All entities with parent names now have proper FK relationships
   - Better data integrity and consistency

3. **Merged Redundant Entities:**
   - `CourseCard` and `CourseEnrollment` merged into one
   - Simplified data model

4. **Better Normalization:**
   - Reduced redundancy
   - Easier to maintain and update

