package org.example.backend.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * CourseVocabulary - Vocabulary trong khóa học với thầy cô
 * 
 * Đây là vocabulary được quản lý bởi giảng viên, gắn liền với các bài học trong Course (khóa học).
 * Vocabulary này thuộc về CourseLesson và được tạo/sửa bởi giảng viên.
 * 
 * Khác biệt với:
 * - CurriculumVocabulary: Vocabulary trong giáo trình (chuẩn hóa, không phụ thuộc vào giảng viên)
 * - VocabularyWord: Vocabulary do người dùng tự tạo và quản lý
 */
@Entity
@Table(name = "course_vocabulary")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class CourseVocabulary {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "course_lesson_id", nullable = false)
    private CourseLesson courseLesson;

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

