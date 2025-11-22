package org.example.backend.dto;

import com.fasterxml.jackson.annotation.JsonProperty;

public record CourseInfoResponse(
    Long id,
    String title,
    String instructor,
    String level,
    Double rating,
    Integer students,
    Integer lessons,
    String duration,
    String price,
    String image,
    @JsonProperty("progress") Double progress,
    @JsonProperty("isEnrolled") Boolean isEnrolled,
    @JsonProperty("accentColor") String accentColor
) {}

