package org.example.backend.controller;

import org.example.backend.dto.CourseInfoResponse;
import org.example.backend.dto.CourseRequest;
import org.example.backend.dto.DashboardStatsResponse;
import org.example.backend.dto.PageResponse;
import org.example.backend.service.CourseService;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/courses")
@CrossOrigin(origins = "*")
public class CourseController {
    private final CourseService courseService;

    public CourseController(CourseService courseService) {
        this.courseService = courseService;
    }

    @GetMapping
    public ResponseEntity<PageResponse<CourseInfoResponse>> getAllCourses(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(defaultValue = "id") String sortBy,
            @RequestParam(defaultValue = "ASC") Sort.Direction direction) {
        Pageable pageable = PageRequest.of(page, size, Sort.by(direction, sortBy));
        PageResponse<CourseInfoResponse> response = courseService.getAllCourses(pageable);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/{id}")
    public ResponseEntity<CourseInfoResponse> getCourseById(@PathVariable Long id) {
        CourseInfoResponse response = courseService.getCourseById(id);
        return ResponseEntity.ok(response);
    }

    @PostMapping
    public ResponseEntity<CourseInfoResponse> createCourse(@RequestBody CourseRequest request) {
        CourseInfoResponse response = courseService.createCourse(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @PutMapping("/{id}")
    public ResponseEntity<CourseInfoResponse> updateCourse(
            @PathVariable Long id,
            @RequestBody CourseRequest request) {
        CourseInfoResponse response = courseService.updateCourse(id, request);
        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteCourse(@PathVariable Long id) {
        courseService.deleteCourse(id);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/level/{level}")
    public ResponseEntity<PageResponse<CourseInfoResponse>> getCoursesByLevel(
            @PathVariable String level,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        Pageable pageable = PageRequest.of(page, size);
        PageResponse<CourseInfoResponse> response = courseService.getCoursesByLevel(level, pageable);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/dashboard-stats/{userId}")
    public ResponseEntity<DashboardStatsResponse> getDashboardStats(@PathVariable Long userId) {
        DashboardStatsResponse response = courseService.getDashboardStats(userId);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/{courseId}/enroll/{userId}")
    public ResponseEntity<CourseInfoResponse> enrollUser(
            @PathVariable Long courseId,
            @PathVariable Long userId) {
        CourseInfoResponse response = courseService.enrollUser(courseId, userId);
        return ResponseEntity.ok(response);
    }
}

