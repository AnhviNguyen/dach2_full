package org.example.backend.service.impl;

import org.example.backend.dto.BlogAuthorResponse;
import org.example.backend.dto.BlogCommentRequest;
import org.example.backend.dto.BlogCommentResponse;
import org.example.backend.dto.BlogPostRequest;
import org.example.backend.dto.BlogPostResponse;
import org.example.backend.dto.PageResponse;
import org.example.backend.entity.BlogComment;
import org.example.backend.entity.BlogLike;
import org.example.backend.entity.BlogPost;
import org.example.backend.entity.BlogTag;
import org.example.backend.entity.User;
import org.example.backend.repository.BlogCommentLikeRepository;
import org.example.backend.repository.BlogCommentRepository;
import org.example.backend.repository.BlogLikeRepository;
import org.example.backend.repository.BlogPostRepository;
import org.example.backend.repository.UserRepository;
import org.example.backend.service.BlogService;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@Transactional
public class BlogServiceImpl implements BlogService {
    private final BlogPostRepository blogPostRepository;
    private final UserRepository userRepository;
    private final BlogLikeRepository blogLikeRepository;
    private final BlogCommentRepository blogCommentRepository;
    private final BlogCommentLikeRepository blogCommentLikeRepository;

    public BlogServiceImpl(BlogPostRepository blogPostRepository,
                          UserRepository userRepository,
                          BlogLikeRepository blogLikeRepository,
                          BlogCommentRepository blogCommentRepository,
                          BlogCommentLikeRepository blogCommentLikeRepository) {
        this.blogPostRepository = blogPostRepository;
        this.userRepository = userRepository;
        this.blogLikeRepository = blogLikeRepository;
        this.blogCommentRepository = blogCommentRepository;
        this.blogCommentLikeRepository = blogCommentLikeRepository;
    }

    @Override
    public PageResponse<BlogPostResponse> getAllPosts(Pageable pageable) {
        Page<BlogPost> posts = blogPostRepository.findAll(pageable);
        List<BlogPostResponse> content = posts.getContent().stream()
                .map(post -> toBlogPostResponse(post, null))
                .collect(Collectors.toList());
        
        return new PageResponse<>(
            content,
            posts.getNumber(),
            posts.getSize(),
            posts.getTotalElements(),
            posts.getTotalPages(),
            posts.hasNext(),
            posts.hasPrevious()
        );
    }

    @Override
    public BlogPostResponse getPostById(Long id, Long currentUserId) {
        BlogPost post = blogPostRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Blog post not found with id: " + id));
        return toBlogPostResponse(post, currentUserId);
    }

    @Override
    public BlogPostResponse createPost(BlogPostRequest request) {
        User author = userRepository.findById(request.authorId())
                .orElseThrow(() -> new RuntimeException("User not found"));
        
        BlogPost post = new BlogPost();
        post.setTitle(request.title());
        post.setContent(request.content());
        post.setAuthor(author);
        post.setSkill(request.skill());
        post.setFeaturedImage(request.featuredImage());
        post.setLikes(0);
        post.setComments(0);
        post.setViews(0);
        
        if (request.tags() != null) {
            for (String tagName : request.tags()) {
                BlogTag tag = new BlogTag();
                tag.setPost(post);
                tag.setTag(tagName);
                post.getTags().add(tag);
            }
        }
        
        BlogPost saved = blogPostRepository.save(post);
        return toBlogPostResponse(saved, request.authorId());
    }

    @Override
    public BlogPostResponse updatePost(Long id, BlogPostRequest request) {
        BlogPost post = blogPostRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Blog post not found"));
        
        post.setTitle(request.title());
        post.setContent(request.content());
        post.setSkill(request.skill());
        post.setFeaturedImage(request.featuredImage());
        
        post.getTags().clear();
        if (request.tags() != null) {
            for (String tagName : request.tags()) {
                BlogTag tag = new BlogTag();
                tag.setPost(post);
                tag.setTag(tagName);
                post.getTags().add(tag);
            }
        }
        
        BlogPost updated = blogPostRepository.save(post);
        return toBlogPostResponse(updated, request.authorId());
    }

    @Override
    public void deletePost(Long id) {
        if (!blogPostRepository.existsById(id)) {
            throw new RuntimeException("Blog post not found");
        }
        blogPostRepository.deleteById(id);
    }

