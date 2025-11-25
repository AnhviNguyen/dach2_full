package org.example.backend.dto;

import com.fasterxml.jackson.annotation.JsonProperty;

public record CompetitionQuestionOptionResponse(
    Long id,
    String optionText,
    Integer optionOrder,
    @JsonProperty("isCorrect") Boolean isCorrect
) {}

