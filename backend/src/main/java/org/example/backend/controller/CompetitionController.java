package org.example.backend.controller;

import org.example.backend.dto.*;
import org.example.backend.service.CompetitionService;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/competitions")
@CrossOrigin(origins = "*")
public class CompetitionController {
    private final CompetitionService competitionService;

    public CompetitionController(CompetitionService competitionService) {
        this.competitionService = competitionService;
    }

    @GetMapping
    public ResponseEntity<PageResponse<CompetitionResponse>> getAllCompetitions(
            @RequestParam(value = "page", defaultValue = "0") int page,
            @RequestParam(value = "size", defaultValue = "10") int size,
            @RequestParam(value = "sortBy", defaultValue = "id") String sortBy,
            @RequestParam(value = "direction", defaultValue = "ASC") Sort.Direction direction,
            @RequestParam(value = "currentUserId", required = false) Long currentUserId) {
        Pageable pageable = PageRequest.of(page, size, Sort.by(direction, sortBy));
        PageResponse<CompetitionResponse> response = competitionService.getAllCompetitions(pageable, currentUserId);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/status/{status}")
    public ResponseEntity<PageResponse<CompetitionResponse>> getCompetitionsByStatus(
            @PathVariable(value = "status") String status,
            @RequestParam(value = "page", defaultValue = "0") int page,
            @RequestParam(value = "size", defaultValue = "10") int size,
            @RequestParam(value = "currentUserId", required = false) Long currentUserId) {
        Pageable pageable = PageRequest.of(page, size);
        PageResponse<CompetitionResponse> response = competitionService.getCompetitionsByStatus(status, pageable, currentUserId);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/{id}")
    public ResponseEntity<CompetitionResponse> getCompetitionById(
            @PathVariable(value = "id") Long id,
            @RequestParam(value = "currentUserId", required = false) Long currentUserId) {
        CompetitionResponse response = competitionService.getCompetitionById(id, currentUserId);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/{id}/questions")
    public ResponseEntity<List<CompetitionQuestionResponse>> getCompetitionQuestions(
            @PathVariable(value = "id") Long id) {
        List<CompetitionQuestionResponse> response = competitionService.getCompetitionQuestions(id);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/{id}/join")
    public ResponseEntity<CompetitionResponse> joinCompetition(
            @PathVariable(value = "id") Long id,
            @RequestParam(value = "userId") Long userId) {
        CompetitionResponse response = competitionService.joinCompetition(id, userId);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/submit")
    public ResponseEntity<CompetitionResultResponse> submitCompetition(
            @RequestBody CompetitionSubmissionRequest request,
            @RequestParam(value = "userId") Long userId) {
        CompetitionResultResponse response = competitionService.submitCompetition(request, userId);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/{id}/result")
    public ResponseEntity<CompetitionResultResponse> getCompetitionResult(
            @PathVariable(value = "id") Long id,
            @RequestParam(value = "userId") Long userId) {
        CompetitionResultResponse response = competitionService.getCompetitionResult(id, userId);
        return ResponseEntity.ok(response);
    }
}

