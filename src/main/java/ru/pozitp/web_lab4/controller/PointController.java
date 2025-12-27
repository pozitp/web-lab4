package ru.pozitp.web_lab4.controller;

import jakarta.validation.Valid;
import org.springframework.data.domain.Page;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import ru.pozitp.web_lab4.dto.HitResultResponse;
import ru.pozitp.web_lab4.dto.PagedResponse;
import ru.pozitp.web_lab4.dto.PointRequest;
import ru.pozitp.web_lab4.model.HitResult;
import ru.pozitp.web_lab4.model.User;
import ru.pozitp.web_lab4.service.FeatureFlagService;
import ru.pozitp.web_lab4.service.HitService;
import ru.pozitp.web_lab4.service.UserService;

@RestController
@RequestMapping("/api/points")
public class PointController {
    private final HitService hitService;
    private final UserService userService;
    private final FeatureFlagService featureFlagService;

    public PointController(HitService hitService, UserService userService, FeatureFlagService featureFlagService) {
        this.hitService = hitService;
        this.userService = userService;
        this.featureFlagService = featureFlagService;
    }

    @PostMapping
    public ResponseEntity<HitResultResponse> checkPoint(@Valid @RequestBody PointRequest request, Authentication auth) {
        User user = userService.findByUsername(auth.getName());
        String variant = featureFlagService.getVariant("ui-variant", user.getUsername());
        HitResult result = hitService.checkPoint(request.getX(), request.getY(), request.getR(), user);
        HitResultResponse response = HitResultResponse.from(result);
        response.setVariant(variant);
        return ResponseEntity.ok(response);
    }

    @GetMapping
    public ResponseEntity<PagedResponse<HitResultResponse>> getHistory(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            Authentication auth) {
        User user = userService.findByUsername(auth.getName());
        Page<HitResult> pageResult = hitService.getHistoryPaged(user, page, size);
        Page<HitResultResponse> responsePage = pageResult.map(HitResultResponse::from);
        return ResponseEntity.ok(new PagedResponse<>(
                responsePage.getContent(),
                responsePage.getNumber(),
                responsePage.getTotalPages(),
                responsePage.getTotalElements()
        ));
    }

    @DeleteMapping
    public ResponseEntity<Void> clearHistory(Authentication auth) {
        User user = userService.findByUsername(auth.getName());
        hitService.clearHistory(user);
        return ResponseEntity.ok().build();
    }
}
