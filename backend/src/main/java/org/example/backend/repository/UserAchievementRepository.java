package org.example.backend.repository;

import org.example.backend.entity.UserAchievement;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface UserAchievementRepository extends JpaRepository<UserAchievement, Long> {
    Optional<UserAchievement> findByUserIdAndAchievementId(Long userId, Long achievementId);
    List<UserAchievement> findByUserId(Long userId);
}

