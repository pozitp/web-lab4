package ru.pozitp.web_lab4.repository;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import ru.pozitp.web_lab4.model.HitResult;
import ru.pozitp.web_lab4.model.User;

import java.util.List;

public interface HitResultRepository extends JpaRepository<HitResult, Long> {
    List<HitResult> findByUserOrderByProcessedAtDesc(User user);
    Page<HitResult> findByUserOrderByProcessedAtDesc(User user, Pageable pageable);
    void deleteByUser(User user);
}
