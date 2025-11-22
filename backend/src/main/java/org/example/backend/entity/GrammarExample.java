package org.example.backend.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

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
}

