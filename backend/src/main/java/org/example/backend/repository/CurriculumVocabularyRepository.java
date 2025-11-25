package org.example.backend.repository;

import org.example.backend.entity.CurriculumVocabulary;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface CurriculumVocabularyRepository extends JpaRepository<CurriculumVocabulary, Long> {
    Page<CurriculumVocabulary> findAll(Pageable pageable);
    List<CurriculumVocabulary> findByCurriculumLessonId(Long curriculumLessonId);
    Page<CurriculumVocabulary> findByCurriculumLessonId(Long curriculumLessonId, Pageable pageable);
}

