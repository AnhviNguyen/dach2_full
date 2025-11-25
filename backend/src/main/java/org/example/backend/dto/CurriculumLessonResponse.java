package org.example.backend.dto;

import java.util.List;

public record CurriculumLessonResponse(
    Long id,
    String title,
    String level,
    String duration,
    Integer progress,
    Integer lessonNumber,
    String videoUrl,
    List<VocabularyItemResponse> vocabulary,
    List<GrammarItemResponse> grammar,
    List<ExerciseItemResponse> exercises
) {}

