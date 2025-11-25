package org.example.backend.dto;

public record AuthRequest(
    String email,
    String password
) {}

