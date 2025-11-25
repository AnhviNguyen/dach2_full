package org.example.backend.dto;

import java.time.LocalDateTime;
import java.util.List;

public record VocabularyFolderResponse(
    Long id,
    String name,
    String icon,
    Integer wordCount,
    List<VocabularyWordResponse> words,
    LocalDateTime createdAt,
    LocalDateTime updatedAt
) {}

