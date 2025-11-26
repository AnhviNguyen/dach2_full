package org.example.backend.service;

import org.example.backend.dto.BlogCommentRequest;
import org.example.backend.dto.BlogCommentResponse;
import org.example.backend.dto.BlogPostRequest;
import org.example.backend.dto.BlogPostResponse;
import org.example.backend.dto.PageResponse;
import org.springframework.data.domain.Pageable;

import java.util.List;

public interface BlogService {
    PageResponse<BlogPostResponse> getAllPosts(Pageable pageable);
    BlogPostResponse getPostById(Long id, Long currentUserId);
    BlogPostResponse createPost(BlogPostRequest request);
    BlogPostResponse updatePost(Long id, BlogPostRequest request);
    void deletePost(Long id);
    PageResponse<BlogPostResponse> getPostsByAuthor(Long authorId, Pageable pageable);
    BlogPostResponse toggleLike(Long postId, Long userId);
    void incrementView(Long postId);
    List<BlogCommentResponse> getComments(Long postId, Long currentUserId);
    BlogCommentResponse createComment(Long postId, BlogCommentRequest request);
}

