package org.example.backend.repository;

import org.example.backend.entity.CurriculumLesson;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface CurriculumLessonRepository extends JpaRepository<CurriculumLesson, Long> {
    Page<CurriculumLesson> findAll(Pageable pageable);
    List<CurriculumLesson> findByCurriculumId(Long curriculumId);
    Optional<CurriculumLesson> findById(Long id);
    
    @Query("SELECT l FROM CurriculumLesson l WHERE l.curriculum.id = :curriculumId")
    Page<CurriculumLesson> findByCurriculumIdWithPagination(@Param("curriculumId") Long curriculumId, Pageable pageable);
}

