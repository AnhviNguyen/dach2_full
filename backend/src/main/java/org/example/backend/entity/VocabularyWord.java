package org.example.backend.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.Objects;

/**
 * VocabularyWord - Từ vựng của người dùng
 * 
 * Đây là từ vựng do người dùng tự tạo và quản lý, thuộc về một VocabularyFolder.
 * Người dùng có thể thêm, sửa, xóa các từ vựng này để học tập cá nhân.
 * 
 * Khác biệt với:
 * - CourseVocabulary: Vocabulary trong khóa học với thầy cô (do giảng viên quản lý)
 * - CurriculumVocabulary: Vocabulary trong giáo trình (chuẩn hóa)
 * 
 * VocabularyWord thuộc về người dùng, không gắn với lesson nào.
 */
@Entity
@Table(name = "vocabulary_words")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class VocabularyWord {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "folder_id", nullable = false)
    private VocabularyFolder folder;

    @Column(nullable = false, length = 500)
    private String korean;

    @Column(nullable = false, length = 500)
    private String vietnamese;

    @Column(length = 500)
    private String pronunciation;

    @Column(columnDefinition = "TEXT")
    private String example;

    @Column(name = "is_learned", columnDefinition = "BOOLEAN DEFAULT FALSE")
    private Boolean isLearned = false;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at", nullable = false)
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
        if (!(o instanceof VocabularyWord)) return false;
        VocabularyWord that = (VocabularyWord) o;
        return Objects.equals(id, that.id);
    }

    @Override
    public int hashCode() {
        return Objects.hash(id);
    }
}

