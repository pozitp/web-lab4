package ru.pozitp.web_lab4.service;

import org.springframework.stereotype.Service;
import ru.pozitp.web_lab4.model.FeatureFlag;
import ru.pozitp.web_lab4.repository.FeatureFlagRepository;

import java.util.Optional;
import java.util.Random;

@Service
public class FeatureFlagService {
    private final FeatureFlagRepository featureFlagRepository;
    private final Random random = new Random();

    public FeatureFlagService(FeatureFlagRepository featureFlagRepository) {
        this.featureFlagRepository = featureFlagRepository;
    }

    public boolean isEnabled(String flagName) {
        Optional<FeatureFlag> flag = featureFlagRepository.findByName(flagName);
        return flag.map(FeatureFlag::getEnabled).orElse(false);
    }

    public String getVariant(String flagName, String userId) {
        Optional<FeatureFlag> flagOpt = featureFlagRepository.findByName(flagName);
        if (flagOpt.isEmpty() || !flagOpt.get().getEnabled()) {
            return "default";
        }

        FeatureFlag flag = flagOpt.get();
        int hash = userId.hashCode();
        int value = Math.abs(hash % 100);

        if (value < flag.getVariantAPercentage()) {
            return "variant-a";
        } else if (value < flag.getVariantAPercentage() + flag.getVariantBPercentage()) {
            return "variant-b";
        } else {
            return "default";
        }
    }

    public FeatureFlag createOrUpdate(String name, boolean enabled, int variantAPercentage, int variantBPercentage) {
        Optional<FeatureFlag> existing = featureFlagRepository.findByName(name);
        if (existing.isPresent()) {
            FeatureFlag flag = existing.get();
            flag.setEnabled(enabled);
            flag.setVariantAPercentage(variantAPercentage);
            flag.setVariantBPercentage(variantBPercentage);
            return featureFlagRepository.save(flag);
        } else {
            FeatureFlag flag = new FeatureFlag(null, name, enabled, variantAPercentage, variantBPercentage);
            return featureFlagRepository.save(flag);
        }
    }
}

