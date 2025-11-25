package org.example.backend.repository;

import org.example.backend.entity.Competition;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface CompetitionRepository extends JpaRepository<Competition, Long> {
    Page<Competition> findAll(Pageable pageable);
    
    Optional<Competition> findById(Long id);
    
    @Query("SELECT c FROM Competition c WHERE c.status = :status")
    Page<Competition> findByStatus(@Param("status") String status, Pageable pageable);
    
    @Query("SELECT c FROM Competition c WHERE c.categoryId = :categoryId")
    Page<Competition> findByCategoryId(@Param("categoryId") String categoryId, Pageable pageable);
    
    List<Competition> findByStatus(String status);
}

