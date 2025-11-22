package org.example.backend.dto;

import java.util.List;

public record LessonResponse(
    Long id,
    String title,
    String level,
    String duration,
    Integer progress,
    List<VocabularyItemResponse> vocabulary,
    List<GrammarItemResponse> grammar,
    List<ExerciseItemResponse> exercises
) {}

