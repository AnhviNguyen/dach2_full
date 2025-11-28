package org.example.backend.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.Objects;

/**
 * CurriculumVocabulary - Vocabulary trong giáo trình
 * 
 * Đây là vocabulary được chuẩn hóa theo giáo trình, gắn liền với các bài học trong Curriculum (giáo trình).
 * Vocabulary này thuộc về CurriculumLesson và được quản lý bởi hệ thống (không phụ thuộc vào giảng viên cụ thể).
 * 
 * Khác biệt với:
 * - CourseVocabulary: Vocabulary trong khóa học với thầy cô (do giảng viên quản lý)
 * - VocabularyWord: Vocabulary do người dùng tự tạo và quản lý
 */
@Entity
@Table(name = "curriculum_vocabulary")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class CurriculumVocabulary {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "curriculum_lesson_id", nullable = false)
    private CurriculumLesson curriculumLesson;

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

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof CurriculumVocabulary)) return false;
        CurriculumVocabulary that = (CurriculumVocabulary) o;
        return Objects.equals(id, that.id);
    }

    @Override
    public int hashCode() {
        return Objects.hash(id);
    }
}