    @Override
    public PageResponse<BlogPostResponse> getPostsByAuthor(Long authorId, Pageable pageable) {
        Page<BlogPost> posts = blogPostRepository.findByAuthorId(authorId, pageable);
        List<BlogPostResponse> content = posts.getContent().stream()
                .map(post -> toBlogPostResponse(post, authorId))
                .collect(Collectors.toList());
        
        return new PageResponse<>(
            content,
            posts.getNumber(),
            posts.getSize(),
            posts.getTotalElements(),
            posts.getTotalPages(),
            posts.hasNext(),
            posts.hasPrevious()
        );
    }

    @Override
    public BlogPostResponse toggleLike(Long postId, Long userId) {
        BlogPost post = blogPostRepository.findById(postId)
                .orElseThrow(() -> new RuntimeException("Blog post not found"));
        
        BlogLike existingLike = blogLikeRepository.findByPost_IdAndUser_Id(postId, userId).orElse(null);
        
        if (existingLike != null) {
            blogLikeRepository.delete(existingLike);
            post.setLikes(post.getLikes() - 1);
        } else {
            User user = userRepository.findById(userId)
                    .orElseThrow(() -> new RuntimeException("User not found"));
            BlogLike newLike = new BlogLike();
            newLike.setPost(post);
            newLike.setUser(user);
            blogLikeRepository.save(newLike);
            post.setLikes(post.getLikes() + 1);
        }
        
        BlogPost updated = blogPostRepository.save(post);
        return toBlogPostResponse(updated, userId);
    }

    @Override
    public void incrementView(Long postId) {
        BlogPost post = blogPostRepository.findById(postId)
                .orElseThrow(() -> new RuntimeException("Blog post not found"));
        post.setViews(post.getViews() + 1);
        blogPostRepository.save(post);
    }

    @Override
    public List<BlogCommentResponse> getComments(Long postId, Long currentUserId) {
        List<BlogComment> comments = blogCommentRepository.findByPost_IdOrderByCreatedAtDesc(postId);
        return comments.stream()
                .map(comment -> toBlogCommentResponse(comment, currentUserId))
                .collect(Collectors.toList());
    }

    @Override
    public BlogCommentResponse createComment(Long postId, BlogCommentRequest request) {
        BlogPost post = blogPostRepository.findById(postId)
                .orElseThrow(() -> new RuntimeException("Blog post not found"));
        User user = userRepository.findById(request.userId())
                .orElseThrow(() -> new RuntimeException("User not found"));

        BlogComment comment = new BlogComment();
        comment.setPost(post);
        comment.setUser(user);
        comment.setContent(request.content());
        comment.setLikes(0);

        BlogComment saved = blogCommentRepository.save(comment);
        
        // Update comment count in post
        post.setComments(post.getComments() + 1);
        blogPostRepository.save(post);

        return toBlogCommentResponse(saved, request.userId());
    }

    private BlogCommentResponse toBlogCommentResponse(BlogComment comment, Long currentUserId) {
        BlogAuthorResponse author = new BlogAuthorResponse(
            comment.getUser().getName(),
            comment.getUser().getAvatar(),
            comment.getUser().getLevel()
        );

        boolean isLiked = currentUserId != null &&
                blogCommentLikeRepository.existsByComment_IdAndUser_Id(comment.getId(), currentUserId);

        return new BlogCommentResponse(
            comment.getId(),
            author,
            comment.getContent(),
            comment.getLikes(),
            comment.getCreatedAt(),
            isLiked
        );
    }

    private BlogPostResponse toBlogPostResponse(BlogPost post, Long currentUserId) {
        BlogAuthorResponse author = new BlogAuthorResponse(
            post.getAuthor().getName(),
            post.getAuthor().getAvatar(),
            post.getAuthor().getLevel()
        );
        
        List<String> tags = post.getTags().stream()
                .map(BlogTag::getTag)
                .collect(Collectors.toList());
        
        boolean isLiked = currentUserId != null && 
                blogLikeRepository.existsByPost_IdAndUser_Id(post.getId(), currentUserId);
        boolean isMyPost = currentUserId != null && 
                post.getAuthor().getId().equals(currentUserId);
        
        return new BlogPostResponse(
            post.getId(),
            post.getTitle(),
            post.getContent(),
            author,
            post.getSkill(),
            post.getLikes(),
            post.getComments(),
            post.getViews(),
            post.getCreatedAt(),
            tags,
            isLiked,
            isMyPost,
            post.getFeaturedImage()
        );
    }
}

