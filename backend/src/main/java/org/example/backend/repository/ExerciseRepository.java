package org.example.backend.repository;

import org.example.backend.entity.Exercise;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ExerciseRepository extends JpaRepository<Exercise, Long> {
    Page<Exercise> findAll(Pageable pageable);
    List<Exercise> findByCurriculumLessonId(Long curriculumLessonId);
    List<Exercise> findByCourseLessonId(Long courseLessonId);
    Page<Exercise> findByCurriculumLessonId(Long curriculumLessonId, Pageable pageable);
    Page<Exercise> findByCourseLessonId(Long courseLessonId, Pageable pageable);
}

