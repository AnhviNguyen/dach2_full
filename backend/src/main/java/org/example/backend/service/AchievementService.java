package org.example.backend.service;

import org.example.backend.dto.AchievementItemResponse;
import org.example.backend.dto.PageResponse;
import org.springframework.data.domain.Pageable;

import java.util.List;

public interface AchievementService {
    PageResponse<AchievementItemResponse> getAllAchievements(Pageable pageable);
    List<AchievementItemResponse> getUserAchievements(Long userId);
    AchievementItemResponse getUserAchievement(Long userId, Long achievementId);
}

