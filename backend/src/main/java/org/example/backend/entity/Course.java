package org.example.backend.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "courses")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Course {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 500)
    private String title;

    @Column(nullable = false, length = 255)
    private String instructor;

    @Column(nullable = false, length = 100)
    private String level;

    @Column(columnDefinition = "DECIMAL(3,2) DEFAULT 0.0")
    private Double rating = 0.0;

    @Column(columnDefinition = "INT DEFAULT 0")
    private Integer students = 0;

    @Column(columnDefinition = "INT DEFAULT 0")
    private Integer lessons = 0;

    @Column(name = "duration_start")
    private LocalDate durationStart;

    @Column(name = "duration_end")
    private LocalDate durationEnd;

    @Column(length = 100)
    private String price;

    @Column(length = 500)
    private String image;

    @Column(name = "accent_color", length = 50)
    private String accentColor;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @OneToMany(mappedBy = "course", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<CourseEnrollment> enrollments = new ArrayList<>();

    @OneToMany(mappedBy = "course", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<Lesson> courseLessons = new ArrayList<>();

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

