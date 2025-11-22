package org.example.backend.repository;

import org.example.backend.entity.CourseCard;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface CourseCardRepository extends JpaRepository<CourseCard, Long> {
    Page<CourseCard> findAll(Pageable pageable);
    List<CourseCard> findByUserId(Long userId);
    Page<CourseCard> findByUserId(Long userId, Pageable pageable);
}

