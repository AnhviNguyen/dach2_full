package org.example.backend.service.impl;

import org.example.backend.dto.PageResponse;
import org.example.backend.dto.RankingEntryResponse;
import org.example.backend.entity.Ranking;
import org.example.backend.repository.RankingRepository;
import org.example.backend.service.RankingService;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@Transactional
public class RankingServiceImpl implements RankingService {
    private final RankingRepository rankingRepository;

    public RankingServiceImpl(RankingRepository rankingRepository) {
        this.rankingRepository = rankingRepository;
    }

    @Override
    public PageResponse<RankingEntryResponse> getAllRankings(Pageable pageable) {
        Page<Ranking> rankings = rankingRepository.findAllOrderByPointsDesc(pageable);
        List<RankingEntryResponse> content = new java.util.ArrayList<>();
        int startPosition = pageable.getPageNumber() * pageable.getPageSize() + 1;
        for (int i = 0; i < rankings.getContent().size(); i++) {
            Ranking ranking = rankings.getContent().get(i);
            content.add(toRankingEntryResponse(ranking, startPosition + i, null));
        }
        
        return new PageResponse<>(
            content,
            rankings.getNumber(),
            rankings.getSize(),
            rankings.getTotalElements(),
            rankings.getTotalPages(),
            rankings.hasNext(),
            rankings.hasPrevious()
        );
    }

    @Override
    public List<RankingEntryResponse> getAllRankings() {
        List<Ranking> rankings = rankingRepository.findAllOrderByPointsDesc();
        Long currentUserId = null; // This should come from security context in real app
        
        List<RankingEntryResponse> result = new java.util.ArrayList<>();
        for (int i = 0; i < rankings.size(); i++) {
            Ranking ranking = rankings.get(i);
            result.add(toRankingEntryResponse(ranking, i + 1, currentUserId));
        }
        return result;
    }

    @Override
    public RankingEntryResponse getRankingByUserId(Long userId) {
        Ranking ranking = rankingRepository.findByUserId(userId)
                .orElseThrow(() -> new RuntimeException("Ranking not found for user id: " + userId));
        
        List<Ranking> allRankings = rankingRepository.findAllOrderByPointsDesc();
        int position = allRankings.indexOf(ranking) + 1;
        
        return toRankingEntryResponse(ranking, position, userId);
    }

    private RankingEntryResponse toRankingEntryResponse(Ranking ranking, int position, Long currentUserId) {
        boolean isCurrentUser = currentUserId != null && ranking.getUser().getId().equals(currentUserId);
        return new RankingEntryResponse(
            position,
            ranking.getUser().getName(),
            ranking.getPoints(),
            ranking.getDays(),
            isCurrentUser,
            ranking.getColor()
        );
    }
}

