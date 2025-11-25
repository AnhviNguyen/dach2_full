package org.example.backend.dto;

public record GoogleSignInRequest(
    String idToken,
    String accessToken
) {}

