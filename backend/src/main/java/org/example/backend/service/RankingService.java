package org.example.backend.service;

import org.example.backend.dto.PageResponse;
import org.example.backend.dto.RankingEntryResponse;
import org.springframework.data.domain.Pageable;

import java.util.List;

public interface RankingService {
    PageResponse<RankingEntryResponse> getAllRankings(Pageable pageable);
    List<RankingEntryResponse> getAllRankings();
    RankingEntryResponse getRankingByUserId(Long userId);
}

