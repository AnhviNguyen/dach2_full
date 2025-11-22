package org.example.backend.controller;

import org.example.backend.dto.PageResponse;
import org.example.backend.dto.TextbookRequest;
import org.example.backend.dto.TextbookResponse;
import org.example.backend.service.TextbookService;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/textbooks")
@CrossOrigin(origins = "*")
public class TextbookController {
    private final TextbookService textbookService;

    public TextbookController(TextbookService textbookService) {
        this.textbookService = textbookService;
    }

    @GetMapping
    public ResponseEntity<PageResponse<TextbookResponse>> getAllTextbooks(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(defaultValue = "bookNumber") String sortBy,
            @RequestParam(defaultValue = "ASC") Sort.Direction direction) {
        Pageable pageable = PageRequest.of(page, size, Sort.by(direction, sortBy));
        PageResponse<TextbookResponse> response = textbookService.getAllTextbooks(pageable);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/{id}")
    public ResponseEntity<TextbookResponse> getTextbookById(@PathVariable Long id) {
        TextbookResponse response = textbookService.getTextbookById(id);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/book-number/{bookNumber}")
    public ResponseEntity<TextbookResponse> getTextbookByBookNumber(@PathVariable Integer bookNumber) {
        TextbookResponse response = textbookService.getTextbookByBookNumber(bookNumber);
        return ResponseEntity.ok(response);
    }

    @PostMapping
    public ResponseEntity<TextbookResponse> createTextbook(@RequestBody TextbookRequest request) {
        TextbookResponse response = textbookService.createTextbook(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @PutMapping("/{id}")
    public ResponseEntity<TextbookResponse> updateTextbook(
            @PathVariable Long id,
            @RequestBody TextbookRequest request) {
        TextbookResponse response = textbookService.updateTextbook(id, request);
        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteTextbook(@PathVariable Long id) {
        textbookService.deleteTextbook(id);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/{textbookId}/progress/{userId}")
    public ResponseEntity<TextbookResponse> getTextbookProgress(
            @PathVariable Long textbookId,
            @PathVariable Long userId) {
        TextbookResponse response = textbookService.getTextbookProgress(textbookId, userId);
        return ResponseEntity.ok(response);
    }
}

