package org.example.backend.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import java.time.LocalDateTime;

public record CompetitionResponse(
    Long id,
    String title,
    String description,
    String categoryId,
    String categoryName,
    LocalDateTime startDate,
    LocalDateTime endDate,
    String status,
    String prize,
    Integer participants,
    String image,
    @JsonProperty("isParticipated") Boolean isParticipated,
    Integer userScore,
    Integer userRank,
    LocalDateTime createdAt
) {}

