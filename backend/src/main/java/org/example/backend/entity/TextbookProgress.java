package org.example.backend.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.Objects;

@Entity
@Table(name = "textbook_progress", uniqueConstraints = {
        @UniqueConstraint(columnNames = { "user_id", "textbook_id" })
})
@Data
@NoArgsConstructor
@AllArgsConstructor
public class TextbookProgress {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "textbook_id", nullable = false)
    private Textbook textbook;

    @Column(name = "completed_lessons", columnDefinition = "INT DEFAULT 0")
    private Integer completedLessons = 0;

    @Column(name = "is_completed", columnDefinition = "BOOLEAN DEFAULT FALSE")
    private Boolean isCompleted = false;

    @Column(name = "is_locked", columnDefinition = "BOOLEAN DEFAULT FALSE")
    private Boolean isLocked = false;

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof TextbookProgress)) return false;
        TextbookProgress that = (TextbookProgress) o;
        return Objects.equals(id, that.id);
    }

    @Override
    public int hashCode() {
        return Objects.hash(id);
    }
}
