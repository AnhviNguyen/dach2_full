package org.example.backend.service;

import org.example.backend.dto.CurriculumLessonResponse;
import org.example.backend.dto.PageResponse;
import org.springframework.data.domain.Pageable;

public interface CurriculumLessonService {
    PageResponse<CurriculumLessonResponse> getAllCurriculumLessons(Pageable pageable);
    CurriculumLessonResponse getCurriculumLessonById(Long id);
    PageResponse<CurriculumLessonResponse> getCurriculumLessonsByCurriculumId(Long curriculumId, Pageable pageable);
}

