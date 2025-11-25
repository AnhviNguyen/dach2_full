package org.example.backend.repository;

import org.example.backend.entity.VocabularyWord;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface VocabularyWordRepository extends JpaRepository<VocabularyWord, Long> {
    List<VocabularyWord> findByFolderId(Long folderId);
    
    @Query("SELECT vw FROM VocabularyWord vw WHERE vw.folder.id = :folderId ORDER BY vw.createdAt DESC")
    List<VocabularyWord> findByFolderIdOrderByCreatedAtDesc(@Param("folderId") Long folderId);
    
    Optional<VocabularyWord> findByIdAndFolderId(Long id, Long folderId);
    
    @Query("SELECT COUNT(vw) FROM VocabularyWord vw WHERE vw.folder.id = :folderId")
    Long countByFolderId(@Param("folderId") Long folderId);
}

