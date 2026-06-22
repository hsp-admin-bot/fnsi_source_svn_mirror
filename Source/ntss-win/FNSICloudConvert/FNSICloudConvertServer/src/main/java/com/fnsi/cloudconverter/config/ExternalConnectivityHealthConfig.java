package com.fnsi.cloudconverter.config;

import org.springframework.boot.health.contributor.Health;
import org.springframework.boot.health.contributor.HealthIndicator;
import org.springframework.boot.health.contributor.Status;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.function.Supplier;

/**
 * 外部依存ごとの HealthIndicator を登録する。
 */
@Configuration
public class ExternalConnectivityHealthConfig {

    private static final Status DEGRADED = new Status("DEGRADED");

    @Bean("converterDbConnectivity")
    public HealthIndicator converterDbConnectivity(ExternalConnectivityChecker checker) {
        return indicator(checker::checkConverterDb);
    }

    @Bean("transitDb4Connectivity")
    public HealthIndicator transitDb4Connectivity(ExternalConnectivityChecker checker) {
        return indicator(checker::checkTransitDb4);
    }

    @Bean("transitDb5Connectivity")
    public HealthIndicator transitDb5Connectivity(ExternalConnectivityChecker checker) {
        return indicator(checker::checkTransitDb5);
    }

    @Bean("transitDb6Connectivity")
    public HealthIndicator transitDb6Connectivity(ExternalConnectivityChecker checker) {
        return indicator(checker::checkTransitDb6);
    }

    @Bean("onlineDb5Connectivity")
    public HealthIndicator onlineDb5Connectivity(ExternalConnectivityChecker checker) {
        return indicator(checker::checkOnlineDb5);
    }

    @Bean("onlineDb6Connectivity")
    public HealthIndicator onlineDb6Connectivity(ExternalConnectivityChecker checker) {
        return indicator(checker::checkOnlineDb6);
    }

    @Bean("onlineAuthDb4Connectivity")
    public HealthIndicator onlineAuthDb4Connectivity(ExternalConnectivityChecker checker) {
        return indicator(checker::checkOnlineAuthDb4);
    }

    @Bean("transitMongoConnectivity")
    public HealthIndicator transitMongoConnectivity(ExternalConnectivityChecker checker) {
        return indicator(checker::checkTransitMongo);
    }

    @Bean("onlineMongoConnectivity")
    public HealthIndicator onlineMongoConnectivity(ExternalConnectivityChecker checker) {
        return indicator(checker::checkOnlineMongo);
    }

    private HealthIndicator indicator(Supplier<ExternalConnectivityChecker.CheckResult> supplier) {
        return () -> {
            ExternalConnectivityChecker.CheckResult result = supplier.get();
            Health.Builder builder = result.available() ? Health.up() : Health.status(DEGRADED);
            return builder.withDetails(result.toHealthDetail()).build();
        };
    }
}
