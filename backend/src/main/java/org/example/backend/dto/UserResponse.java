package org.example.backend.dto;

import com.fasterxml.jackson.annotation.JsonProperty;

public record UserResponse(
        Long id,
        String name,
        String email,
        String username,
        String avatar,
        String level,
        Integer points,
        @JsonProperty("streakDays") Integer streakDays) {
}
