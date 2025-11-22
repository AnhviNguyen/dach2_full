package org.example.backend.dto;

import java.util.List;

public record BlogPostRequest(
    String title,
    String content,
    Long authorId,
    String skill,
    List<String> tags,
    String featuredImage
) {}

