package org.example.backend.repository;

import org.example.backend.entity.TextbookProgress;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface TextbookProgressRepository extends JpaRepository<TextbookProgress, Long> {
    Optional<TextbookProgress> findByUserIdAndTextbookId(Long userId, Long textbookId);
    List<TextbookProgress> findByUserId(Long userId);
}

