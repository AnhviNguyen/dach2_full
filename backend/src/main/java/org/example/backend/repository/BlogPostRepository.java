package org.example.backend.repository;

import org.example.backend.entity.BlogPost;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface BlogPostRepository extends JpaRepository<BlogPost, Long> {
    Page<BlogPost> findAll(Pageable pageable);
    List<BlogPost> findByAuthorId(Long authorId);
    Page<BlogPost> findByAuthorId(Long authorId, Pageable pageable);
}

