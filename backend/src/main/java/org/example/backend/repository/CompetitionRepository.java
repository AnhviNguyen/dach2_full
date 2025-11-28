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
    @Query(value = "SELECT DISTINCT c FROM Competition c ORDER BY c.id ASC",
           countQuery = "SELECT COUNT(DISTINCT c.id) FROM Competition c")
    Page<Competition> findAllDistinct(Pageable pageable);
    
    @Query(value = "SELECT DISTINCT c FROM Competition c ORDER BY c.id ASC",
           countQuery = "SELECT COUNT(DISTINCT c.id) FROM Competition c")
    Page<Competition> findAll(Pageable pageable);
    
    @Query("SELECT DISTINCT c FROM Competition c WHERE c.id = :id")
    Optional<Competition> findByIdWithCollections(@Param("id") Long id);
    
    Optional<Competition> findById(Long id);
    
    @Query(value = "SELECT DISTINCT c FROM Competition c WHERE c.status = :status ORDER BY c.id ASC",
           countQuery = "SELECT COUNT(DISTINCT c.id) FROM Competition c WHERE c.status = :status")
    Page<Competition> findByStatusDistinct(@Param("status") String status, Pageable pageable);
    
    @Query(value = "SELECT DISTINCT c FROM Competition c WHERE c.status = :status ORDER BY c.id ASC",
           countQuery = "SELECT COUNT(DISTINCT c.id) FROM Competition c WHERE c.status = :status")
    Page<Competition> findByStatus(@Param("status") String status, Pageable pageable);
    
    @Query(value = "SELECT DISTINCT c FROM Competition c WHERE c.categoryId = :categoryId ORDER BY c.id ASC",
           countQuery = "SELECT COUNT(DISTINCT c.id) FROM Competition c WHERE c.categoryId = :categoryId")
    Page<Competition> findByCategoryIdDistinct(@Param("categoryId") String categoryId, Pageable pageable);
    
    @Query(value = "SELECT DISTINCT c FROM Competition c WHERE c.categoryId = :categoryId ORDER BY c.id ASC",
           countQuery = "SELECT COUNT(DISTINCT c.id) FROM Competition c WHERE c.categoryId = :categoryId")
    Page<Competition> findByCategoryId(@Param("categoryId") String categoryId, Pageable pageable);
    
    List<Competition> findByStatus(String status);
}

