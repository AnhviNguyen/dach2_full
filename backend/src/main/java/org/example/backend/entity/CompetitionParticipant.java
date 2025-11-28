package org.example.backend.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.Objects;

@Entity
@Table(name = "competition_participants")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class CompetitionParticipant {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @ManyToOne
    @JoinColumn(name = "competition_id", nullable = false)
    private Competition competition;

    @Column(nullable = false)
    private Integer score = 0;

    @Column
    private Integer rank;

    @Column(name = "submitted_at")
    private LocalDateTime submittedAt;

    @Column(length = 50)
    private String status = "registered";

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof CompetitionParticipant)) return false;
        CompetitionParticipant that = (CompetitionParticipant) o;
        return Objects.equals(id, that.id);
    }

    @Override
    public int hashCode() {
        return Objects.hash(id);
    }
}

