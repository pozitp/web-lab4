package ru.pozitp.web_lab4.dto;

import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
public class HitResultResponse {
    private Long id;
    private int x;
    private BigDecimal y;
    private int r;
    private boolean hit;
    private long processingTimeNs;
    private LocalDateTime processedAt;
    private String variant;

    public static HitResultResponse from(ru.pozitp.web_lab4.model.HitResult result) {
        HitResultResponse response = new HitResultResponse();
        response.setId(result.getId());
        response.setX(result.getX());
        response.setY(result.getY());
        response.setR(result.getR());
        response.setHit(result.isHit());
        response.setProcessingTimeNs(result.getProcessingTimeNs());
        response.setProcessedAt(result.getProcessedAt());
        return response;
    }
}
