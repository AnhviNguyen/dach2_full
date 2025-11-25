package org.example.backend.repository;

import org.example.backend.entity.CompetitionSubmission;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface CompetitionSubmissionRepository extends JpaRepository<CompetitionSubmission, Long> {
    @Query("SELECT cs FROM CompetitionSubmission cs WHERE cs.user.id = :userId AND cs.competition.id = :competitionId")
    List<CompetitionSubmission> findByUserIdAndCompetitionId(@Param("userId") Long userId, @Param("competitionId") Long competitionId);
    
    @Query("SELECT cs FROM CompetitionSubmission cs WHERE cs.user.id = :userId AND cs.competition.id = :competitionId AND cs.question.id = :questionId")
    Optional<CompetitionSubmission> findByUserIdAndCompetitionIdAndQuestionId(
            @Param("userId") Long userId,
            @Param("competitionId") Long competitionId,
            @Param("questionId") Long questionId
    );
    
    @Query("SELECT COUNT(cs) FROM CompetitionSubmission cs WHERE cs.user.id = :userId AND cs.competition.id = :competitionId AND cs.isCorrect = true")
    Long countCorrectAnswersByUserIdAndCompetitionId(@Param("userId") Long userId, @Param("competitionId") Long competitionId);
}

