package org.example.backend.repository;

import org.example.backend.entity.BlogComment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface BlogCommentRepository extends JpaRepository<BlogComment, Long> {
    List<BlogComment> findByPost_IdOrderByCreatedAtDesc(Long postId);
}

