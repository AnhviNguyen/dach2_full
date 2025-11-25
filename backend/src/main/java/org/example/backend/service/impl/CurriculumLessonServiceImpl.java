package org.example.backend.service.impl;

import org.example.backend.dto.*;
import org.example.backend.entity.*;
import org.example.backend.repository.*;
import org.example.backend.service.CurriculumLessonService;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
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
    public PageResponse<CurriculumLessonResponse> getAllCurriculumLessons(Pageable pageable) {
        Page<CurriculumLesson> lessons = curriculumLessonRepository.findAll(pageable);
        List<CurriculumLessonResponse> content = lessons.getContent().stream()
                .map(this::toCurriculumLessonResponse)
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
    public CurriculumLessonResponse getCurriculumLessonById(Long id) {
        CurriculumLesson lesson = curriculumLessonRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Curriculum lesson not found with id: " + id));
        return toCurriculumLessonResponse(lesson);
    }

    @Override
    public PageResponse<CurriculumLessonResponse> getCurriculumLessonsByCurriculumId(Long curriculumId, Pageable pageable) {
        Page<CurriculumLesson> lessons = curriculumLessonRepository.findByCurriculumIdWithPagination(curriculumId, pageable);
        List<CurriculumLessonResponse> content = lessons.getContent().stream()
                .map(this::toCurriculumLessonResponse)
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

    private CurriculumLessonResponse toCurriculumLessonResponse(CurriculumLesson lesson) {
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

