package org.example.backend.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "skill_progress")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class SkillProgress {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(nullable = false, length = 100)
    private String label;

    @Column(columnDefinition = "DECIMAL(5,4) DEFAULT 0.0")
    private Double percent = 0.0;

    @Column(length = 50)
    private String color;
}

