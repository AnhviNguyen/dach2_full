package org.example.backend.dto;

import java.util.List;

public record CompetitionQuestionResponse(
    Long id,
    String questionText,
    String questionType,
    String correctAnswer,
    Integer points,
    Integer questionOrder,
    List<CompetitionQuestionOptionResponse> options
) {}

