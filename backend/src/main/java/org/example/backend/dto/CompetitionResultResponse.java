package org.example.backend.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import java.util.List;

public record CompetitionResultResponse(
    Long competitionId,
    Integer totalQuestions,
    Integer correctAnswers,
    Integer wrongAnswers,
    Integer skippedAnswers,
    Integer score,
    Integer rank,
    Double accuracy,
    List<QuestionResultResponse> questionResults
) {}

