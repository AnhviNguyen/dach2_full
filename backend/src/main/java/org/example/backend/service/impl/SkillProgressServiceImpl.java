package org.example.backend.service.impl;

import org.example.backend.dto.SkillProgressResponse;
import org.example.backend.entity.SkillProgress;
import org.example.backend.entity.User;
import org.example.backend.repository.SkillProgressRepository;
import org.example.backend.repository.UserRepository;
import org.example.backend.service.SkillProgressService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@Transactional
public class SkillProgressServiceImpl implements SkillProgressService {
    private final SkillProgressRepository skillProgressRepository;
    private final UserRepository userRepository;

    public SkillProgressServiceImpl(SkillProgressRepository skillProgressRepository,
                                   UserRepository userRepository) {
        this.skillProgressRepository = skillProgressRepository;
        this.userRepository = userRepository;
    }

    @Override
    public List<SkillProgressResponse> getUserSkillProgress(Long userId) {
        List<SkillProgress> skills = skillProgressRepository.findByUserId(userId);
        
        // Nếu user chưa có skill progress, tạo skill progress mặc định
        if (skills.isEmpty()) {
            User user = userRepository.findById(userId)
                    .orElseThrow(() -> new RuntimeException("User not found with id: " + userId));
            
            // Tạo skill progress mặc định cho user mới
            skills = createDefaultSkillProgress(user);
        }
        
        return skills.stream()
                .map(skill -> new SkillProgressResponse(
                        skill.getLabel(),
                        skill.getPercent() != null ? skill.getPercent() : 0.0,
                        skill.getColor() != null ? skill.getColor() : "#000000"
                ))
                .collect(Collectors.toList());
    }

    private List<SkillProgress> createDefaultSkillProgress(User user) {
        List<SkillProgress> defaultSkills = List.of(
                createSkillProgress(user, "Nghe", 0.0, "#FFD700"),
                createSkillProgress(user, "Nói", 0.0, "#FF6B6B"),
                createSkillProgress(user, "Đọc", 0.0, "#4ECDC4"),
                createSkillProgress(user, "Viết", 0.0, "#95E1D3")
        );
        
        return skillProgressRepository.saveAll(defaultSkills);
    }

    private SkillProgress createSkillProgress(User user, String label, Double percent, String color) {
        SkillProgress skill = new SkillProgress();
        skill.setUser(user);
        skill.setLabel(label);
        skill.setPercent(percent);
        skill.setColor(color);
        return skill;
    }
}

