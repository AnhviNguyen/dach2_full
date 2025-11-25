package org.example.backend.service.impl;

import org.example.backend.dto.*;
import org.example.backend.entity.*;
import org.example.backend.repository.*;
import org.example.backend.service.LessonService;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@Transactional
public class LessonServiceImpl implements LessonService {
    private final LessonRepository lessonRepository;
    private final GrammarRepository grammarRepository;
    private final ExerciseRepository exerciseRepository;

    public LessonServiceImpl(LessonRepository lessonRepository,
                             GrammarRepository grammarRepository,
                             ExerciseRepository exerciseRepository) {
        this.lessonRepository = lessonRepository;
        this.grammarRepository = grammarRepository;
        this.exerciseRepository = exerciseRepository;
    }

    @Override
    public PageResponse<LessonResponse> getAllLessons(Pageable pageable) {
        Page<Lesson> lessons = lessonRepository.findAll(pageable);
        List<LessonResponse> content = lessons.getContent().stream()
                .map(this::toLessonResponse)
                .collect(Collectors.toList());
        
        return new PageResponse<>(
            content,
            lessons.getNumber(),
            lessons.getSize(),
            lessons.getTotalElements(),
            lessons.getTotalPages(),
            lessons.hasNext(),
            lessons.hasPrevious()
        );
    }

    @Override
    public LessonResponse getLessonById(Long id) {
        Lesson lesson = lessonRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Lesson not found with id: " + id));
        return toLessonResponse(lesson);
    }

    @Override
    public PageResponse<LessonResponse> getLessonsByTextbookId(Long textbookId, Pageable pageable) {
        Page<Lesson> lessons = lessonRepository.findByTextbookIdWithPagination(textbookId, pageable);
        List<LessonResponse> content = lessons.getContent().stream()
                .map(this::toLessonResponse)
                .collect(Collectors.toList());
        
        return new PageResponse<>(
            content,
            lessons.getNumber(),
            lessons.getSize(),
            lessons.getTotalElements(),
            lessons.getTotalPages(),
            lessons.hasNext(),
            lessons.hasPrevious()
        );
    }

    @Override
    public PageResponse<LessonResponse> getLessonsByCourseId(Long courseId, Pageable pageable) {
        Page<Lesson> lessons = lessonRepository.findByCourseIdWithPagination(courseId, pageable);
        List<LessonResponse> content = lessons.getContent().stream()
                .map(this::toLessonResponse)
                .collect(Collectors.toList());
        
        return new PageResponse<>(
            content,
            lessons.getNumber(),
            lessons.getSize(),
            lessons.getTotalElements(),
            lessons.getTotalPages(),
            lessons.hasNext(),
            lessons.hasPrevious()
        );
    }

    private LessonResponse toLessonResponse(Lesson lesson) {
        // Note: This service is deprecated. Use CurriculumLessonService or CourseLessonService instead.
        // For now, we'll return empty lists as Lesson entity is being phased out
        // Vocabulary is no longer available for old Lesson entity
        List<Grammar> grammars = lesson.getCourse() != null 
            ? grammarRepository.findByCourseLessonId(lesson.getId())
            : List.of();
        List<Exercise> exercises = lesson.getCourse() != null
            ? exerciseRepository.findByCourseLessonId(lesson.getId())
            : List.of();
        
        // Vocabulary is no longer available for old Lesson entity
        // Use CurriculumLessonService or CourseLessonService for vocabulary
        List<VocabularyItemResponse> vocabularyResponses = List.of();
        
        List<GrammarItemResponse> grammarResponses = grammars.stream()
                .map(g -> {
                    List<String> examples = g.getExamples().stream()
                            .map(GrammarExample::getExampleText)
                            .collect(Collectors.toList());
                    return new GrammarItemResponse(
                        g.getTitle(),
                        g.getExplanation(),
                        examples
                    );
                })
                .collect(Collectors.toList());
        
        List<ExerciseItemResponse> exerciseResponses = exercises.stream()
                .map(e -> {
                    List<String> options = e.getOptions().stream()
                            .map(ExerciseOption::getOptionText)
                            .collect(Collectors.toList());
                    return new ExerciseItemResponse(
                        e.getId(),
                        e.getType(),
                        e.getQuestion(),
                        options.isEmpty() ? null : options,
                        e.getCorrectIndex(),
                        e.getAnswer()
                    );
                })
                .collect(Collectors.toList());
        
        return new LessonResponse(
            lesson.getId(),
            lesson.getTitle(),
            lesson.getLevel(),
            lesson.getDuration(),
            lesson.getProgress(),
            lesson.getLessonNumber(),
            vocabularyResponses,
            grammarResponses,
            exerciseResponses
        );
    }
}

