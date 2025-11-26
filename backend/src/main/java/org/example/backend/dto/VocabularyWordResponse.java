package org.example.backend.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import java.time.LocalDateTime;

public record VocabularyWordResponse(
    Long id,
    String korean,
    String vietnamese,
    String pronunciation,
    String example,
    @JsonProperty("isLearned") Boolean isLearned,
    LocalDateTime createdAt,
    LocalDateTime updatedAt
) {}

