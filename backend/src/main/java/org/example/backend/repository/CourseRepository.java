package org.example.backend.repository;

import org.example.backend.entity.Course;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface CourseRepository extends JpaRepository<Course, Long> {
    Page<Course> findAll(Pageable pageable);
    List<Course> findByLevel(String level);
    Page<Course> findByLevel(String level, Pageable pageable);
    Optional<Course> findByTitle(String title);
}

