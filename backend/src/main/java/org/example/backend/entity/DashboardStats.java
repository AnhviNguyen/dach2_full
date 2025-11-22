package org.example.backend.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "dashboard_stats", uniqueConstraints = {
    @UniqueConstraint(columnNames = {"user_id"})
})
@Data
@NoArgsConstructor
@AllArgsConstructor
public class DashboardStats {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false, unique = true)
    private User user;

    @Column(name = "total_courses", columnDefinition = "INT DEFAULT 0")
    private Integer totalCourses = 0;

    @Column(name = "completed_courses", columnDefinition = "INT DEFAULT 0")
    private Integer completedCourses = 0;

    @Column(name = "total_videos", columnDefinition = "INT DEFAULT 0")
    private Integer totalVideos = 0;

    @Column(name = "watched_videos", columnDefinition = "INT DEFAULT 0")
    private Integer watchedVideos = 0;

    @Column(name = "total_exams", columnDefinition = "INT DEFAULT 0")
    private Integer totalExams = 0;

    @Column(name = "completed_exams", columnDefinition = "INT DEFAULT 0")
    private Integer completedExams = 0;

    @Column(name = "total_watch_time", length = 50)
    private String totalWatchTime;

    @Column(name = "completed_watch_time", length = 50)
    private String completedWatchTime;

    @Column(name = "last_access")
    private LocalDateTime lastAccess;

    @Column(name = "end_date")
    private LocalDate endDate;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @PrePersist
    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
}

