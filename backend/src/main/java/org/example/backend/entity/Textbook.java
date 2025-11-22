package org.example.backend.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "textbooks")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Textbook {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
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

    @OneToMany(mappedBy = "textbook", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<TextbookProgress> progresses = new ArrayList<>();

    @OneToMany(mappedBy = "textbook", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<Lesson> lessons = new ArrayList<>();

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

