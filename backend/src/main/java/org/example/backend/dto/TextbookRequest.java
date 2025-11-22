package org.example.backend.dto;

public record TextbookRequest(
    Integer bookNumber,
    String title,
    String subtitle,
    Integer totalLessons,
    String color
) {}

