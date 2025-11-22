package org.example.backend.service.impl;

import org.example.backend.dto.PageResponse;
import org.example.backend.dto.TextbookRequest;
import org.example.backend.dto.TextbookResponse;
import org.example.backend.entity.Textbook;
import org.example.backend.entity.TextbookProgress;
import org.example.backend.entity.User;
import org.example.backend.repository.TextbookProgressRepository;
import org.example.backend.repository.TextbookRepository;
import org.example.backend.repository.UserRepository;
import org.example.backend.service.TextbookService;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@Transactional
public class TextbookServiceImpl implements TextbookService {
    private final TextbookRepository textbookRepository;
    private final TextbookProgressRepository progressRepository;
    private final UserRepository userRepository;

    public TextbookServiceImpl(TextbookRepository textbookRepository,
                              TextbookProgressRepository progressRepository,
                              UserRepository userRepository) {
        this.textbookRepository = textbookRepository;
        this.progressRepository = progressRepository;
        this.userRepository = userRepository;
    }

    @Override
    public PageResponse<TextbookResponse> getAllTextbooks(Pageable pageable) {
        Page<Textbook> textbooks = textbookRepository.findAll(pageable);
        List<TextbookResponse> content = textbooks.getContent().stream()
                .map(this::toTextbookResponse)
                .collect(Collectors.toList());
        
        return new PageResponse<>(
            content,
            textbooks.getNumber(),
            textbooks.getSize(),
            textbooks.getTotalElements(),
            textbooks.getTotalPages(),
            textbooks.hasNext(),
            textbooks.hasPrevious()
        );
    }

    @Override
    public TextbookResponse getTextbookById(Long id) {
        Textbook textbook = textbookRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Textbook not found with id: " + id));
        return toTextbookResponse(textbook);
    }

    @Override
    public TextbookResponse createTextbook(TextbookRequest request) {
        Textbook textbook = new Textbook();
        textbook.setBookNumber(request.bookNumber());
        textbook.setTitle(request.title());
        textbook.setSubtitle(request.subtitle());
        textbook.setTotalLessons(request.totalLessons());
        textbook.setColor(request.color());
        Textbook saved = textbookRepository.save(textbook);
        return toTextbookResponse(saved);
    }

    @Override
    public TextbookResponse updateTextbook(Long id, TextbookRequest request) {
        Textbook textbook = textbookRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Textbook not found with id: " + id));
        textbook.setBookNumber(request.bookNumber());
        textbook.setTitle(request.title());
        textbook.setSubtitle(request.subtitle());
        textbook.setTotalLessons(request.totalLessons());
        textbook.setColor(request.color());
        Textbook updated = textbookRepository.save(textbook);
        return toTextbookResponse(updated);
    }

    @Override
    public void deleteTextbook(Long id) {
        if (!textbookRepository.existsById(id)) {
            throw new RuntimeException("Textbook not found with id: " + id);
        }
        textbookRepository.deleteById(id);
    }

    @Override
    public TextbookResponse getTextbookByBookNumber(Integer bookNumber) {
        Textbook textbook = textbookRepository.findByBookNumber(bookNumber)
                .orElseThrow(() -> new RuntimeException("Textbook not found with book number: " + bookNumber));
        return toTextbookResponse(textbook);
    }

    @Override
    public TextbookResponse getTextbookProgress(Long textbookId, Long userId) {
        Textbook textbook = textbookRepository.findById(textbookId)
                .orElseThrow(() -> new RuntimeException("Textbook not found"));
        TextbookProgress progress = progressRepository.findByUserIdAndTextbookId(userId, textbookId)
                .orElseGet(() -> {
                    User user = userRepository.findById(userId)
                            .orElseThrow(() -> new RuntimeException("User not found"));
                    TextbookProgress newProgress = new TextbookProgress();
                    newProgress.setUser(user);
                    newProgress.setTextbook(textbook);
                    newProgress.setCompletedLessons(0);
                    newProgress.setIsCompleted(false);
                    newProgress.setIsLocked(false);
                    return progressRepository.save(newProgress);
                });
        
        return new TextbookResponse(
            textbook.getBookNumber(),
            textbook.getTitle(),
            textbook.getSubtitle(),
            textbook.getTotalLessons(),
            progress.getCompletedLessons(),
            progress.getIsCompleted(),
            progress.getIsLocked(),
            textbook.getColor()
        );
    }

    private TextbookResponse toTextbookResponse(Textbook textbook) {
        return new TextbookResponse(
            textbook.getBookNumber(),
            textbook.getTitle(),
            textbook.getSubtitle(),
            textbook.getTotalLessons(),
            0,
            false,
            false,
            textbook.getColor()
        );
    }
}

