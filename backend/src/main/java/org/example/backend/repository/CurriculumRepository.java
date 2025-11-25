package org.example.backend.repository;

import org.example.backend.entity.Curriculum;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface CurriculumRepository extends JpaRepository<Curriculum, Long> {
    Page<Curriculum> findAll(Pageable pageable);
    Optional<Curriculum> findByBookNumber(Integer bookNumber);
}

