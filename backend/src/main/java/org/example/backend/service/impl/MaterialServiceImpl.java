package org.example.backend.service.impl;

import org.example.backend.dto.MaterialResponse;
import org.example.backend.dto.PageResponse;
import org.example.backend.entity.Material;
import org.example.backend.entity.MaterialDownload;
import org.example.backend.entity.User;
import org.example.backend.repository.MaterialDownloadRepository;
import org.example.backend.repository.MaterialRepository;
import org.example.backend.repository.UserRepository;
import org.example.backend.service.MaterialService;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class MaterialServiceImpl implements MaterialService {
    private final MaterialRepository materialRepository;
    private final MaterialDownloadRepository materialDownloadRepository;
    private final UserRepository userRepository;

    public MaterialServiceImpl(
            MaterialRepository materialRepository,
            MaterialDownloadRepository materialDownloadRepository,
            UserRepository userRepository
    ) {
        this.materialRepository = materialRepository;
        this.materialDownloadRepository = materialDownloadRepository;
        this.userRepository = userRepository;
    }

    @Override
    public PageResponse<MaterialResponse> getAllMaterials(Pageable pageable, Long currentUserId) {
        Page<Material> materials = materialRepository.findAll(pageable);
        List<Long> downloadedIds = currentUserId != null
                ? materialDownloadRepository.findDownloadedMaterialIdsByUserId(currentUserId)
                : List.of();

        List<MaterialResponse> content = materials.getContent().stream()
                .map(m -> toResponse(m, downloadedIds.contains(m.getId())))
                .collect(Collectors.toList());

        return new PageResponse<>(
                content,
                materials.getNumber(),
                materials.getSize(),
                materials.getTotalElements(),
                materials.getTotalPages(),
                materials.hasNext(),
                materials.hasPrevious()
        );
    }

    @Override
    public PageResponse<MaterialResponse> getMaterialsByFilters(
            String level, String skill, String type, String searchQuery,
            Pageable pageable, Long currentUserId
    ) {
        String levelFilter = (level != null && !level.equals("all")) ? level : null;
        String skillFilter = (skill != null && !skill.equals("all")) ? skill : null;
        String typeFilter = (type != null && !type.equals("all")) ? type : null;
        String searchFilter = (searchQuery != null && !searchQuery.isEmpty()) ? searchQuery : null;

        Page<Material> materials = materialRepository.findByFilters(
                levelFilter, skillFilter, typeFilter, searchFilter, pageable
        );

        List<Long> downloadedIds = currentUserId != null
                ? materialDownloadRepository.findDownloadedMaterialIdsByUserId(currentUserId)
                : List.of();

        List<MaterialResponse> content = materials.getContent().stream()
                .map(m -> toResponse(m, downloadedIds.contains(m.getId())))
                .collect(Collectors.toList());

        return new PageResponse<>(
                content,
                materials.getNumber(),
                materials.getSize(),
                materials.getTotalElements(),
                materials.getTotalPages(),
                materials.hasNext(),
                materials.hasPrevious()
        );
    }

    @Override
    public MaterialResponse getMaterialById(Long id, Long currentUserId) {
        Material material = materialRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Material not found"));

        boolean isDownloaded = currentUserId != null &&
                materialDownloadRepository.findByUserIdAndMaterialId(currentUserId, id).isPresent();

        return toResponse(material, isDownloaded);
    }

    @Override
    public List<MaterialResponse> getFeaturedMaterials(Long currentUserId) {
        List<Material> materials = materialRepository.findByIsFeaturedTrue();
        List<Long> downloadedIds = currentUserId != null
                ? materialDownloadRepository.findDownloadedMaterialIdsByUserId(currentUserId)
                : List.of();

        return materials.stream()
                .map(m -> toResponse(m, downloadedIds.contains(m.getId())))
                .collect(Collectors.toList());
    }

    @Override
    public Long getDownloadedMaterialsCount(Long userId) {
        return materialDownloadRepository.countByUserId(userId);
    }

    @Override
    @Transactional
    public MaterialResponse downloadMaterial(Long materialId, Long userId) {
        Material material = materialRepository.findById(materialId)
                .orElseThrow(() -> new RuntimeException("Material not found"));

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        // Check if already downloaded
        if (materialDownloadRepository.findByUserIdAndMaterialId(userId, materialId).isEmpty()) {
            // Check user points
            if (user.getPoints() < material.getPoints()) {
                throw new RuntimeException("Insufficient points");
            }

            // Deduct points
            user.setPoints(user.getPoints() - material.getPoints());
            userRepository.save(user);

            // Create download record
            MaterialDownload download = new MaterialDownload();
            download.setUser(user);
            download.setMaterial(material);
            materialDownloadRepository.save(download);

            // Increment download count
            material.setDownloads(material.getDownloads() + 1);
            materialRepository.save(material);
        }

        return toResponse(material, true);
    }

    @Override
    public Long getTotalMaterialsCount() {
        return materialRepository.countAll();
    }

    private MaterialResponse toResponse(Material material, boolean isDownloaded) {
        return new MaterialResponse(
                material.getId(),
                material.getTitle(),
                material.getDescription(),
                material.getLevel(),
                material.getSkill(),
                material.getType(),
                material.getThumbnail(),
                material.getDownloads(),
                material.getRating(),
                material.getSize(),
                material.getPoints(),
                material.getIsFeatured(),
                material.getDuration(),
                material.getPdfUrl(),
                material.getVideoUrl(),
                material.getAudioUrl(),
                isDownloaded
        );
    }
}

