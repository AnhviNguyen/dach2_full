package org.example.backend.service;

import org.example.backend.dto.CurriculumLessonResponse;
import org.example.backend.dto.PageResponse;
import org.springframework.data.domain.Pageable;

public interface CourseLessonService {
    PageResponse<CurriculumLessonResponse> getAllCourseLessons(Pageable pageable);
    CurriculumLessonResponse getCourseLessonById(Long id);
    PageResponse<CurriculumLessonResponse> getCourseLessonsByCourseId(Long courseId, Pageable pageable);
}

