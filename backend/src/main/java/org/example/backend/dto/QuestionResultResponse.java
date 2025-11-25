package org.example.backend.dto;

import com.fasterxml.jackson.annotation.JsonProperty;

public record QuestionResultResponse(
    Long questionId,
    String userAnswer,
    String correctAnswer,
    @JsonProperty("isCorrect") Boolean isCorrect
) {}

