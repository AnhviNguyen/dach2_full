package org.example.backend.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.Objects;

@Entity
@Table(name = "exercise_options")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class ExerciseOption {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "exercise_id", nullable = false)
    private Exercise exercise;

    @Column(name = "option_text", nullable = false, length = 500)
    private String optionText;

    @Column(name = "option_order", nullable = false)
    private Integer optionOrder;

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof ExerciseOption)) return false;
        ExerciseOption that = (ExerciseOption) o;
        return Objects.equals(id, that.id);
    }

    @Override
    public int hashCode() {
        return Objects.hash(id);
    }
}

