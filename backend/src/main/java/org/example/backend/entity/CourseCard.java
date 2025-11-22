package org.example.backend.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "course_cards")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class CourseCard {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(nullable = false, length = 500)
    private String title;

    @Column(columnDefinition = "DECIMAL(5,4) DEFAULT 0.0")
    private Double progress = 0.0;

    @Column(columnDefinition = "INT DEFAULT 0")
    private Integer lessons = 0;

    @Column(columnDefinition = "INT DEFAULT 0")
    private Integer completed = 0;

    @Column(name = "accent_color", length = 50)
    private String accentColor;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
    }
}

