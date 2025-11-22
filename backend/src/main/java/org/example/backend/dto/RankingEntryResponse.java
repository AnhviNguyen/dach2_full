package org.example.backend.dto;

import com.fasterxml.jackson.annotation.JsonProperty;

public record RankingEntryResponse(
    Integer position,
    String name,
    Integer points,
    Integer days,
    @JsonProperty("isCurrentUser") Boolean isCurrentUser,
    String color
) {}

