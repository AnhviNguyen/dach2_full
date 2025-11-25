package org.example.backend.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import java.util.List;

public record AchievementListResponse(
    List<AchievementItemResponse> achievements,
    String message,
    @JsonProperty("isEmpty") Boolean isEmpty
) {
    public static AchievementListResponse empty(String message) {
        return new AchievementListResponse(List.of(), message, true);
    }
    
    public static AchievementListResponse withData(List<AchievementItemResponse> achievements) {
        return new AchievementListResponse(achievements, null, false);
    }
}

