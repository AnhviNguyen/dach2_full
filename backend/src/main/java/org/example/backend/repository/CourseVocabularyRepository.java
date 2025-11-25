package org.example.backend.repository;

import org.example.backend.entity.CourseVocabulary;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface CourseVocabularyRepository extends JpaRepository<CourseVocabulary, Long> {
    Page<CourseVocabulary> findAll(Pageable pageable);
    List<CourseVocabulary> findByCourseLessonId(Long courseLessonId);
    Page<CourseVocabulary> findByCourseLessonId(Long courseLessonId, Pageable pageable);
}

