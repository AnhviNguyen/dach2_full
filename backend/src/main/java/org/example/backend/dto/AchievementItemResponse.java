package org.example.backend.dto;

import com.fasterxml.jackson.annotation.JsonProperty;

public record AchievementItemResponse(
    @JsonProperty("iconLabel") String iconLabel,
    String title,
    String subtitle,
    Integer count,
    String color,
    @JsonProperty("isCompleted") Boolean isCompleted,
    Double progress
) {}

