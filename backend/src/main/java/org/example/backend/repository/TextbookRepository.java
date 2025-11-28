package org.example.backend.repository;

import org.example.backend.entity.Textbook;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface TextbookRepository extends JpaRepository<Textbook, Long> {
    @Query(value = "SELECT DISTINCT t FROM Textbook t",
           countQuery = "SELECT COUNT(DISTINCT t.id) FROM Textbook t")
    Page<Textbook> findAllDistinct(Pageable pageable);
    
    Page<Textbook> findAll(Pageable pageable);
    
    @Query("SELECT DISTINCT t FROM Textbook t WHERE t.id = :id")
    Optional<Textbook> findByIdWithCollections(@Param("id") Long id);
    
    Optional<Textbook> findByBookNumber(Integer bookNumber);
}

