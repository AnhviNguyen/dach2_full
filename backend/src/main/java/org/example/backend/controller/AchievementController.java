package org.example.backend.controller;

import org.example.backend.dto.AchievementItemResponse;
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
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(defaultValue = "id") String sortBy,
            @RequestParam(defaultValue = "ASC") Sort.Direction direction) {
        Pageable pageable = PageRequest.of(page, size, Sort.by(direction, sortBy));
        PageResponse<AchievementItemResponse> response = achievementService.getAllAchievements(pageable);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/user/{userId}")
    public ResponseEntity<List<AchievementItemResponse>> getUserAchievements(@PathVariable Long userId) {
        List<AchievementItemResponse> response = achievementService.getUserAchievements(userId);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/user/{userId}/achievement/{achievementId}")
    public ResponseEntity<AchievementItemResponse> getUserAchievement(
            @PathVariable Long userId,
            @PathVariable Long achievementId) {
        AchievementItemResponse response = achievementService.getUserAchievement(userId, achievementId);
        return ResponseEntity.ok(response);
    }
}

