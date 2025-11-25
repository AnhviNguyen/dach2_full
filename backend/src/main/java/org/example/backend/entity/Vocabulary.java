package org.example.backend.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * @deprecated This entity is deprecated. Use CurriculumVocabulary instead.
 * The old vocabulary table is no longer used in the new schema.
 */
@Deprecated
@Entity
@Table(name = "vocabulary")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Vocabulary {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Long id;

    // NOTE: Relationship removed - Vocabulary entity is deprecated
    // Use CurriculumVocabulary instead which references CurriculumLesson

    @Column(nullable = false, length = 500)
    private String korean;

    @Column(nullable = false, length = 500)
    private String vietnamese;

    @Column(length = 500)
    private String pronunciation;

    @Column(columnDefinition = "TEXT")
    private String example;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
}

