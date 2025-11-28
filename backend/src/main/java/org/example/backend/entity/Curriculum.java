package org.example.backend.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.HashSet;
import java.util.Set;

@Entity
@Table(name = "curriculum")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Curriculum {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Long id;

    @Column(name = "book_number", nullable = false, unique = true)
    private Integer bookNumber;

    @Column(nullable = false, length = 500)
    private String title;

    @Column(length = 255)
    private String subtitle;

    @Column(name = "total_lessons", columnDefinition = "INT DEFAULT 0")
    private Integer totalLessons = 0;

    @Column(length = 50)
    private String color;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @OneToMany(mappedBy = "curriculum", cascade = CascadeType.ALL, orphanRemoval = true, fetch = FetchType.LAZY)
    @OrderBy("id ASC")
    private Set<CurriculumProgress> progresses = new HashSet<>();

    @OneToMany(mappedBy = "curriculum", cascade = CascadeType.ALL, orphanRemoval = true, fetch = FetchType.LAZY)
    @OrderBy("id ASC")
    private Set<CurriculumLesson> lessons = new HashSet<>();

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

