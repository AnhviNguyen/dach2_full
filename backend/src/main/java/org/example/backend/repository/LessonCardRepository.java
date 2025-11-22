package org.example.backend.repository;

import org.example.backend.entity.LessonCard;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface LessonCardRepository extends JpaRepository<LessonCard, Long> {
    Page<LessonCard> findAll(Pageable pageable);
    List<LessonCard> findByUserId(Long userId);
    Page<LessonCard> findByUserId(Long userId, Pageable pageable);
}

