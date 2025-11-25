package org.example.backend.controller;

import org.example.backend.dto.CurriculumRequest;
import org.example.backend.dto.CurriculumResponse;
import org.example.backend.dto.PageResponse;
import org.example.backend.service.CurriculumService;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/curriculum")
@CrossOrigin(origins = "*")
public class CurriculumController {
    private final CurriculumService curriculumService;

    public CurriculumController(CurriculumService curriculumService) {
        this.curriculumService = curriculumService;
    }

    @GetMapping
    public ResponseEntity<PageResponse<CurriculumResponse>> getAllCurriculum(
            @RequestParam(value = "page", defaultValue = "0") int page,
            @RequestParam(value = "size", defaultValue = "10") int size,
            @RequestParam(value = "sortBy", defaultValue = "bookNumber") String sortBy,
            @RequestParam(value = "direction", defaultValue = "ASC") Sort.Direction direction,
            @RequestParam(value = "userId", required = false) Long userId) {
        Pageable pageable = PageRequest.of(page, size, Sort.by(direction, sortBy));
        PageResponse<CurriculumResponse> response = curriculumService.getAllCurriculum(pageable, userId);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/{id}")
    public ResponseEntity<CurriculumResponse> getCurriculumById(@PathVariable(value = "id") Long id) {
        CurriculumResponse response = curriculumService.getCurriculumById(id);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/book-number/{bookNumber}")
    public ResponseEntity<CurriculumResponse> getCurriculumByBookNumber(@PathVariable(value = "bookNumber") Integer bookNumber) {
        CurriculumResponse response = curriculumService.getCurriculumByBookNumber(bookNumber);
        return ResponseEntity.ok(response);
    }

    @PostMapping
    public ResponseEntity<CurriculumResponse> createCurriculum(@RequestBody CurriculumRequest request) {
        CurriculumResponse response = curriculumService.createCurriculum(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @PutMapping("/{id}")
    public ResponseEntity<CurriculumResponse> updateCurriculum(
            @PathVariable(value = "id") Long id,
            @RequestBody CurriculumRequest request) {
        CurriculumResponse response = curriculumService.updateCurriculum(id, request);
        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteCurriculum(@PathVariable(value = "id") Long id) {
        curriculumService.deleteCurriculum(id);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/{curriculumId}/progress/{userId}")
    public ResponseEntity<CurriculumResponse> getCurriculumProgress(
            @PathVariable(value = "curriculumId") Long curriculumId,
            @PathVariable(value = "userId") Long userId) {
        CurriculumResponse response = curriculumService.getCurriculumProgress(curriculumId, userId);
        return ResponseEntity.ok(response);
    }
}

