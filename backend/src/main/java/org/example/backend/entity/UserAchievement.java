package org.example.backend.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "user_achievements", uniqueConstraints = {
    @UniqueConstraint(columnNames = {"user_id", "achievement_id"})
})
@Data
@NoArgsConstructor
@AllArgsConstructor
public class UserAchievement {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "achievement_id", nullable = false)
    private Achievement achievement;

    @Column(name = "current_count", columnDefinition = "INT DEFAULT 0")
    private Integer currentCount = 0;

    @Column(name = "is_completed", columnDefinition = "BOOLEAN DEFAULT FALSE")
    private Boolean isCompleted = false;

    @Column(columnDefinition = "DECIMAL(5,4) DEFAULT 0.0")
    private Double progress = 0.0;

    @Column(name = "completed_at")
    private LocalDateTime completedAt;
}

