package org.example.backend.repository;

import org.example.backend.entity.BlogPost;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface BlogPostRepository extends JpaRepository<BlogPost, Long> {
    @Query(value = "SELECT DISTINCT p FROM BlogPost p LEFT JOIN FETCH p.author ORDER BY p.createdAt DESC",
           countQuery = "SELECT COUNT(DISTINCT p.id) FROM BlogPost p")
    Page<BlogPost> findAllDistinct(Pageable pageable);
    
    @Query(value = "SELECT DISTINCT p FROM BlogPost p ORDER BY p.createdAt DESC",
           countQuery = "SELECT COUNT(DISTINCT p.id) FROM BlogPost p")
    Page<BlogPost> findAll(Pageable pageable);
    
    @Query("SELECT DISTINCT p FROM BlogPost p LEFT JOIN FETCH p.author WHERE p.id = :id")
    Optional<BlogPost> findByIdWithAuthor(@Param("id") Long id);
    
    List<BlogPost> findByAuthorId(Long authorId);
    
    @Query(value = "SELECT DISTINCT p FROM BlogPost p LEFT JOIN FETCH p.author WHERE p.author.id = :authorId ORDER BY p.createdAt DESC",
           countQuery = "SELECT COUNT(DISTINCT p.id) FROM BlogPost p WHERE p.author.id = :authorId")
    Page<BlogPost> findByAuthorIdDistinct(@Param("authorId") Long authorId, Pageable pageable);
    
    @Query(value = "SELECT DISTINCT p FROM BlogPost p WHERE p.author.id = :authorId ORDER BY p.createdAt DESC",
           countQuery = "SELECT COUNT(DISTINCT p.id) FROM BlogPost p WHERE p.author.id = :authorId")
    Page<BlogPost> findByAuthorId(@Param("authorId") Long authorId, Pageable pageable);
}

