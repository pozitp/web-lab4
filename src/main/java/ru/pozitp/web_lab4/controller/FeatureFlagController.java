package ru.pozitp.web_lab4.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import ru.pozitp.web_lab4.model.FeatureFlag;
import ru.pozitp.web_lab4.service.FeatureFlagService;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/feature-flags")
public class FeatureFlagController {
    private final FeatureFlagService featureFlagService;

    public FeatureFlagController(FeatureFlagService featureFlagService) {
        this.featureFlagService = featureFlagService;
    }

    @GetMapping("/{flagName}")
    public ResponseEntity<Map<String, Object>> getVariant(@PathVariable String flagName, Authentication auth) {
        String userId = auth != null ? auth.getName() : "anonymous";
        String variant = featureFlagService.getVariant(flagName, userId);
        boolean enabled = featureFlagService.isEnabled(flagName);

        Map<String, Object> response = new HashMap<>();
        response.put("enabled", enabled);
        response.put("variant", variant);
        response.put("flagName", flagName);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/{flagName}")
    public ResponseEntity<FeatureFlag> createOrUpdate(
            @PathVariable String flagName,
            @RequestBody Map<String, Object> config) {
        boolean enabled = (Boolean) config.getOrDefault("enabled", true);
        int variantAPercentage = (Integer) config.getOrDefault("variantAPercentage", 50);
        int variantBPercentage = (Integer) config.getOrDefault("variantBPercentage", 50);

        FeatureFlag flag = featureFlagService.createOrUpdate(flagName, enabled, variantAPercentage, variantBPercentage);
        return ResponseEntity.ok(flag);
    }
}

