package org.example.backend.repository;

import org.example.backend.entity.Material;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface MaterialRepository extends JpaRepository<Material, Long> {
    Page<Material> findAll(Pageable pageable);

    Optional<Material> findById(Long id);

    @Query("SELECT m FROM Material m WHERE " +
           "(:level IS NULL OR m.level = :level) AND " +
           "(:skill IS NULL OR m.skill = :skill) AND " +
           "(:type IS NULL OR m.type = :type) AND " +
           "(:searchQuery IS NULL OR LOWER(m.title) LIKE LOWER(CONCAT('%', :searchQuery, '%')) OR " +
           "LOWER(m.description) LIKE LOWER(CONCAT('%', :searchQuery, '%')))")
    Page<Material> findByFilters(
            @Param("level") String level,
            @Param("skill") String skill,
            @Param("type") String type,
            @Param("searchQuery") String searchQuery,
            Pageable pageable
    );

    List<Material> findByIsFeaturedTrue();

    @Query("SELECT COUNT(m) FROM Material m")
    Long countAll();
}

