package org.example.backend.service;

import org.example.backend.dto.PageResponse;
import org.example.backend.dto.TextbookRequest;
import org.example.backend.dto.TextbookResponse;
import org.springframework.data.domain.Pageable;

public interface TextbookService {
    PageResponse<TextbookResponse> getAllTextbooks(Pageable pageable);
    TextbookResponse getTextbookById(Long id);
    TextbookResponse createTextbook(TextbookRequest request);
    TextbookResponse updateTextbook(Long id, TextbookRequest request);
    void deleteTextbook(Long id);
    TextbookResponse getTextbookByBookNumber(Integer bookNumber);
    TextbookResponse getTextbookProgress(Long textbookId, Long userId);
}

