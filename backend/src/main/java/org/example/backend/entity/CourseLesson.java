package org.example.backend.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.HashSet;
import java.util.Set;

@Entity
@Table(name = "course_lessons")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class CourseLesson {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "course_id", nullable = false)
    private Course course;

    @Column(nullable = false, length = 500)
    private String title;

    @Column(length = 100)
    private String level;

    @Column(length = 50)
    private String duration;

    @Column(columnDefinition = "INT DEFAULT 0")
    private Integer progress = 0;

    @Column(name = "lesson_number")
    private Integer lessonNumber;

    @Column(name = "video_url", length = 500)
    private String videoUrl;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @OneToMany(mappedBy = "courseLesson", cascade = CascadeType.ALL, orphanRemoval = true, fetch = FetchType.LAZY)
    @OrderBy("id ASC")
    private Set<CourseVocabulary> vocabularies = new HashSet<>();

    @OneToMany(mappedBy = "courseLesson", cascade = CascadeType.ALL, orphanRemoval = true, fetch = FetchType.LAZY)
    @OrderBy("id ASC")
    private Set<Grammar> grammars = new HashSet<>();

    @OneToMany(mappedBy = "courseLesson", cascade = CascadeType.ALL, orphanRemoval = true, fetch = FetchType.LAZY)
    @OrderBy("id ASC")
    private Set<Exercise> exercises = new HashSet<>();

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

