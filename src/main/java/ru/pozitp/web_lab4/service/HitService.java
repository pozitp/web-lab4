package ru.pozitp.web_lab4.service;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import ru.pozitp.web_lab4.model.HitResult;
import ru.pozitp.web_lab4.model.User;
import ru.pozitp.web_lab4.repository.HitResultRepository;

import java.math.BigDecimal;
import java.util.List;

@Service
public class HitService {
    private final HitResultRepository hitResultRepository;
    private final AreaChecker areaChecker;

    public HitService(HitResultRepository hitResultRepository, AreaChecker areaChecker) {
        this.hitResultRepository = hitResultRepository;
        this.areaChecker = areaChecker;
    }

    public HitResult checkPoint(int x, BigDecimal y, int r, User user) {
        long startTime = System.nanoTime();
        boolean hit = areaChecker.isHit(new BigDecimal(x), y, new BigDecimal(r));
        long processingTime = System.nanoTime() - startTime;

        HitResult result = new HitResult(x, y, r, hit, processingTime, user);
        return hitResultRepository.save(result);
    }

    public List<HitResult> getHistory(User user) {
        return hitResultRepository.findByUserOrderByProcessedAtDesc(user);
    }

    public Page<HitResult> getHistoryPaged(User user, int page, int size) {
        return hitResultRepository.findByUserOrderByProcessedAtDesc(user, PageRequest.of(page, size));
    }

    @Transactional
    public void clearHistory(User user) {
        hitResultRepository.deleteByUser(user);
    }
}
