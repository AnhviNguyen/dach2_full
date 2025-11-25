package org.example.backend.dto;

public record VocabularyWordRequest(
    String korean,
    String vietnamese,
    String pronunciation,
    String example
) {}

