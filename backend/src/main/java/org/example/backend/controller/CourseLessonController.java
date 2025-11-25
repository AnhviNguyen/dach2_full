package org.example.backend.controller;

import org.example.backend.dto.CurriculumLessonResponse;
import org.example.backend.dto.PageResponse;
import org.example.backend.service.CourseLessonService;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/course-lessons")
@CrossOrigin(origins = "*")
public class CourseLessonController {
    private final CourseLessonService courseLessonService;

    public CourseLessonController(CourseLessonService courseLessonService) {
        this.courseLessonService = courseLessonService;
    }

    @GetMapping
    public ResponseEntity<PageResponse<CurriculumLessonResponse>> getAllCourseLessons(
            @RequestParam(value = "page", defaultValue = "0") int page,
            @RequestParam(value = "size", defaultValue = "10") int size,
            @RequestParam(value = "sortBy", defaultValue = "id") String sortBy,
            @RequestParam(value = "direction", defaultValue = "ASC") Sort.Direction direction) {
        Pageable pageable = PageRequest.of(page, size, Sort.by(direction, sortBy));
        PageResponse<CurriculumLessonResponse> response = courseLessonService.getAllCourseLessons(pageable);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/{id}")
    public ResponseEntity<CurriculumLessonResponse> getCourseLessonById(@PathVariable(value = "id") Long id) {
        CurriculumLessonResponse response = courseLessonService.getCourseLessonById(id);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/course/{courseId}")
    public ResponseEntity<PageResponse<CurriculumLessonResponse>> getCourseLessonsByCourseId(
            @PathVariable(value = "courseId") Long courseId,
            @RequestParam(value = "page", defaultValue = "0") int page,
            @RequestParam(value = "size", defaultValue = "10") int size) {
        Pageable pageable = PageRequest.of(page, size);
        PageResponse<CurriculumLessonResponse> response = courseLessonService.getCourseLessonsByCourseId(courseId, pageable);
        return ResponseEntity.ok(response);
    }
}

