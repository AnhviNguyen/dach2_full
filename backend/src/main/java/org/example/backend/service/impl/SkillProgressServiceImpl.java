package org.example.backend.service.impl;

import org.example.backend.dto.SkillProgressResponse;
import org.example.backend.entity.Curriculum;
import org.example.backend.repository.CurriculumProgressRepository;
import org.example.backend.repository.CurriculumRepository;
import org.example.backend.repository.UserRepository;
import org.example.backend.service.SkillProgressService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;

@Service
@Transactional
public class SkillProgressServiceImpl implements SkillProgressService {
    private final CurriculumProgressRepository curriculumProgressRepository;
    private final CurriculumRepository curriculumRepository;
    private final UserRepository userRepository;

    public SkillProgressServiceImpl(
            CurriculumProgressRepository curriculumProgressRepository,
            CurriculumRepository curriculumRepository,
            UserRepository userRepository) {
        this.curriculumProgressRepository = curriculumProgressRepository;
        this.curriculumRepository = curriculumRepository;
        this.userRepository = userRepository;
    }

    @Override
    public List<SkillProgressResponse> getUserSkillProgress(Long userId) {
        // Verify user exists
        userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found with id: " + userId));

        // Calculate progress based on curriculum progress
        // Formula: total completed lessons / total lessons in all curricula
        final int[] totalCompletedLessonsArray = {0}; // Use array to work around effectively final requirement
        int totalLessons = 0;

        // Get all curricula
        List<Curriculum> allCurricula = curriculumRepository.findAll();
        
        // Calculate total completed and total lessons
        for (Curriculum curriculum : allCurricula) {
            totalLessons += curriculum.getTotalLessons() != null ? curriculum.getTotalLessons() : 0;
            
            // Get user's progress for this curriculum
            curriculumProgressRepository.findByUserIdAndCurriculumId(userId, curriculum.getId())
                    .ifPresent(progress -> {
                        int completed = progress.getCompletedLessons() != null ? progress.getCompletedLessons() : 0;
                        // Use array to work around effectively final requirement
                        totalCompletedLessonsArray[0] += completed;
                    });
        }
        
        // Extract value from array
        int totalCompletedLessons = totalCompletedLessonsArray[0];

        // Calculate percentage (0.0 to 1.0)
        double progressPercent = totalLessons > 0 
                ? (double) totalCompletedLessons / totalLessons 
                : 0.0;
        
        // Ensure progress is between 0.0 and 1.0
        progressPercent = Math.max(0.0, Math.min(1.0, progressPercent));

        // Return exactly 4 skills with the same progress
        List<SkillProgressResponse> skills = new ArrayList<>();
        skills.add(new SkillProgressResponse("Nghe", progressPercent, "#FF6B6B"));
        skills.add(new SkillProgressResponse("Nói", progressPercent, "#4ECDC4"));
        skills.add(new SkillProgressResponse("Đọc", progressPercent, "#95E1D3"));
        skills.add(new SkillProgressResponse("Viết", progressPercent, "#F38181"));

        return skills;
    }
}

