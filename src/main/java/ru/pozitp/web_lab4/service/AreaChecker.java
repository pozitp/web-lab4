package ru.pozitp.web_lab4.service;

import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.math.MathContext;
import java.math.RoundingMode;

@Service
public class AreaChecker {
    private static final MathContext MC = new MathContext(30, RoundingMode.HALF_UP);
    private static final BigDecimal TWO = BigDecimal.valueOf(2);

        public boolean isHit(BigDecimal x, BigDecimal y, BigDecimal r) {
        boolean isNegativeR = r.compareTo(BigDecimal.ZERO) < 0;
        BigDecimal absR = r.abs(MC);
        BigDecimal half = absR.divide(TWO, MC);
        BigDecimal mx = x;
        BigDecimal my = y;
        if (isNegativeR) {
            mx = x.negate(MC);
            my = y.negate(MC);
        }
        boolean rectangle = mx.compareTo(BigDecimal.ZERO) >= 0
            && mx.compareTo(absR) <= 0
            && my.compareTo(BigDecimal.ZERO) >= 0
            && my.compareTo(half) <= 0;
        BigDecimal lineY = absR.add(mx.multiply(TWO, MC), MC);
        boolean triangle = mx.compareTo(BigDecimal.ZERO) <= 0
            && mx.compareTo(half.negate()) >= 0
            && my.compareTo(BigDecimal.ZERO) >= 0
            && my.compareTo(lineY) <= 0;
        BigDecimal distanceSquared = mx.multiply(mx, MC).add(my.multiply(my, MC), MC);
        boolean quarterCircle = mx.compareTo(BigDecimal.ZERO) >= 0
            && mx.compareTo(half) <= 0
            && my.compareTo(BigDecimal.ZERO) <= 0
            && my.compareTo(half.negate()) >= 0
            && distanceSquared.compareTo(half.pow(2, MC)) <= 0;
        return rectangle || triangle || quarterCircle;
        }
}
