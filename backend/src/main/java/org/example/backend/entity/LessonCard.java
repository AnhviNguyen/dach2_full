package org.example.backend.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "lesson_cards")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class LessonCard {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    // FIXED: Added @ManyToOne to Lesson since entity name contains "Lesson"
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "lesson_id", nullable = false)
    private Lesson lesson;

    // FIXED: Removed duplicate title field - now accessed via lesson.title

    @Column(length = 50)
    private String date;

    @Column(length = 100)
    private String tag;

    @Column(name = "accent_color", length = 50)
    private String accentColor;

    @Column(name = "background_color", length = 50)
    private String backgroundColor;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
    }
}

