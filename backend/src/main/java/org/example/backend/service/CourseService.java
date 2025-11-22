package org.example.backend.service;

import org.example.backend.dto.CourseInfoResponse;
import org.example.backend.dto.CourseRequest;
import org.example.backend.dto.DashboardStatsResponse;
import org.example.backend.dto.PageResponse;
import org.springframework.data.domain.Pageable;

public interface CourseService {
    PageResponse<CourseInfoResponse> getAllCourses(Pageable pageable);
    CourseInfoResponse getCourseById(Long id);
    CourseInfoResponse createCourse(CourseRequest request);
    CourseInfoResponse updateCourse(Long id, CourseRequest request);
    void deleteCourse(Long id);
    PageResponse<CourseInfoResponse> getCoursesByLevel(String level, Pageable pageable);
    DashboardStatsResponse getDashboardStats(Long userId);
    CourseInfoResponse enrollUser(Long courseId, Long userId);
}

