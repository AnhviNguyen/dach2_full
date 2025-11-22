package org.example.backend.dto;

import com.fasterxml.jackson.annotation.JsonProperty;

public record DashboardStatsResponse(
    @JsonProperty("totalCourses") Integer totalCourses,
    @JsonProperty("completedCourses") Integer completedCourses,
    @JsonProperty("totalVideos") Integer totalVideos,
    @JsonProperty("watchedVideos") Integer watchedVideos,
    @JsonProperty("totalExams") Integer totalExams,
    @JsonProperty("completedExams") Integer completedExams,
    @JsonProperty("totalWatchTime") String totalWatchTime,
    @JsonProperty("completedWatchTime") String completedWatchTime,
    @JsonProperty("lastAccess") String lastAccess,
    @JsonProperty("endDate") String endDate
) {}

