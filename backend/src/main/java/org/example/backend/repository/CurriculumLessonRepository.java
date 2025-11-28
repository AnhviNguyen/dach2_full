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
    @Query(value = "SELECT DISTINCT l FROM CurriculumLesson l LEFT JOIN FETCH l.curriculum",
           countQuery = "SELECT COUNT(DISTINCT l.id) FROM CurriculumLesson l")
    Page<CurriculumLesson> findAllDistinct(Pageable pageable);
    
    Page<CurriculumLesson> findAll(Pageable pageable);
    
    @Query("SELECT DISTINCT l FROM CurriculumLesson l LEFT JOIN FETCH l.curriculum WHERE l.id = :id")
    Optional<CurriculumLesson> findByIdWithCollections(@Param("id") Long id);
    
    List<CurriculumLesson> findByCurriculumId(Long curriculumId);
    
    Optional<CurriculumLesson> findById(Long id);
    
    @Query(value = "SELECT DISTINCT l FROM CurriculumLesson l LEFT JOIN FETCH l.curriculum WHERE l.curriculum.id = :curriculumId",
           countQuery = "SELECT COUNT(DISTINCT l.id) FROM CurriculumLesson l WHERE l.curriculum.id = :curriculumId")
    Page<CurriculumLesson> findByCurriculumIdDistinct(@Param("curriculumId") Long curriculumId, Pageable pageable);
    
    @Query("SELECT l FROM CurriculumLesson l WHERE l.curriculum.id = :curriculumId")
    Page<CurriculumLesson> findByCurriculumIdWithPagination(@Param("curriculumId") Long curriculumId, Pageable pageable);
}

