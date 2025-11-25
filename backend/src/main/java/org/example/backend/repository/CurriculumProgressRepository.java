package org.example.backend.repository;

import org.example.backend.entity.CurriculumProgress;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface CurriculumProgressRepository extends JpaRepository<CurriculumProgress, Long> {
    Optional<CurriculumProgress> findByUserIdAndCurriculumId(Long userId, Long curriculumId);
}

