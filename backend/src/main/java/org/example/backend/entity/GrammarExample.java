package org.example.backend.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.Objects;

@Entity
@Table(name = "grammar_examples")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class GrammarExample {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "grammar_id", nullable = false)
    private Grammar grammar;

    @Column(name = "example_text", nullable = false, columnDefinition = "TEXT")
    private String exampleText;

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof GrammarExample)) return false;
        GrammarExample that = (GrammarExample) o;
        return Objects.equals(id, that.id);
    }

    @Override
    public int hashCode() {
        return Objects.hash(id);
    }
}

