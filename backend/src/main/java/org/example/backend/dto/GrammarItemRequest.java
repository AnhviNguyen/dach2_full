package org.example.backend.dto;

import java.util.List;

public record GrammarItemRequest(
    String title,
    String explanation,
    List<String> examples
) {}

