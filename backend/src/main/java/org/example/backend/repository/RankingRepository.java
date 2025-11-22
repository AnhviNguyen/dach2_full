package org.example.backend.repository;

import org.example.backend.entity.Ranking;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface RankingRepository extends JpaRepository<Ranking, Long> {
    Page<Ranking> findAll(Pageable pageable);
    
    @Query("SELECT r FROM Ranking r ORDER BY r.points DESC, r.days DESC")
    List<Ranking> findAllOrderByPointsDesc();
    
    @Query("SELECT r FROM Ranking r ORDER BY r.points DESC, r.days DESC")
    Page<Ranking> findAllOrderByPointsDesc(Pageable pageable);
    
    Optional<Ranking> findByUserId(Long userId);
}

