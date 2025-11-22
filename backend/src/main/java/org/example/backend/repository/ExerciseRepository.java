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
    List<Exercise> findByLessonId(Long lessonId);
    Page<Exercise> findByLessonId(Long lessonId, Pageable pageable);
}

