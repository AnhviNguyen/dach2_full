package org.example.backend.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.Objects;

@Entity
@Table(name = "competition_question_options")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class CompetitionQuestionOption {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "question_id", nullable = false)
    private CompetitionQuestion question;

    @Column(name = "option_text", nullable = false, length = 500)
    private String optionText;

    @Column(name = "option_order", nullable = false)
    private Integer optionOrder;

    @Column(name = "is_correct", nullable = false)
    private Boolean isCorrect = false;

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof CompetitionQuestionOption)) return false;
        CompetitionQuestionOption that = (CompetitionQuestionOption) o;
        return Objects.equals(id, that.id);
    }

    @Override
    public int hashCode() {
        return Objects.hash(id);
    }
}

