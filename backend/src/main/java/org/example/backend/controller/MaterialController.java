package org.example.backend.controller;

import org.example.backend.dto.MaterialResponse;
import org.example.backend.dto.PageResponse;
import org.example.backend.service.MaterialService;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/materials")
@CrossOrigin(origins = "*")
public class MaterialController {
    private final MaterialService materialService;

    public MaterialController(MaterialService materialService) {
        this.materialService = materialService;
    }

    @GetMapping
    public ResponseEntity<PageResponse<MaterialResponse>> getAllMaterials(
            @RequestParam(value = "page", defaultValue = "0") int page,
            @RequestParam(value = "size", defaultValue = "10") int size,
            @RequestParam(value = "sortBy", defaultValue = "id") String sortBy,
            @RequestParam(value = "direction", defaultValue = "ASC") Sort.Direction direction,
            @RequestParam(value = "currentUserId", required = false) Long currentUserId) {
        Pageable pageable = PageRequest.of(page, size, Sort.by(direction, sortBy));
        PageResponse<MaterialResponse> response = materialService.getAllMaterials(pageable, currentUserId);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/filter")
    public ResponseEntity<PageResponse<MaterialResponse>> getMaterialsByFilters(
            @RequestParam(value = "level", required = false) String level,
            @RequestParam(value = "skill", required = false) String skill,
            @RequestParam(value = "type", required = false) String type,
            @RequestParam(value = "searchQuery", required = false) String searchQuery,
            @RequestParam(value = "page", defaultValue = "0") int page,
            @RequestParam(value = "size", defaultValue = "10") int size,
            @RequestParam(value = "currentUserId", required = false) Long currentUserId) {
        Pageable pageable = PageRequest.of(page, size);
        PageResponse<MaterialResponse> response = materialService.getMaterialsByFilters(
                level, skill, type, searchQuery, pageable, currentUserId
        );
        return ResponseEntity.ok(response);
    }

    @GetMapping("/{id}")
    public ResponseEntity<MaterialResponse> getMaterialById(
            @PathVariable(value = "id") Long id,
            @RequestParam(value = "currentUserId", required = false) Long currentUserId) {
        MaterialResponse response = materialService.getMaterialById(id, currentUserId);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/featured")
    public ResponseEntity<List<MaterialResponse>> getFeaturedMaterials(
            @RequestParam(value = "currentUserId", required = false) Long currentUserId) {
        List<MaterialResponse> response = materialService.getFeaturedMaterials(currentUserId);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/downloads/count")
    public ResponseEntity<Long> getDownloadedMaterialsCount(@RequestParam(value = "userId") Long userId) {
        Long count = materialService.getDownloadedMaterialsCount(userId);
        return ResponseEntity.ok(count);
    }

    @PostMapping("/{id}/download")
    public ResponseEntity<MaterialResponse> downloadMaterial(
            @PathVariable(value = "id") Long id,
            @RequestParam(value = "userId") Long userId) {
        MaterialResponse response = materialService.downloadMaterial(id, userId);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/count")
    public ResponseEntity<Long> getTotalMaterialsCount() {
        Long count = materialService.getTotalMaterialsCount();
        return ResponseEntity.ok(count);
    }
}

