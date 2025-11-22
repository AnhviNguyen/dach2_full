package org.example.backend.dto;

import java.util.List;

public record ExerciseItemResponse(
    Long id,
    String type,
    String question,
    List<String> options,
    Integer correct,
    String answer
) {}

