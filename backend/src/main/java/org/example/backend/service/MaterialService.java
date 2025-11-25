package org.example.backend.service;

import org.example.backend.dto.MaterialResponse;
import org.example.backend.dto.PageResponse;
import org.springframework.data.domain.Pageable;

import java.util.List;

public interface MaterialService {
    PageResponse<MaterialResponse> getAllMaterials(Pageable pageable, Long currentUserId);
    PageResponse<MaterialResponse> getMaterialsByFilters(
            String level, String skill, String type, String searchQuery,
            Pageable pageable, Long currentUserId
    );
    MaterialResponse getMaterialById(Long id, Long currentUserId);
    List<MaterialResponse> getFeaturedMaterials(Long currentUserId);
    Long getDownloadedMaterialsCount(Long userId);
    MaterialResponse downloadMaterial(Long materialId, Long userId);
    Long getTotalMaterialsCount();
}

