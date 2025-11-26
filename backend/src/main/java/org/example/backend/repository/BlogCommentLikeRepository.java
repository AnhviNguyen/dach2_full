package org.example.backend.repository;

import org.example.backend.entity.BlogCommentLike;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface BlogCommentLikeRepository extends JpaRepository<BlogCommentLike, Long> {
    Optional<BlogCommentLike> findByComment_IdAndUser_Id(Long commentId, Long userId);
    boolean existsByComment_IdAndUser_Id(Long commentId, Long userId);
}

