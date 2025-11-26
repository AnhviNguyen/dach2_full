package org.example.backend.dto;

public record BlogCommentRequest(
    Long userId,
    String content
) {}

