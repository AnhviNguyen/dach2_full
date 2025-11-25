package org.example.backend.service.impl;

import org.example.backend.dto.*;
import org.example.backend.entity.*;
import org.example.backend.repository.*;
import org.example.backend.service.CourseLessonService;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@Transactional
public class CourseLessonServiceImpl implements CourseLessonService {
    private final CourseLessonRepository courseLessonRepository;
    private final CourseVocabularyRepository vocabularyRepository;
    private final GrammarRepository grammarRepository;
    private final ExerciseRepository exerciseRepository;

    public CourseLessonServiceImpl(CourseLessonRepository courseLessonRepository,
                                 CourseVocabularyRepository vocabularyRepository,
                                 GrammarRepository grammarRepository,
                                 ExerciseRepository exerciseRepository) {
        this.courseLessonRepository = courseLessonRepository;
        this.vocabularyRepository = vocabularyRepository;
        this.grammarRepository = grammarRepository;
        this.exerciseRepository = exerciseRepository;
    }

    @Override
    public PageResponse<CurriculumLessonResponse> getAllCourseLessons(Pageable pageable) {
        Page<CourseLesson> lessons = courseLessonRepository.findAll(pageable);
        List<CurriculumLessonResponse> content = lessons.getContent().stream()
                .map(this::toCourseLessonResponse)
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
    public CurriculumLessonResponse getCourseLessonById(Long id) {
        CourseLesson lesson = courseLessonRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Course lesson not found with id: " + id));
        return toCourseLessonResponse(lesson);
    }

    @Override
    public PageResponse<CurriculumLessonResponse> getCourseLessonsByCourseId(Long courseId, Pageable pageable) {
        Page<CourseLesson> lessons = courseLessonRepository.findByCourseIdWithPagination(courseId, pageable);
        List<CurriculumLessonResponse> content = lessons.getContent().stream()
                .map(this::toCourseLessonResponse)
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

    private CurriculumLessonResponse toCourseLessonResponse(CourseLesson lesson) {
        List<CourseVocabulary> vocabularies = vocabularyRepository.findByCourseLessonId(lesson.getId());
        List<Grammar> grammars = grammarRepository.findByCourseLessonId(lesson.getId());
        List<Exercise> exercises = exerciseRepository.findByCourseLessonId(lesson.getId());
        
        List<VocabularyItemResponse> vocabularyResponses = vocabularies.stream()
                .map(v -> new VocabularyItemResponse(
                    v.getKorean(),
                    v.getVietnamese(),
                    v.getPronunciation(),
                    v.getExample()
                ))
                .collect(Collectors.toList());
        
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
        
        return new CurriculumLessonResponse(
            lesson.getId(),
            lesson.getTitle(),
            lesson.getLevel(),
            lesson.getDuration(),
            lesson.getProgress(),
            lesson.getLessonNumber(),
            lesson.getVideoUrl(),
            vocabularyResponses,
            grammarResponses,
            exerciseResponses
        );
    }
}

