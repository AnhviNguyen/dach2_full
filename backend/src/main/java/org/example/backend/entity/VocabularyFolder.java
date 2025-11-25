package org.example.backend.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * VocabularyFolder - Thư mục từ vựng của người dùng
 * 
 * Đây là vocabulary do người dùng tự tạo và quản lý. Người dùng có thể tạo các thư mục (folders)
 * và thêm các từ vựng (VocabularyWord) vào đó để học tập cá nhân.
 * 
 * Khác biệt với:
 * - CourseVocabulary: Vocabulary trong khóa học với thầy cô (do giảng viên quản lý, gắn với CourseLesson)
 * - CurriculumVocabulary: Vocabulary trong giáo trình (chuẩn hóa, gắn với CurriculumLesson)
 * 
 * VocabularyFolder và VocabularyWord thuộc về người dùng, không gắn với lesson nào.
 */
@Entity
@Table(name = "vocabulary_folders")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class VocabularyFolder {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(nullable = false, length = 255)
    private String name;

    @Column(length = 10)
    private String icon = "📁";

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

    @OneToMany(mappedBy = "folder", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<VocabularyWord> words = new ArrayList<>();

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

