package org.example.backend.dto;

import java.time.LocalDateTime;

public record VocabularyWordResponse(
    Long id,
    String korean,
    String vietnamese,
    String pronunciation,
    String example,
    LocalDateTime createdAt,
    LocalDateTime updatedAt
) {}

