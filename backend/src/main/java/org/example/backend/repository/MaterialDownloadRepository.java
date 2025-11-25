package org.example.backend.repository;

import org.example.backend.entity.MaterialDownload;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface MaterialDownloadRepository extends JpaRepository<MaterialDownload, Long> {
    Optional<MaterialDownload> findByUserIdAndMaterialId(Long userId, Long materialId);

    @Query("SELECT md.material.id FROM MaterialDownload md WHERE md.user.id = :userId")
    List<Long> findDownloadedMaterialIdsByUserId(@Param("userId") Long userId);

    @Query("SELECT COUNT(md) FROM MaterialDownload md WHERE md.user.id = :userId")
    Long countByUserId(@Param("userId") Long userId);
}

