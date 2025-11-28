package org.example.backend.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.HashSet;
import java.util.Objects;
import java.util.Set;

@Entity
@Table(name = "competition_questions")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class CompetitionQuestion {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "competition_id", nullable = false)
    private Competition competition;

    @Column(name = "question_text", nullable = false, columnDefinition = "TEXT")
    private String questionText;

    @Column(name = "question_type", length = 50)
    private String questionType;

    @Column(name = "correct_answer", length = 500)
    private String correctAnswer;

    @Column(nullable = false)
    private Integer points = 1;

    @Column(name = "question_order")
    private Integer questionOrder;

    @OneToMany(mappedBy = "question", cascade = CascadeType.ALL, orphanRemoval = true)
    @OrderBy("id ASC")
    private Set<CompetitionQuestionOption> options = new HashSet<>();

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof CompetitionQuestion)) return false;
        CompetitionQuestion that = (CompetitionQuestion) o;
        return Objects.equals(id, that.id);
    }

    @Override
    public int hashCode() {
        return Objects.hash(id);
    }
}

