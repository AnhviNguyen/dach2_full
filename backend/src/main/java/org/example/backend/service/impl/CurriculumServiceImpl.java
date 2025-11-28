package org.example.backend.service.impl;

import org.example.backend.dto.CurriculumRequest;
import org.example.backend.dto.CurriculumResponse;
import org.example.backend.dto.PageResponse;
import org.example.backend.entity.Curriculum;
import org.example.backend.entity.CurriculumProgress;
import org.example.backend.entity.User;
import org.example.backend.repository.CurriculumProgressRepository;
import org.example.backend.repository.CurriculumRepository;
import org.example.backend.repository.UserRepository;
import org.example.backend.service.CurriculumService;
import org.hibernate.Hibernate;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@Transactional
public class CurriculumServiceImpl implements CurriculumService {
    private final CurriculumRepository curriculumRepository;
    private final CurriculumProgressRepository progressRepository;
    private final UserRepository userRepository;

    public CurriculumServiceImpl(CurriculumRepository curriculumRepository,
                              CurriculumProgressRepository progressRepository,
                              UserRepository userRepository) {
        this.curriculumRepository = curriculumRepository;
        this.progressRepository = progressRepository;
        this.userRepository = userRepository;
    }

    @Override
    @Transactional(readOnly = true)
    public PageResponse<CurriculumResponse> getAllCurriculum(Pageable pageable, Long userId) {
        Page<Curriculum> curriculum = curriculumRepository.findAllDistinct(pageable);
        
        // Initialize lazy collections and remove duplicates by ID
        Map<Long, Curriculum> uniqueCurriculumMap = new LinkedHashMap<>();
        for (Curriculum c : curriculum.getContent()) {
            // Initialize lazy collections
            Hibernate.initialize(c.getProgresses());
            Hibernate.initialize(c.getLessons());
            
            // Remove duplicates by ID (keep first occurrence)
            uniqueCurriculumMap.putIfAbsent(c.getId(), c);
        }
        
        // Nếu có userId, xử lý progress cho user
        if (userId != null) {
            User user = userRepository.findById(userId)
                    .orElseThrow(() -> new RuntimeException("User not found with id: " + userId));
            
            // Nếu user mới (chưa có progress), auto tạo progress cho curriculum đầu tiên (bookNumber = 1)
            if (!uniqueCurriculumMap.isEmpty()) {
                Curriculum firstCurriculum = uniqueCurriculumMap.values().stream()
                        .filter(c -> c.getBookNumber() == 1)
                        .findFirst()
                        .orElse(uniqueCurriculumMap.values().iterator().next());
                
                // Kiểm tra xem đã có progress cho curriculum đầu tiên chưa
                boolean hasProgress = progressRepository.findByUserIdAndCurriculumId(userId, firstCurriculum.getId())
                        .isPresent();
                
                // Nếu chưa có, tạo progress mới
                if (!hasProgress) {
                    CurriculumProgress newProgress = new CurriculumProgress();
                    newProgress.setUser(user);
                    newProgress.setCurriculum(firstCurriculum);
                    newProgress.setCompletedLessons(0);
                    newProgress.setIsCompleted(false);
                    newProgress.setIsLocked(false);
                    progressRepository.save(newProgress);
                }
            }
        }
        
        List<CurriculumResponse> content = uniqueCurriculumMap.values().stream()
                .map(c -> {
                    // Nếu có userId, lấy progress của user cho curriculum này
                    if (userId != null) {
                        return progressRepository.findByUserIdAndCurriculumId(userId, c.getId())
                                .map(progress -> new CurriculumResponse(
                                        c.getId(),
                                        c.getBookNumber(),
                                        c.getTitle(),
                                        c.getSubtitle(),
                                        c.getTotalLessons(),
                                        progress.getCompletedLessons(),
                                        progress.getIsCompleted(),
                                        progress.getIsLocked(),
                                        c.getColor()
                                ))
                                .orElse(toCurriculumResponse(c)); // Nếu chưa có progress, trả về default
                    }
                    return toCurriculumResponse(c);
                })
                .collect(Collectors.toList());
        
        // Recalculate total elements based on unique curriculum
        long uniqueTotal = uniqueCurriculumMap.size();
        
        return new PageResponse<>(
            content,
            curriculum.getNumber(),
            curriculum.getSize(),
            uniqueTotal,
            (int) Math.ceil((double) uniqueTotal / curriculum.getSize()),
            curriculum.hasNext(),
            curriculum.hasPrevious()
        );
    }

