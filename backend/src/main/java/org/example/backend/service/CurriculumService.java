package org.example.backend.service;

import org.example.backend.dto.CurriculumRequest;
import org.example.backend.dto.CurriculumResponse;
import org.example.backend.dto.PageResponse;
import org.springframework.data.domain.Pageable;

public interface CurriculumService {
    PageResponse<CurriculumResponse> getAllCurriculum(Pageable pageable, Long userId);
    CurriculumResponse getCurriculumById(Long id);
    CurriculumResponse createCurriculum(CurriculumRequest request);
    CurriculumResponse updateCurriculum(Long id, CurriculumRequest request);
    void deleteCurriculum(Long id);
    CurriculumResponse getCurriculumByBookNumber(Integer bookNumber);
    CurriculumResponse getCurriculumProgress(Long curriculumId, Long userId);
}

