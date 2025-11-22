package org.example.backend.repository;

import org.example.backend.entity.Lesson;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface LessonRepository extends JpaRepository<Lesson, Long> {
    Page<Lesson> findAll(Pageable pageable);
    List<Lesson> findByTextbookId(Long textbookId);
    List<Lesson> findByCourseId(Long courseId);
    Optional<Lesson> findById(Long id);
    
    @Query("SELECT l FROM Lesson l WHERE l.textbook.id = :textbookId")
    Page<Lesson> findByTextbookIdWithPagination(@Param("textbookId") Long textbookId, Pageable pageable);
    
    @Query("SELECT l FROM Lesson l WHERE l.course.id = :courseId")
    Page<Lesson> findByCourseIdWithPagination(@Param("courseId") Long courseId, Pageable pageable);
}

