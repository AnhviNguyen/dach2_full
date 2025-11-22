package org.example.backend.repository;

import org.example.backend.entity.Vocabulary;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface VocabularyRepository extends JpaRepository<Vocabulary, Long> {
    Page<Vocabulary> findAll(Pageable pageable);
    List<Vocabulary> findByLessonId(Long lessonId);
    Page<Vocabulary> findByLessonId(Long lessonId, Pageable pageable);
}

