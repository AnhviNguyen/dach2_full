package org.example.backend.controller;

import org.example.backend.dto.BlogPostRequest;
import org.example.backend.dto.BlogPostResponse;
import org.example.backend.dto.PageResponse;
import org.example.backend.service.BlogService;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/blog")
@CrossOrigin(origins = "*")
public class BlogController {
    private final BlogService blogService;

    public BlogController(BlogService blogService) {
        this.blogService = blogService;
    }

    @GetMapping("/posts")
    public ResponseEntity<PageResponse<BlogPostResponse>> getAllPosts(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(defaultValue = "createdAt") String sortBy,
            @RequestParam(defaultValue = "DESC") Sort.Direction direction,
            @RequestParam(required = false) Long currentUserId) {
        Pageable pageable = PageRequest.of(page, size, Sort.by(direction, sortBy));
        PageResponse<BlogPostResponse> response = blogService.getAllPosts(pageable);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/posts/{id}")
    public ResponseEntity<BlogPostResponse> getPostById(
            @PathVariable Long id,
            @RequestParam(required = false) Long currentUserId) {
        BlogPostResponse response = blogService.getPostById(id, currentUserId);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/posts")
    public ResponseEntity<BlogPostResponse> createPost(@RequestBody BlogPostRequest request) {
        BlogPostResponse response = blogService.createPost(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @PutMapping("/posts/{id}")
    public ResponseEntity<BlogPostResponse> updatePost(
            @PathVariable Long id,
            @RequestBody BlogPostRequest request) {
        BlogPostResponse response = blogService.updatePost(id, request);
        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/posts/{id}")
    public ResponseEntity<Void> deletePost(@PathVariable Long id) {
        blogService.deletePost(id);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/posts/author/{authorId}")
    public ResponseEntity<PageResponse<BlogPostResponse>> getPostsByAuthor(
            @PathVariable Long authorId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        Pageable pageable = PageRequest.of(page, size);
        PageResponse<BlogPostResponse> response = blogService.getPostsByAuthor(authorId, pageable);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/posts/{postId}/like/{userId}")
    public ResponseEntity<BlogPostResponse> toggleLike(
            @PathVariable Long postId,
            @PathVariable Long userId) {
        BlogPostResponse response = blogService.toggleLike(postId, userId);
        return ResponseEntity.ok(response);
    }
}

