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
    Page<CourseLesson> findAll(Pageable pageable);
    List<CourseLesson> findByCourseId(Long courseId);
    Optional<CourseLesson> findById(Long id);
    
    @Query("SELECT l FROM CourseLesson l WHERE l.course.id = :courseId")
    Page<CourseLesson> findByCourseIdWithPagination(@Param("courseId") Long courseId, Pageable pageable);
}

