package org.example.backend.controller;

import org.example.backend.dto.SkillProgressResponse;
import org.example.backend.service.SkillProgressService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/skills")
@CrossOrigin(origins = "*")
public class SkillProgressController {
    private final SkillProgressService skillProgressService;

    public SkillProgressController(SkillProgressService skillProgressService) {
        this.skillProgressService = skillProgressService;
    }

    @GetMapping("/user/{userId}")
    public ResponseEntity<List<SkillProgressResponse>> getUserSkillProgress(@PathVariable(value = "userId") Long userId) {
        List<SkillProgressResponse> response = skillProgressService.getUserSkillProgress(userId);
        return ResponseEntity.ok(response);
    }
}

