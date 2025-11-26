package org.example.backend.dto;

import com.fasterxml.jackson.annotation.JsonProperty;

public record VocabularyWordRequest(
    String korean,
    String vietnamese,
    String pronunciation,
    String example,
    @JsonProperty("isLearned") Boolean isLearned
) {}

