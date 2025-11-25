package org.example.backend.dto;

public record CurriculumRequest(
    Integer bookNumber,
    String title,
    String subtitle,
    Integer totalLessons,
    String color
) {}

