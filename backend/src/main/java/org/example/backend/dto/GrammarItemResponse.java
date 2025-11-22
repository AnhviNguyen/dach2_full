package org.example.backend.dto;

import java.util.List;

public record GrammarItemResponse(
    String title,
    String explanation,
    List<String> examples
) {}

