package ru.pozitp.web_lab4.dto;

import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.math.BigDecimal;

@Data
public class PointRequest {

    @NotNull
    private Integer x;


    @NotNull
    private BigDecimal y;


    @NotNull
    private Integer r;
}
