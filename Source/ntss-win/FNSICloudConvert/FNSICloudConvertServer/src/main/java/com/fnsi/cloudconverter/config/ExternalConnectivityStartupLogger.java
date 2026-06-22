package com.fnsi.cloudconverter.config;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.event.EventListener;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.atomic.AtomicBoolean;

/**
 * 起動完了時に外部依存の疎通状態をログへ出力する。
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class ExternalConnectivityStartupLogger {

    private final ExternalConnectivityChecker checker;
    private final Map<String, ExternalConnectivityChecker.CheckResult> lastResults = new LinkedHashMap<>();
    private final AtomicBoolean fullyAvailableLogged = new AtomicBoolean(false);

    @EventListener(ApplicationReadyEvent.class)
    public void logStartupConnectivity() {
        Map<String, ExternalConnectivityChecker.CheckResult> results = checker.checkAll();
        synchronized (lastResults) {
            lastResults.clear();
            lastResults.putAll(results);
        }
        fullyAvailableLogged.set(false);
        logSnapshot(results, "起動時疎通確認完了");
    }

    @Scheduled(
            initialDelayString = "${connectivity.check.log-initial-delay-ms:5000}",
            fixedDelayString = "${connectivity.check.log-interval-ms:5000}"
    )
    public void logConnectivityChanges() {
        Map<String, ExternalConnectivityChecker.CheckResult> current = checker.checkAll();
        List<String> remainingDown = new ArrayList<>();
        boolean hasChange = false;
        boolean allUp = true;

        synchronized (lastResults) {
            if (lastResults.isEmpty()) {
                lastResults.putAll(current);
                if (current.values().stream().allMatch(ExternalConnectivityChecker.CheckResult::available)) {
                    fullyAvailableLogged.set(true);
                }
                return;
            }

            for (Map.Entry<String, ExternalConnectivityChecker.CheckResult> entry : current.entrySet()) {
                String name = entry.getKey();
                ExternalConnectivityChecker.CheckResult currentResult = entry.getValue();
                ExternalConnectivityChecker.CheckResult previousResult = lastResults.get(name);

                if (!currentResult.available()) {
                    allUp = false;
                    remainingDown.add(name);
                }

                if (previousResult == null || previousResult.available() != currentResult.available()) {
                    hasChange = true;
                    logTransition(name, previousResult, currentResult);
                }
            }

            lastResults.clear();
            lastResults.putAll(current);
        }

        if (!hasChange) {
            return;
        }

        if (allUp) {
            if (fullyAvailableLogged.compareAndSet(false, true)) {
                log.info("[CONNECTIVITY] すべての外部依存が利用可能になりました。通常操作を開始できます");
            }
        } else {
            fullyAvailableLogged.set(false);
            log.warn("[CONNECTIVITY] まだ未接続の依存があります: {}", String.join(", ", remainingDown));
        }
    }

    private void logSnapshot(Map<String, ExternalConnectivityChecker.CheckResult> results, String headline) {
        int upCount = 0;
        for (Map.Entry<String, ExternalConnectivityChecker.CheckResult> entry : results.entrySet()) {
            ExternalConnectivityChecker.CheckResult result = entry.getValue();
            if (result.available()) {
                upCount++;
                log.info("[CONNECTIVITY] {} {} ({})", entry.getKey(), result.statusLabel(), result.type());
            } else {
                log.warn("[CONNECTIVITY] {} {} ({}) - {}", entry.getKey(), result.statusLabel(), result.type(), result.summary());
            }
        }

        int total = results.size();
        int downCount = total - upCount;
        if (downCount == 0) {
            fullyAvailableLogged.set(true);
            log.info("[CONNECTIVITY] {}: {}/{} すべて利用可能です。通常操作を開始できます", headline, upCount, total);
        } else {
            log.warn("[CONNECTIVITY] {}: up={}, down={}。サービス起動は継続します", headline, upCount, downCount);
        }
    }

    private void logTransition(
            String name,
            ExternalConnectivityChecker.CheckResult previous,
            ExternalConnectivityChecker.CheckResult current) {
        String previousLabel = previous == null ? "UNKNOWN" : previous.statusLabel();
        if (current.available()) {
            log.info("[CONNECTIVITY] {} {} -> {} ({})", name, previousLabel, current.statusLabel(), current.type());
        } else {
            log.warn("[CONNECTIVITY] {} {} -> {} ({}) - {}", name, previousLabel, current.statusLabel(), current.type(), current.summary());
        }
    }
}
