package org.example.backend.repository;

import org.example.backend.entity.Curriculum;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface CurriculumRepository extends JpaRepository<Curriculum, Long> {
    @Query(value = "SELECT DISTINCT c FROM Curriculum c",
           countQuery = "SELECT COUNT(DISTINCT c.id) FROM Curriculum c")
    Page<Curriculum> findAllDistinct(Pageable pageable);
    
    Page<Curriculum> findAll(Pageable pageable);
    
    @Query("SELECT DISTINCT c FROM Curriculum c WHERE c.id = :id")
    Optional<Curriculum> findByIdWithCollections(@Param("id") Long id);
    
    Optional<Curriculum> findByBookNumber(Integer bookNumber);
}

