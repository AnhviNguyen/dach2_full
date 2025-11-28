-- SQL script to remove duplicate vocabulary entries
-- Run this script to clean up duplicate vocabulary in curriculum_vocabulary table

-- Step 1: Identify duplicates (for review)
-- This query shows all duplicate vocabulary entries
SELECT 
    curriculum_lesson_id,
    korean,
    vietnamese,
    pronunciation,
    COUNT(*) as duplicate_count,
    GROUP_CONCAT(id ORDER BY id) as ids
FROM curriculum_vocabulary
GROUP BY curriculum_lesson_id, korean, vietnamese, pronunciation, example
HAVING COUNT(*) > 1
ORDER BY curriculum_lesson_id, korean;

-- Step 2: Delete duplicates, keeping only the entry with the minimum ID
-- This will delete all duplicate entries except the one with the smallest ID
DELETE cv1 FROM curriculum_vocabulary cv1
INNER JOIN curriculum_vocabulary cv2
WHERE 
    cv1.id > cv2.id
    AND cv1.curriculum_lesson_id = cv2.curriculum_lesson_id
    AND cv1.korean = cv2.korean
    AND cv1.vietnamese = cv2.vietnamese
    AND (cv1.pronunciation = cv2.pronunciation OR (cv1.pronunciation IS NULL AND cv2.pronunciation IS NULL))
    AND (cv1.example = cv2.example OR (cv1.example IS NULL AND cv2.example IS NULL));

-- Step 3: Verify no duplicates remain
-- This should return 0 rows if cleanup was successful
SELECT 
    curriculum_lesson_id,
    korean,
    vietnamese,
    COUNT(*) as count
FROM curriculum_vocabulary
GROUP BY curriculum_lesson_id, korean, vietnamese, pronunciation, example
HAVING COUNT(*) > 1;

-- Alternative: If you want to be more conservative, you can first create a backup
-- CREATE TABLE curriculum_vocabulary_backup AS SELECT * FROM curriculum_vocabulary;

-- Then run the delete query above

