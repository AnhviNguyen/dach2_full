package org.example.backend.dto;

public record VocabularyItemRequest(
    String korean,
    String vietnamese,
    String pronunciation,
    String example
) {}

