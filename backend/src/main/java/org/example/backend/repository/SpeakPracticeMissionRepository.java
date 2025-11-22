package org.example.backend.repository;

import org.example.backend.entity.SpeakPracticeMission;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface SpeakPracticeMissionRepository extends JpaRepository<SpeakPracticeMission, Long> {
    List<SpeakPracticeMission> findByUserId(Long userId);
}

