package org.example.backend.dto;

import com.fasterxml.jackson.annotation.JsonProperty;

public record TextbookResponse(
    Long id,
    @JsonProperty("bookNumber") Integer bookNumber,
    String title,
    String subtitle,
    @JsonProperty("totalLessons") Integer totalLessons,
    @JsonProperty("completedLessons") Integer completedLessons,
    @JsonProperty("isCompleted") Boolean isCompleted,
    @JsonProperty("isLocked") Boolean isLocked,
    String color
) {}

