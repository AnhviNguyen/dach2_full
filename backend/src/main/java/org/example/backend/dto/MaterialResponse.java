package org.example.backend.dto;

import com.fasterxml.jackson.annotation.JsonProperty;

public record MaterialResponse(
    Long id,
    String title,
    String description,
    String level,
    String skill,
    String type,
    String thumbnail,
    Integer downloads,
    Double rating,
    String size,
    Integer points,
    @JsonProperty("isFeatured") Boolean isFeatured,
    String duration,
    @JsonProperty("pdfUrl") String pdfUrl,
    @JsonProperty("videoUrl") String videoUrl,
    @JsonProperty("audioUrl") String audioUrl,
    @JsonProperty("isDownloaded") Boolean isDownloaded
) {}

