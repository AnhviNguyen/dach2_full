package org.example.backend.repository;

import org.example.backend.entity.CompetitionCategory;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface CompetitionCategoryRepository extends JpaRepository<CompetitionCategory, Long> {
    Page<CompetitionCategory> findAll(Pageable pageable);
    Optional<CompetitionCategory> findByCategoryId(String categoryId);
}

