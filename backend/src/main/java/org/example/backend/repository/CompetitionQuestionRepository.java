package org.example.backend.repository;

import org.example.backend.entity.CompetitionQuestion;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface CompetitionQuestionRepository extends JpaRepository<CompetitionQuestion, Long> {
    List<CompetitionQuestion> findByCompetitionId(Long competitionId);
    
    @Query("SELECT cq FROM CompetitionQuestion cq WHERE cq.competition.id = :competitionId ORDER BY cq.questionOrder ASC")
    List<CompetitionQuestion> findByCompetitionIdOrderByQuestionOrder(@Param("competitionId") Long competitionId);
    
    Optional<CompetitionQuestion> findById(Long id);
}

