package org.example.backend.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import java.time.LocalDateTime;

public record BlogCommentResponse(
    Long id,
    BlogAuthorResponse author,
    String content,
    Integer likes,
    LocalDateTime date,
    @JsonProperty("isLiked") Boolean isLiked
) {}

