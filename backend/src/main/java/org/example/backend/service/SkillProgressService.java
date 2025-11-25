package org.example.backend.service;

import org.example.backend.dto.SkillProgressResponse;

import java.util.List;

public interface SkillProgressService {
    List<SkillProgressResponse> getUserSkillProgress(Long userId);
}

