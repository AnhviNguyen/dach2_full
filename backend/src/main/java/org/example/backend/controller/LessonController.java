package org.example.backend.controller;

import org.example.backend.dto.LessonResponse;
import org.example.backend.dto.PageResponse;
import org.example.backend.service.LessonService;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/lessons")
@CrossOrigin(origins = "*")
public class LessonController {
    private final LessonService lessonService;

    public LessonController(LessonService lessonService) {
        this.lessonService = lessonService;
    }

    @GetMapping
    public ResponseEntity<PageResponse<LessonResponse>> getAllLessons(
            @RequestParam(value = "page", defaultValue = "0") int page,
            @RequestParam(value = "size", defaultValue = "10") int size,
            @RequestParam(value = "sortBy", defaultValue = "id") String sortBy,
            @RequestParam(value = "direction", defaultValue = "ASC") Sort.Direction direction) {
        Pageable pageable = PageRequest.of(page, size, Sort.by(direction, sortBy));
        PageResponse<LessonResponse> response = lessonService.getAllLessons(pageable);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/{id}")
    public ResponseEntity<LessonResponse> getLessonById(@PathVariable(value = "id") Long id) {
        LessonResponse response = lessonService.getLessonById(id);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/textbook/{textbookId}")
    public ResponseEntity<PageResponse<LessonResponse>> getLessonsByTextbookId(
            @PathVariable(value = "textbookId") Long textbookId,
            @RequestParam(value = "page", defaultValue = "0") int page,
            @RequestParam(value = "size", defaultValue = "10") int size) {
        Pageable pageable = PageRequest.of(page, size);
        PageResponse<LessonResponse> response = lessonService.getLessonsByTextbookId(textbookId, pageable);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/course/{courseId}")
    public ResponseEntity<PageResponse<LessonResponse>> getLessonsByCourseId(
            @PathVariable(value = "courseId") Long courseId,
            @RequestParam(value = "page", defaultValue = "0") int page,
            @RequestParam(value = "size", defaultValue = "10") int size) {
        Pageable pageable = PageRequest.of(page, size);
        PageResponse<LessonResponse> response = lessonService.getLessonsByCourseId(courseId, pageable);
        return ResponseEntity.ok(response);
    }
}

