package org.example.backend.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.Objects;

@Entity
@Table(name = "blog_tags")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class BlogTag {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "post_id", nullable = false)
    private BlogPost post;

    @Column(nullable = false, length = 100)
    private String tag;

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof BlogTag)) return false;
        BlogTag that = (BlogTag) o;
        return Objects.equals(id, that.id);
    }

    @Override
    public int hashCode() {
        return Objects.hash(id);
    }
}

