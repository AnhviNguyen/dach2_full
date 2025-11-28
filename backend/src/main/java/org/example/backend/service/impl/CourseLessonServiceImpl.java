package org.example.backend.service.impl;

import org.example.backend.dto.*;
import org.example.backend.entity.*;
import org.example.backend.repository.*;
import org.example.backend.service.CourseLessonService;
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
    @Transactional(readOnly = true)
    public PageResponse<CurriculumLessonResponse> getAllCourseLessons(Pageable pageable) {
        Page<CourseLesson> lessons = courseLessonRepository.findAllDistinct(pageable);
        
        // Initialize lazy collections and remove duplicates by ID
        Map<Long, CourseLesson> uniqueLessonsMap = new LinkedHashMap<>();
        for (CourseLesson lesson : lessons.getContent()) {
            // Initialize lazy collections
            Hibernate.initialize(lesson.getVocabularies());
            Hibernate.initialize(lesson.getGrammars());
            Hibernate.initialize(lesson.getExercises());
            Hibernate.initialize(lesson.getCourse());
            
            // Remove duplicates by ID (keep first occurrence)
            uniqueLessonsMap.putIfAbsent(lesson.getId(), lesson);
        }
        
        List<CurriculumLessonResponse> content = uniqueLessonsMap.values().stream()
                .map(this::toCourseLessonResponse)
                .collect(Collectors.toList());
        
        // Recalculate total elements based on unique lessons
        long uniqueTotal = uniqueLessonsMap.size();
        
        return new PageResponse<>(
            content,
            lessons.getNumber(),
            lessons.getSize(),
            uniqueTotal,
            (int) Math.ceil((double) uniqueTotal / lessons.getSize()),
            lessons.hasNext(),
            lessons.hasPrevious()
        );
    }

    @Override
    public CurriculumLessonResponse getCourseLessonById(Long id) {
        CourseLesson lesson = courseLessonRepository.findByIdWithCollections(id)
                .orElseThrow(() -> new RuntimeException("Course lesson not found with id: " + id));
        return toCourseLessonResponse(lesson);
    }

    @Override
    @Transactional(readOnly = true)
    public PageResponse<CurriculumLessonResponse> getCourseLessonsByCourseId(Long courseId, Pageable pageable) {
        Page<CourseLesson> lessons = courseLessonRepository.findByCourseIdDistinct(courseId, pageable);
        
        // Initialize lazy collections and remove duplicates by ID
        Map<Long, CourseLesson> uniqueLessonsMap = new LinkedHashMap<>();
        for (CourseLesson lesson : lessons.getContent()) {
            // Initialize lazy collections
            Hibernate.initialize(lesson.getVocabularies());
            Hibernate.initialize(lesson.getGrammars());
            Hibernate.initialize(lesson.getExercises());
            Hibernate.initialize(lesson.getCourse());
            
            // Remove duplicates by ID (keep first occurrence)
            uniqueLessonsMap.putIfAbsent(lesson.getId(), lesson);
        }
        
        List<CurriculumLessonResponse> content = uniqueLessonsMap.values().stream()
                .map(this::toCourseLessonResponse)
                .collect(Collectors.toList());
        
        // Recalculate total elements based on unique lessons
        long uniqueTotal = uniqueLessonsMap.size();
        
        return new PageResponse<>(
            content,
            lessons.getNumber(),
            lessons.getSize(),
            uniqueTotal,
            (int) Math.ceil((double) uniqueTotal / lessons.getSize()),
            lessons.hasNext(),
            lessons.hasPrevious()
        );
    }

    private CurriculumLessonResponse toCourseLessonResponse(CourseLesson lesson) {
        // Ensure collections are loaded
        Hibernate.initialize(lesson.getVocabularies());
        Hibernate.initialize(lesson.getGrammars());
        Hibernate.initialize(lesson.getExercises());
        
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
                .distinct()
                .collect(Collectors.toList());
        
        List<GrammarItemResponse> grammarResponses = grammars.stream()
                .map(g -> {
                    Hibernate.initialize(g.getExamples());
                    List<String> examples = g.getExamples().stream()
                            .map(GrammarExample::getExampleText)
                            .distinct()
                            .collect(Collectors.toList());
                    return new GrammarItemResponse(
                        g.getTitle(),
                        g.getExplanation(),
                        examples
                    );
                })
                .distinct()
                .collect(Collectors.toList());
        
        List<ExerciseItemResponse> exerciseResponses = exercises.stream()
                .map(e -> {
                    Hibernate.initialize(e.getOptions());
                    List<String> options = e.getOptions().stream()
                            .map(ExerciseOption::getOptionText)
                            .distinct()
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
                .distinct()
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

