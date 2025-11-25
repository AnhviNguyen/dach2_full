package org.example.backend.service;

import org.example.backend.dto.*;
import org.springframework.data.domain.Pageable;

import java.util.List;

public interface CompetitionService {
    PageResponse<CompetitionResponse> getAllCompetitions(Pageable pageable, Long currentUserId);
    PageResponse<CompetitionResponse> getCompetitionsByStatus(String status, Pageable pageable, Long currentUserId);
    CompetitionResponse getCompetitionById(Long id, Long currentUserId);
    List<CompetitionQuestionResponse> getCompetitionQuestions(Long competitionId);
    CompetitionResultResponse submitCompetition(CompetitionSubmissionRequest request, Long userId);
    CompetitionResponse joinCompetition(Long competitionId, Long userId);
    CompetitionResultResponse getCompetitionResult(Long competitionId, Long userId);
}

