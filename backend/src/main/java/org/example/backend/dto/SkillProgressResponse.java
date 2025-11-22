package org.example.backend.dto;

public record SkillProgressResponse(
    String label,
    Double percent,
    String color
) {}

