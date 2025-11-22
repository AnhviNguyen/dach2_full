package org.example.backend.dto;

import com.fasterxml.jackson.annotation.JsonProperty;

public record TaskItemResponse(
    String title,
    String icon,
    String color,
    @JsonProperty("progressColor") String progressColor,
    @JsonProperty("progressPercent") Double progressPercent
) {}

