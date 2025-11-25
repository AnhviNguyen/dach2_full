package org.example.backend.controller;

import org.example.backend.dto.CurriculumLessonResponse;
import org.example.backend.dto.PageResponse;
import org.example.backend.service.CurriculumLessonService;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/curriculum-lessons")
@CrossOrigin(origins = "*")
public class CurriculumLessonController {
    private final CurriculumLessonService curriculumLessonService;

    public CurriculumLessonController(CurriculumLessonService curriculumLessonService) {
        this.curriculumLessonService = curriculumLessonService;
    }

    @GetMapping
    public ResponseEntity<PageResponse<CurriculumLessonResponse>> getAllCurriculumLessons(
            @RequestParam(value = "page", defaultValue = "0") int page,
            @RequestParam(value = "size", defaultValue = "10") int size,
            @RequestParam(value = "sortBy", defaultValue = "id") String sortBy,
            @RequestParam(value = "direction", defaultValue = "ASC") Sort.Direction direction) {
        Pageable pageable = PageRequest.of(page, size, Sort.by(direction, sortBy));
        PageResponse<CurriculumLessonResponse> response = curriculumLessonService.getAllCurriculumLessons(pageable);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/{id}")
    public ResponseEntity<CurriculumLessonResponse> getCurriculumLessonById(@PathVariable(value = "id") Long id) {
        CurriculumLessonResponse response = curriculumLessonService.getCurriculumLessonById(id);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/curriculum/{curriculumId}")
    public ResponseEntity<PageResponse<CurriculumLessonResponse>> getCurriculumLessonsByCurriculumId(
            @PathVariable(value = "curriculumId") Long curriculumId,
            @RequestParam(value = "page", defaultValue = "0") int page,
            @RequestParam(value = "size", defaultValue = "10") int size) {
        Pageable pageable = PageRequest.of(page, size);
        PageResponse<CurriculumLessonResponse> response = curriculumLessonService.getCurriculumLessonsByCurriculumId(curriculumId, pageable);
        return ResponseEntity.ok(response);
    }
}

