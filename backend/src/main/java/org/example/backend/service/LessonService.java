package org.example.backend.service;

import org.example.backend.dto.LessonResponse;
import org.example.backend.dto.PageResponse;
import org.springframework.data.domain.Pageable;

public interface LessonService {
    PageResponse<LessonResponse> getAllLessons(Pageable pageable);
    LessonResponse getLessonById(Long id);
    PageResponse<LessonResponse> getLessonsByTextbookId(Long textbookId, Pageable pageable);
    PageResponse<LessonResponse> getLessonsByCourseId(Long courseId, Pageable pageable);
}

