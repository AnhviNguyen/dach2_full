package org.example.backend.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "course_enrollments", uniqueConstraints = {
    @UniqueConstraint(columnNames = {"user_id", "course_id"})
})
@Data
@NoArgsConstructor
@AllArgsConstructor
public class CourseEnrollment {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "course_id", nullable = false)
    private Course course;

    @Column(columnDefinition = "DECIMAL(5,4) DEFAULT 0.0")
    private Double progress = 0.0;

    @Column(name = "is_enrolled", columnDefinition = "BOOLEAN DEFAULT TRUE")
    private Boolean isEnrolled = true;

    // FIXED: Added fields from CourseCard to merge user-course relationship tracking
    // FIXED: Both CourseCard and CourseEnrollment track same relationship - merged into CourseEnrollment
    @Column(columnDefinition = "INT DEFAULT 0")
    private Integer completedLessons = 0; // User-specific completed lessons count

    @Column(name = "enrolled_at")
    private LocalDateTime enrolledAt;

    @PrePersist
    protected void onCreate() {
        enrolledAt = LocalDateTime.now();
    }
}

