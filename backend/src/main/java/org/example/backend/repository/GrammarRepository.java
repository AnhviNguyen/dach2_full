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
    List<Grammar> findByLessonId(Long lessonId);
    Page<Grammar> findByLessonId(Long lessonId, Pageable pageable);
}

