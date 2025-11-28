package org.example.backend.repository;

import org.example.backend.entity.CourseLesson;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface CourseLessonRepository extends JpaRepository<CourseLesson, Long> {
    @Query(value = "SELECT DISTINCT l FROM CourseLesson l LEFT JOIN FETCH l.course",
           countQuery = "SELECT COUNT(DISTINCT l.id) FROM CourseLesson l")
    Page<CourseLesson> findAllDistinct(Pageable pageable);
    
    Page<CourseLesson> findAll(Pageable pageable);
    
    @Query("SELECT DISTINCT l FROM CourseLesson l LEFT JOIN FETCH l.course WHERE l.id = :id")
    Optional<CourseLesson> findByIdWithCollections(@Param("id") Long id);
    
    List<CourseLesson> findByCourseId(Long courseId);
    
    Optional<CourseLesson> findById(Long id);
    
    @Query(value = "SELECT DISTINCT l FROM CourseLesson l LEFT JOIN FETCH l.course WHERE l.course.id = :courseId",
           countQuery = "SELECT COUNT(DISTINCT l.id) FROM CourseLesson l WHERE l.course.id = :courseId")
    Page<CourseLesson> findByCourseIdDistinct(@Param("courseId") Long courseId, Pageable pageable);
    
    @Query("SELECT l FROM CourseLesson l WHERE l.course.id = :courseId")
    Page<CourseLesson> findByCourseIdWithPagination(@Param("courseId") Long courseId, Pageable pageable);
}

