package org.example.backend.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

// FIXED: This entity is deprecated - use CourseEnrollment instead (both track same user-course relationship)
// FIXED: Merged CourseCard functionality into CourseEnrollment
@Entity
@Table(name = "course_cards")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Deprecated
public class CourseCard {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    // FIXED: Added @ManyToOne to Course since entity name contains "Course"
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "course_id", nullable = false)
    private Course course;

    // FIXED: Removed duplicate fields (title, lessons, accentColor) - now accessed
    // via course relationship
    // FIXED: Removed progress - use CourseEnrollment.progress instead
    // FIXED: Removed lessons - use Course.lessons instead
    // FIXED: Removed accentColor - use Course.accentColor instead

    @Column(columnDefinition = "INT DEFAULT 0")
    private Integer completed = 0; // User-specific completed lessons count

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
    }
}
