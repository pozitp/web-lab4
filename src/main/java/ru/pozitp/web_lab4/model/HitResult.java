package ru.pozitp.web_lab4.model;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "hit_results_lab4")
@Data
@NoArgsConstructor
public class HitResult {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private int x;

    @Column(nullable = false, precision = 38, scale = 30)
    private BigDecimal y;

    @Column(nullable = false)
    private int r;

    @Column(nullable = false)
    private boolean hit;

    @Column(name = "processing_time_ns", nullable = false)
    private long processingTimeNs;

    @Column(name = "processed_at", nullable = false)
    private LocalDateTime processedAt;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    public HitResult(int x, BigDecimal y, int r, boolean hit, long processingTimeNs, User user) {
        this.x = x;
        this.y = y;
        this.r = r;
        this.hit = hit;
        this.processingTimeNs = processingTimeNs;
        this.user = user;
    }

    @PrePersist
    public void fillTimestamp() {
        if (processedAt == null) {
            processedAt = LocalDateTime.now();
        }
    }
}
