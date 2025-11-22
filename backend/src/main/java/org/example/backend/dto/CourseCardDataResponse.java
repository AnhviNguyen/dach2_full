package org.example.backend.dto;

import com.fasterxml.jackson.annotation.JsonProperty;

public record CourseCardDataResponse(
    String title,
    Double progress,
    Integer lessons,
    Integer completed,
    @JsonProperty("accentColor") String accentColor
) {}