    @Override
    public CurriculumResponse getCurriculumById(Long id) {
        Curriculum curriculum = curriculumRepository.findByIdWithCollections(id)
                .orElseThrow(() -> new RuntimeException("Curriculum not found with id: " + id));
        return toCurriculumResponse(curriculum);
    }

    @Override
    public CurriculumResponse createCurriculum(CurriculumRequest request) {
        Curriculum curriculum = new Curriculum();
        curriculum.setBookNumber(request.bookNumber());
        curriculum.setTitle(request.title());
        curriculum.setSubtitle(request.subtitle());
        curriculum.setTotalLessons(request.totalLessons());
        curriculum.setColor(request.color());
        Curriculum saved = curriculumRepository.save(curriculum);
        return toCurriculumResponse(saved);
    }

    @Override
    public CurriculumResponse updateCurriculum(Long id, CurriculumRequest request) {
        Curriculum curriculum = curriculumRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Curriculum not found with id: " + id));
        curriculum.setBookNumber(request.bookNumber());
        curriculum.setTitle(request.title());
        curriculum.setSubtitle(request.subtitle());
        curriculum.setTotalLessons(request.totalLessons());
        curriculum.setColor(request.color());
        Curriculum updated = curriculumRepository.save(curriculum);
        return toCurriculumResponse(updated);
    }

    @Override
    public void deleteCurriculum(Long id) {
        if (!curriculumRepository.existsById(id)) {
            throw new RuntimeException("Curriculum not found with id: " + id);
        }
        curriculumRepository.deleteById(id);
    }

    @Override
    public CurriculumResponse getCurriculumByBookNumber(Integer bookNumber) {
        Curriculum curriculum = curriculumRepository.findByBookNumber(bookNumber)
                .orElseThrow(() -> new RuntimeException("Curriculum not found with book number: " + bookNumber));
        return toCurriculumResponse(curriculum);
    }

    @Override
    public CurriculumResponse getCurriculumProgress(Long curriculumId, Long userId) {
        Curriculum curriculum = curriculumRepository.findById(curriculumId)
                .orElseThrow(() -> new RuntimeException("Curriculum not found"));
        CurriculumProgress progress = progressRepository.findByUserIdAndCurriculumId(userId, curriculumId)
                .orElseGet(() -> {
                    User user = userRepository.findById(userId)
                            .orElseThrow(() -> new RuntimeException("User not found"));
                    CurriculumProgress newProgress = new CurriculumProgress();
                    newProgress.setUser(user);
                    newProgress.setCurriculum(curriculum);
                    newProgress.setCompletedLessons(0);
                    newProgress.setIsCompleted(false);
                    newProgress.setIsLocked(false);
                    return progressRepository.save(newProgress);
                });
        
        return new CurriculumResponse(
            curriculum.getId(),
            curriculum.getBookNumber(),
            curriculum.getTitle(),
            curriculum.getSubtitle(),
            curriculum.getTotalLessons(),
            progress.getCompletedLessons(),
            progress.getIsCompleted(),
            progress.getIsLocked(),
            curriculum.getColor()
        );
    }

    private CurriculumResponse toCurriculumResponse(Curriculum curriculum) {
        return new CurriculumResponse(
            curriculum.getId(),
            curriculum.getBookNumber(),
            curriculum.getTitle(),
            curriculum.getSubtitle(),
            curriculum.getTotalLessons(),
            0,
            false,
            false,
            curriculum.getColor()
        );
    }
}

