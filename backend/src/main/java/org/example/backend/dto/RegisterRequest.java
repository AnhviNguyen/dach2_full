package org.example.backend.dto;

public record RegisterRequest(
    String name,
    String email,
    String password,
    String username
) {}

