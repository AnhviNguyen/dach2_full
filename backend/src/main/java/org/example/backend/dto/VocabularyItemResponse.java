package org.example.backend.dto;

public record VocabularyItemResponse(
    String korean,
    String vietnamese,
    String pronunciation,
    String example
) {}

