package org.example.backend.repository;

import org.example.backend.entity.Course;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface CourseRepository extends JpaRepository<Course, Long> {
    @Query(value = "SELECT DISTINCT c FROM Course c",
           countQuery = "SELECT COUNT(DISTINCT c.id) FROM Course c")
    Page<Course> findAllDistinct(Pageable pageable);
    
    Page<Course> findAll(Pageable pageable);
    
    @Query("SELECT DISTINCT c FROM Course c WHERE c.id = :id")
    Optional<Course> findByIdWithCollections(@Param("id") Long id);
    
    List<Course> findByLevel(String level);
    
    @Query(value = "SELECT DISTINCT c FROM Course c WHERE c.level = :level",
           countQuery = "SELECT COUNT(DISTINCT c.id) FROM Course c WHERE c.level = :level")
    Page<Course> findByLevelDistinct(@Param("level") String level, Pageable pageable);
    
    Page<Course> findByLevel(String level, Pageable pageable);
    Optional<Course> findByTitle(String title);
}

