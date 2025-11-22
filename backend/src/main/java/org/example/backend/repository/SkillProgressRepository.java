package org.example.backend.repository;

import org.example.backend.entity.SkillProgress;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface SkillProgressRepository extends JpaRepository<SkillProgress, Long> {
    List<SkillProgress> findByUserId(Long userId);
}

