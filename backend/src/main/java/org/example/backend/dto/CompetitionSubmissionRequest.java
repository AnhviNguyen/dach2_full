package org.example.backend.dto;

import java.util.Map;

public record CompetitionSubmissionRequest(
    Long competitionId,
    Map<Long, String> answers // questionId -> answer
) {}

