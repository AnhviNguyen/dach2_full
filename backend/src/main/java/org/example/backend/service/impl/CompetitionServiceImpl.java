package org.example.backend.service.impl;

import org.example.backend.dto.*;
import org.example.backend.entity.*;
import org.example.backend.repository.*;
import org.example.backend.service.CompetitionService;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
public class CompetitionServiceImpl implements CompetitionService {
    private final CompetitionRepository competitionRepository;
    private final CompetitionParticipantRepository participantRepository;
    private final CompetitionQuestionRepository questionRepository;
    private final CompetitionSubmissionRepository submissionRepository;
    private final CompetitionCategoryRepository categoryRepository;
    private final UserRepository userRepository;

    public CompetitionServiceImpl(
            CompetitionRepository competitionRepository,
            CompetitionParticipantRepository participantRepository,
            CompetitionQuestionRepository questionRepository,
            CompetitionSubmissionRepository submissionRepository,
            CompetitionCategoryRepository categoryRepository,
            UserRepository userRepository
    ) {
        this.competitionRepository = competitionRepository;
        this.participantRepository = participantRepository;
        this.questionRepository = questionRepository;
        this.submissionRepository = submissionRepository;
        this.categoryRepository = categoryRepository;
        this.userRepository = userRepository;
    }

    @Override
    public PageResponse<CompetitionResponse> getAllCompetitions(Pageable pageable, Long currentUserId) {
        Page<Competition> competitions = competitionRepository.findAll(pageable);
        List<CompetitionResponse> content = competitions.getContent().stream()
                .map(c -> toCompetitionResponse(c, currentUserId))
                .collect(Collectors.toList());

        return new PageResponse<>(
                content,
                competitions.getNumber(),
                competitions.getSize(),
                competitions.getTotalElements(),
                competitions.getTotalPages(),
                competitions.hasNext(),
                competitions.hasPrevious()
        );
    }

    @Override
    public PageResponse<CompetitionResponse> getCompetitionsByStatus(String status, Pageable pageable, Long currentUserId) {
        Page<Competition> competitions = competitionRepository.findByStatus(status, pageable);
        List<CompetitionResponse> content = competitions.getContent().stream()
                .map(c -> toCompetitionResponse(c, currentUserId))
                .collect(Collectors.toList());

        return new PageResponse<>(
                content,
                competitions.getNumber(),
                competitions.getSize(),
                competitions.getTotalElements(),
                competitions.getTotalPages(),
                competitions.hasNext(),
                competitions.hasPrevious()
        );
    }

    @Override
    public CompetitionResponse getCompetitionById(Long id, Long currentUserId) {
        Competition competition = competitionRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Competition not found"));
        return toCompetitionResponse(competition, currentUserId);
    }

