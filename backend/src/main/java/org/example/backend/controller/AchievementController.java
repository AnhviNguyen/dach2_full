package org.example.backend.controller;

import org.example.backend.dto.AchievementItemResponse;
import org.example.backend.dto.AchievementListResponse;
import org.example.backend.dto.PageResponse;
import org.example.backend.service.AchievementService;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/achievements")
@CrossOrigin(origins = "*")
public class AchievementController {
    private final AchievementService achievementService;

    public AchievementController(AchievementService achievementService) {
        this.achievementService = achievementService;
    }

    @GetMapping
    public ResponseEntity<PageResponse<AchievementItemResponse>> getAllAchievements(
            @RequestParam(value = "page", defaultValue = "0") int page,
            @RequestParam(value = "size", defaultValue = "10") int size,
            @RequestParam(value = "sortBy", defaultValue = "id") String sortBy,
            @RequestParam(value = "direction", defaultValue = "ASC") Sort.Direction direction) {
        Pageable pageable = PageRequest.of(page, size, Sort.by(direction, sortBy));
        PageResponse<AchievementItemResponse> response = achievementService.getAllAchievements(pageable);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/user/{userId}")
    public ResponseEntity<AchievementListResponse> getUserAchievements(@PathVariable(value = "userId") Long userId) {
        List<AchievementItemResponse> achievements = achievementService.getUserAchievements(userId);
        
        if (achievements.isEmpty()) {
            AchievementListResponse response = AchievementListResponse.empty(
                "Bạn chưa đạt được thành tựu nào. Hãy tiếp tục học tập để nhận được thành tựu đầu tiên!"
            );
            return ResponseEntity.ok(response);
        }
        
        AchievementListResponse response = AchievementListResponse.withData(achievements);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/user/{userId}/achievement/{achievementId}")
    public ResponseEntity<AchievementItemResponse> getUserAchievement(
            @PathVariable(value = "userId") Long userId,
            @PathVariable(value = "achievementId") Long achievementId) {
        AchievementItemResponse response = achievementService.getUserAchievement(userId, achievementId);
        return ResponseEntity.ok(response);
    }
}

