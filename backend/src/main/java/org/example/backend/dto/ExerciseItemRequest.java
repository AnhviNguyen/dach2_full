package org.example.backend.dto;

import java.util.List;

public record ExerciseItemRequest(
    String type,
    String question,
    List<String> options,
    Integer correct,
    String answer
) {}