    @Override
    public List<CompetitionQuestionResponse> getCompetitionQuestions(Long competitionId) {
        List<CompetitionQuestion> questions = questionRepository.findByCompetitionIdOrderByQuestionOrder(competitionId);
        return questions.stream()
                .map(this::toQuestionResponse)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional
    public CompetitionResultResponse submitCompetition(CompetitionSubmissionRequest request, Long userId) {
        Competition competition = competitionRepository.findById(request.competitionId())
                .orElseThrow(() -> new RuntimeException("Competition not found"));

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        // Delete existing submissions for this competition
        List<CompetitionSubmission> existingSubmissions = submissionRepository
                .findByUserIdAndCompetitionId(userId, request.competitionId());
        submissionRepository.deleteAll(existingSubmissions);

        // Save new submissions
        int correctCount = 0;
        int totalQuestions = 0;
        List<QuestionResultResponse> questionResults = new ArrayList<>();

        for (Map.Entry<Long, String> entry : request.answers().entrySet()) {
            Long questionId = entry.getKey();
            String userAnswer = entry.getValue();

            CompetitionQuestion question = questionRepository.findById(questionId)
                    .orElseThrow(() -> new RuntimeException("Question not found"));

            totalQuestions++;
            boolean isCorrect = checkAnswer(question, userAnswer);

            if (isCorrect) {
                correctCount++;
            }

            CompetitionSubmission submission = new CompetitionSubmission();
            submission.setUser(user);
            submission.setCompetition(competition);
            submission.setQuestion(question);
            submission.setAnswer(userAnswer);
            submission.setIsCorrect(isCorrect);
            submissionRepository.save(submission);

            questionResults.add(new QuestionResultResponse(
                    questionId,
                    userAnswer,
                    question.getCorrectAnswer(),
                    isCorrect
            ));
        }

        // Calculate score
        int score = correctCount * 10; // Assuming 10 points per correct answer

        // Update or create participant
        CompetitionParticipant participant = participantRepository
                .findByUserIdAndCompetitionId(userId, request.competitionId())
                .orElse(new CompetitionParticipant());
        participant.setUser(user);
        participant.setCompetition(competition);
        participant.setScore(score);
        participant.setSubmittedAt(LocalDateTime.now());
        participant.setStatus("completed");
        participantRepository.save(participant);

        // Update ranking
        updateRankings(competition.getId());

        // Get user's rank
        CompetitionParticipant updatedParticipant = participantRepository
                .findByUserIdAndCompetitionId(userId, request.competitionId())
                .orElse(participant);

        double accuracy = totalQuestions > 0 ? (double) correctCount / totalQuestions : 0.0;

        return new CompetitionResultResponse(
                competition.getId(),
                totalQuestions,
                correctCount,
                totalQuestions - correctCount,
                0,
                score,
                updatedParticipant.getRank(),
                accuracy,
                questionResults
        );
    }

    @Override
    @Transactional
    public CompetitionResponse joinCompetition(Long competitionId, Long userId) {
        Competition competition = competitionRepository.findById(competitionId)
                .orElseThrow(() -> new RuntimeException("Competition not found"));

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        // Check if already joined
        if (participantRepository.findByUserIdAndCompetitionId(userId, competitionId).isEmpty()) {
            CompetitionParticipant participant = new CompetitionParticipant();
            participant.setUser(user);
            participant.setCompetition(competition);
            participant.setStatus("registered");
            participantRepository.save(participant);

            // Increment participants count
            competition.setParticipants(competition.getParticipants() + 1);
            competitionRepository.save(competition);
        }

        return toCompetitionResponse(competition, userId);
    }

    @Override
    public CompetitionResultResponse getCompetitionResult(Long competitionId, Long userId) {
        List<CompetitionSubmission> submissions = submissionRepository
                .findByUserIdAndCompetitionId(userId, competitionId);

        int totalQuestions = questionRepository.findByCompetitionId(competitionId).size();
        int correctCount = submissionRepository
                .countCorrectAnswersByUserIdAndCompetitionId(userId, competitionId).intValue();
        int wrongCount = submissions.size() - correctCount;
        int skippedCount = totalQuestions - submissions.size();

        CompetitionParticipant participant = participantRepository
                .findByUserIdAndCompetitionId(userId, competitionId)
                .orElse(null);

        List<QuestionResultResponse> questionResults = submissions.stream()
                .map(s -> new QuestionResultResponse(
                        s.getQuestion().getId(),
                        s.getAnswer(),
                        s.getQuestion().getCorrectAnswer(),
                        s.getIsCorrect()
                ))
                .collect(Collectors.toList());

        double accuracy = totalQuestions > 0 ? (double) correctCount / totalQuestions : 0.0;

        return new CompetitionResultResponse(
                competitionId,
                totalQuestions,
                correctCount,
                wrongCount,
                skippedCount,
                participant != null ? participant.getScore() : 0,
                participant != null ? participant.getRank() : null,
                accuracy,
                questionResults
        );
    }

    private CompetitionResponse toCompetitionResponse(Competition competition, Long currentUserId) {
        boolean isParticipated = currentUserId != null &&
                participantRepository.findByUserIdAndCompetitionId(currentUserId, competition.getId()).isPresent();

        CompetitionParticipant participant = isParticipated
                ? participantRepository.findByUserIdAndCompetitionId(currentUserId, competition.getId()).orElse(null)
                : null;

        String categoryName = null;
        if (competition.getCategoryId() != null) {
            categoryRepository.findByCategoryId(competition.getCategoryId())
                    .ifPresent(cat -> {
                        // categoryName is effectively final in lambda
                    });
            categoryName = categoryRepository.findByCategoryId(competition.getCategoryId())
                    .map(cat -> cat.getName())
                    .orElse(null);
        }

        return new CompetitionResponse(
                competition.getId(),
                competition.getTitle(),
                competition.getDescription(),
                competition.getCategoryId(),
                categoryName,
                competition.getStartDate(),
                competition.getEndDate(),
                competition.getStatus(),
                competition.getPrize(),
                competition.getParticipants(),
                competition.getImage(),
                isParticipated,
                participant != null ? participant.getScore() : null,
                participant != null ? participant.getRank() : null,
                competition.getCreatedAt()
        );
    }

    private CompetitionQuestionResponse toQuestionResponse(CompetitionQuestion question) {
        List<CompetitionQuestionOptionResponse> options = question.getOptions().stream()
                .sorted((a, b) -> Integer.compare(a.getOptionOrder(), b.getOptionOrder()))
                .map(opt -> new CompetitionQuestionOptionResponse(
                        opt.getId(),
                        opt.getOptionText(),
                        opt.getOptionOrder(),
                        opt.getIsCorrect()
                ))
                .collect(Collectors.toList());

        return new CompetitionQuestionResponse(
                question.getId(),
                question.getQuestionText(),
                question.getQuestionType(),
                question.getCorrectAnswer(),
                question.getPoints(),
                question.getQuestionOrder(),
                options
        );
    }

    private boolean checkAnswer(CompetitionQuestion question, String userAnswer) {
        if (question.getCorrectAnswer() != null) {
            return question.getCorrectAnswer().equalsIgnoreCase(userAnswer);
        }

        // Check if user selected the correct option
        return question.getOptions().stream()
                .anyMatch(opt -> opt.getIsCorrect() && opt.getOptionText().equalsIgnoreCase(userAnswer));
    }

    private void updateRankings(Long competitionId) {
        List<CompetitionParticipant> participants = participantRepository
                .findByCompetitionIdOrderByScoreDesc(competitionId);

        for (int i = 0; i < participants.size(); i++) {
            CompetitionParticipant participant = participants.get(i);
            participant.setRank(i + 1);
            participantRepository.save(participant);
        }
    }
}

