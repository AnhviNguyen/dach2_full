package org.example.backend.repository;

import org.example.backend.entity.Textbook;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface TextbookRepository extends JpaRepository<Textbook, Long> {
    Page<Textbook> findAll(Pageable pageable);
    Optional<Textbook> findByBookNumber(Integer bookNumber);
}

