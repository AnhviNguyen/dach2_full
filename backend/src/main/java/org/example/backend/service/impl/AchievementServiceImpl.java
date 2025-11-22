package org.example.backend.service.impl;

import org.example.backend.dto.AchievementItemResponse;
import org.example.backend.dto.PageResponse;
import org.example.backend.entity.Achievement;
import org.example.backend.entity.UserAchievement;
import org.example.backend.repository.AchievementRepository;
import org.example.backend.repository.UserAchievementRepository;
import org.example.backend.service.AchievementService;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@Transactional
public class AchievementServiceImpl implements AchievementService {
    private final AchievementRepository achievementRepository;
    private final UserAchievementRepository userAchievementRepository;

    public AchievementServiceImpl(AchievementRepository achievementRepository,
                                 UserAchievementRepository userAchievementRepository) {
        this.achievementRepository = achievementRepository;
        this.userAchievementRepository = userAchievementRepository;
    }

    @Override
    public PageResponse<AchievementItemResponse> getAllAchievements(Pageable pageable) {
        Page<Achievement> achievements = achievementRepository.findAll(pageable);
        List<AchievementItemResponse> content = achievements.getContent().stream()
                .map(this::toAchievementItemResponse)
                .collect(Collectors.toList());
        
        return new PageResponse<>(
            content,
            achievements.getNumber(),
            achievements.getSize(),
            achievements.getTotalElements(),
            achievements.getTotalPages(),
            achievements.hasNext(),
            achievements.hasPrevious()
        );
    }

    @Override
    public List<AchievementItemResponse> getUserAchievements(Long userId) {
        List<UserAchievement> userAchievements = userAchievementRepository.findByUserId(userId);
        return userAchievements.stream()
                .map(this::toAchievementItemResponse)
                .collect(Collectors.toList());
    }

    @Override
    public AchievementItemResponse getUserAchievement(Long userId, Long achievementId) {
        UserAchievement userAchievement = userAchievementRepository
                .findByUserIdAndAchievementId(userId, achievementId)
                .orElseThrow(() -> new RuntimeException("User achievement not found"));
        return toAchievementItemResponse(userAchievement);
    }

    private AchievementItemResponse toAchievementItemResponse(Achievement achievement) {
        return new AchievementItemResponse(
            achievement.getIconLabel(),
            achievement.getTitle(),
            achievement.getSubtitle(),
            0,
            achievement.getColor(),
            false,
            0.0
        );
    }

    private AchievementItemResponse toAchievementItemResponse(UserAchievement userAchievement) {
        Achievement achievement = userAchievement.getAchievement();
        return new AchievementItemResponse(
            achievement.getIconLabel(),
            achievement.getTitle(),
            achievement.getSubtitle(),
            userAchievement.getCurrentCount(),
            achievement.getColor(),
            userAchievement.getIsCompleted(),
            userAchievement.getProgress()
        );
    }
}

