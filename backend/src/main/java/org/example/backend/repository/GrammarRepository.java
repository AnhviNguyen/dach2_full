package org.example.backend.repository;

import org.example.backend.entity.Grammar;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface GrammarRepository extends JpaRepository<Grammar, Long> {
    Page<Grammar> findAll(Pageable pageable);
    List<Grammar> findByCurriculumLessonId(Long curriculumLessonId);
    List<Grammar> findByCourseLessonId(Long courseLessonId);
    Page<Grammar> findByCurriculumLessonId(Long curriculumLessonId, Pageable pageable);
    Page<Grammar> findByCourseLessonId(Long courseLessonId, Pageable pageable);
}

