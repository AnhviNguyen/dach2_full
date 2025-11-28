package org.example.backend.service.impl;

import org.example.backend.dto.*;
import org.example.backend.entity.*;
import org.example.backend.repository.*;
import org.example.backend.service.CurriculumLessonService;
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
public class CurriculumLessonServiceImpl implements CurriculumLessonService {
    private final CurriculumLessonRepository curriculumLessonRepository;
    private final CurriculumVocabularyRepository vocabularyRepository;
    private final GrammarRepository grammarRepository;
    private final ExerciseRepository exerciseRepository;

    public CurriculumLessonServiceImpl(CurriculumLessonRepository curriculumLessonRepository,
                                     CurriculumVocabularyRepository vocabularyRepository,
                                     GrammarRepository grammarRepository,
                                     ExerciseRepository exerciseRepository) {
        this.curriculumLessonRepository = curriculumLessonRepository;
        this.vocabularyRepository = vocabularyRepository;
        this.grammarRepository = grammarRepository;
        this.exerciseRepository = exerciseRepository;
    }

    @Override
    @Transactional(readOnly = true)
    public PageResponse<CurriculumLessonResponse> getAllCurriculumLessons(Pageable pageable) {
        Page<CurriculumLesson> lessons = curriculumLessonRepository.findAllDistinct(pageable);
        
        // Initialize lazy collections and remove duplicates by ID
        Map<Long, CurriculumLesson> uniqueLessonsMap = new LinkedHashMap<>();
        for (CurriculumLesson lesson : lessons.getContent()) {
            // Initialize lazy collections
            Hibernate.initialize(lesson.getVocabularies());
            Hibernate.initialize(lesson.getGrammars());
            Hibernate.initialize(lesson.getExercises());
            Hibernate.initialize(lesson.getCurriculum());
            
            // Remove duplicates by ID (keep first occurrence)
            uniqueLessonsMap.putIfAbsent(lesson.getId(), lesson);
        }
        
        List<CurriculumLessonResponse> content = uniqueLessonsMap.values().stream()
                .map(this::toCurriculumLessonResponse)
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
    public CurriculumLessonResponse getCurriculumLessonById(Long id) {
        CurriculumLesson lesson = curriculumLessonRepository.findByIdWithCollections(id)
                .orElseThrow(() -> new RuntimeException("Curriculum lesson not found with id: " + id));
        return toCurriculumLessonResponse(lesson);
    }

    @Override
    @Transactional(readOnly = true)
    public PageResponse<CurriculumLessonResponse> getCurriculumLessonsByCurriculumId(Long curriculumId, Pageable pageable) {
        Page<CurriculumLesson> lessons = curriculumLessonRepository.findByCurriculumIdDistinct(curriculumId, pageable);
        
        // Initialize lazy collections and remove duplicates by ID
        Map<Long, CurriculumLesson> uniqueLessonsMap = new LinkedHashMap<>();
        for (CurriculumLesson lesson : lessons.getContent()) {
            // Initialize lazy collections
            Hibernate.initialize(lesson.getVocabularies());
            Hibernate.initialize(lesson.getGrammars());
            Hibernate.initialize(lesson.getExercises());
            Hibernate.initialize(lesson.getCurriculum());
            
            // Remove duplicates by ID (keep first occurrence)
            uniqueLessonsMap.putIfAbsent(lesson.getId(), lesson);
        }
        
        List<CurriculumLessonResponse> content = uniqueLessonsMap.values().stream()
                .map(this::toCurriculumLessonResponse)
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

    private CurriculumLessonResponse toCurriculumLessonResponse(CurriculumLesson lesson) {
        // Ensure collections are loaded
        Hibernate.initialize(lesson.getVocabularies());
        Hibernate.initialize(lesson.getGrammars());
        Hibernate.initialize(lesson.getExercises());
        
        List<CurriculumVocabulary> vocabularies = vocabularyRepository.findByCurriculumLessonId(lesson.getId());
        List<Grammar> grammars = grammarRepository.findByCurriculumLessonId(lesson.getId());
        List<Exercise> exercises = exerciseRepository.findByCurriculumLessonId(lesson.getId());
        
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

