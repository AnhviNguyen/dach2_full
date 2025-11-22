package org.example.backend.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import java.time.LocalDateTime;
import java.util.List;

public record BlogPostResponse(
    Long id,
    String title,
    String content,
    BlogAuthorResponse author,
    String skill,
    Integer likes,
    Integer comments,
    Integer views,
    LocalDateTime date,
    List<String> tags,
    @JsonProperty("isLiked") Boolean isLiked,
    @JsonProperty("isMyPost") Boolean isMyPost,
    String featuredImage
) {}

