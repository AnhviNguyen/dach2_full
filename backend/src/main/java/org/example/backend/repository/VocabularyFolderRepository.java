package org.example.backend.repository;

import org.example.backend.entity.VocabularyFolder;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface VocabularyFolderRepository extends JpaRepository<VocabularyFolder, Long> {
    List<VocabularyFolder> findByUserId(Long userId);
    
    @Query("SELECT vf FROM VocabularyFolder vf WHERE vf.user.id = :userId ORDER BY vf.createdAt DESC")
    List<VocabularyFolder> findByUserIdOrderByCreatedAtDesc(@Param("userId") Long userId);
    
    Optional<VocabularyFolder> findByIdAndUserId(Long id, Long userId);
}

