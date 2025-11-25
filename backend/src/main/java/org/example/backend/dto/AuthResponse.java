package org.example.backend.dto;

import com.fasterxml.jackson.annotation.JsonProperty;

public record AuthResponse(
    String accessToken,
    String refreshToken,
    @JsonProperty("expiresIn") Integer expiresIn,
    UserResponse user
) {}

