package org.example.backend.controller;

import org.example.backend.dto.PageResponse;
import org.example.backend.dto.RankingEntryResponse;
import org.example.backend.service.RankingService;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/rankings")
@CrossOrigin(origins = "*")
public class RankingController {
    private final RankingService rankingService;

    public RankingController(RankingService rankingService) {
        this.rankingService = rankingService;
    }

    @GetMapping
    public ResponseEntity<PageResponse<RankingEntryResponse>> getAllRankings(
            @RequestParam(value = "page", defaultValue = "0") int page,
            @RequestParam(value = "size", defaultValue = "10") int size) {
        Pageable pageable = PageRequest.of(page, size);
        PageResponse<RankingEntryResponse> response = rankingService.getAllRankings(pageable);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/all")
    public ResponseEntity<List<RankingEntryResponse>> getAllRankingsList() {
        List<RankingEntryResponse> response = rankingService.getAllRankings();
        return ResponseEntity.ok(response);
    }

    @GetMapping("/user/{userId}")
    public ResponseEntity<RankingEntryResponse> getRankingByUserId(@PathVariable(value = "userId") Long userId) {
        RankingEntryResponse response = rankingService.getRankingByUserId(userId);
        return ResponseEntity.ok(response);
    }
}

