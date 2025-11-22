package org.example.backend.dto;

import com.fasterxml.jackson.annotation.JsonProperty;

public record LessonCardDataResponse(
    String title,
    String date,
    String tag,
    @JsonProperty("accentColor") String accentColor,
    @JsonProperty("backgroundColor") String backgroundColor
) {}

