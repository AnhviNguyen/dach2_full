package org.example.backend.repository;

import org.example.backend.entity.CompetitionParticipant;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface CompetitionParticipantRepository extends JpaRepository<CompetitionParticipant, Long> {
    Optional<CompetitionParticipant> findByUserIdAndCompetitionId(Long userId, Long competitionId);
    
    List<CompetitionParticipant> findByCompetitionId(Long competitionId);
    
    @Query("SELECT cp FROM CompetitionParticipant cp WHERE cp.competition.id = :competitionId ORDER BY cp.score DESC, cp.submittedAt ASC")
    List<CompetitionParticipant> findByCompetitionIdOrderByScoreDesc(@Param("competitionId") Long competitionId);
    
    @Query("SELECT COUNT(cp) FROM CompetitionParticipant cp WHERE cp.competition.id = :competitionId")
    Long countByCompetitionId(@Param("competitionId") Long competitionId);
}

