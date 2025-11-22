package org.example.backend.repository;

import org.example.backend.entity.CourseEnrollment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface CourseEnrollmentRepository extends JpaRepository<CourseEnrollment, Long> {
    Optional<CourseEnrollment> findByUserIdAndCourseId(Long userId, Long courseId);
    List<CourseEnrollment> findByUserId(Long userId);
    List<CourseEnrollment> findByCourseId(Long courseId);
}

