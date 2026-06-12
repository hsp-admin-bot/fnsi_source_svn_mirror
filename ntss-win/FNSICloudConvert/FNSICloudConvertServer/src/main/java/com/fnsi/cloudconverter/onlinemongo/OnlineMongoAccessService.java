package com.fnsi.cloudconverter.onlinemongo;

import com.fnsi.cloudconverter.clear.online.mongo.OnlineMongoClearService;
import com.fnsi.cloudconverter.config.ExternalConnectivityChecker;
import com.fnsi.cloudconverter.config.OnlineMongoConnectionInfo;
import com.fnsi.cloudconverter.migration.mongo.MongoDumpConfig;
import com.fnsi.cloudconverter.migration.mongo.MongoToolProfile;
import com.mongodb.client.MongoClient;
import lombok.extern.slf4j.Slf4j;
import org.bson.Document;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.concurrent.atomic.AtomicReference;

@Slf4j
@Service
public class OnlineMongoAccessService {

    private final MongoDumpConfig mongoDumpConfig;
    private final OnlineMongoClearService onlineMongoClearService;
    private final MongoClient onlineMongoClient;
    private final OnlineMongoConnectionInfo onlineMongoConnectionInfo;
    private final DocDb4HelperRunner helperRunner;

    @Value("${online.data.mongodb.driver-mode:auto}")
    private String configuredMode;

    @Value("${connectivity.check.timeout-ms:2000}")
    private int timeoutMs;

    private final AtomicReference<OnlineMongoAccessMode> autoResolvedMode = new AtomicReference<>();

    public OnlineMongoAccessService(
            MongoDumpConfig mongoDumpConfig,
            OnlineMongoClearService onlineMongoClearService,
            @Qualifier("onlineMongoClient") MongoClient onlineMongoClient,
            OnlineMongoConnectionInfo onlineMongoConnectionInfo,
            DocDb4HelperRunner helperRunner) {
        this.mongoDumpConfig = mongoDumpConfig;
        this.onlineMongoClearService = onlineMongoClearService;
        this.onlineMongoClient = onlineMongoClient;
        this.onlineMongoConnectionInfo = onlineMongoConnectionInfo;
        this.helperRunner = helperRunner;
    }

    public ExternalConnectivityChecker.CheckResult checkConnectivity() {
        try {
            OnlineMongoAccessMode mode = OnlineMongoAccessMode.from(configuredMode);
            return switch (mode) {
                case MODERN -> modernConnectivity();
                case DOCDB4 -> helperConnectivity();
                case AUTO -> autoConnectivity();
            };
        } catch (Exception ex) {
            return ExternalConnectivityChecker.CheckResult.down("mongo", summarize(ex));
        }
    }

    public void clearFacilityData(List<String> facilityCodes) {
        OnlineMongoAccessMode mode = resolveModeForOperation();
        if (mode == OnlineMongoAccessMode.DOCDB4) {
            DocDb4HelperRunner.ClearResponse response = helperRunner.clearFacilityData(
                    onlineMongoConnectionInfo.connectionUri(),
                    facilityCodes,
                    mongoDumpConfig.dumpTargets(),
                    Math.max(timeoutMs, 5000)
            );
            if (!response.ok()) {
                throw new IllegalStateException("DocDB4 helper clear failed: " + response.message());
            }
            return;
        }

        onlineMongoClearService.clearFacilityData(
                facilityCodes,
                onlineMongoClient.getDatabase(onlineMongoConnectionInfo.database())
        );
    }

    public String connectionUri() {
        return onlineMongoConnectionInfo.connectionUri();
    }

    public MongoToolProfile mongoToolProfile() {
        return resolveModeForOperation() == OnlineMongoAccessMode.DOCDB4
                ? MongoToolProfile.DOCDB4_COMPAT
                : MongoToolProfile.DEFAULT;
    }

    private ExternalConnectivityChecker.CheckResult autoConnectivity() {
        DocDb4HelperRunner.ServerInfoResponse info = helperRunner.fetchServerInfo(
                onlineMongoConnectionInfo.connectionUri(),
                timeoutMs
        );
        if (!info.ok()) {
            return ExternalConnectivityChecker.CheckResult.down("mongo", info.message());
        }

        OnlineMongoAccessMode resolved = classify(info);
        cacheAutoMode(resolved, info);
        if (resolved == OnlineMongoAccessMode.DOCDB4) {
            return ExternalConnectivityChecker.CheckResult.up(
                    "mongo",
                    "reachable (mode=docdb4, version=%s, wire=%s)".formatted(
                            valueOrUnknown(info.serverVersion()),
                            valueOrUnknown(info.maxWireVersion())
                    )
            );
        }
        return modernConnectivity();
    }

    private ExternalConnectivityChecker.CheckResult modernConnectivity() {
        try {
            onlineMongoClient.getDatabase(onlineMongoConnectionInfo.database())
                    .runCommand(new Document("ping", 1));
            return ExternalConnectivityChecker.CheckResult.up("mongo");
        } catch (Exception ex) {
            return ExternalConnectivityChecker.CheckResult.down("mongo", summarize(ex));
        }
    }

    private ExternalConnectivityChecker.CheckResult helperConnectivity() {
        DocDb4HelperRunner.ServerInfoResponse info = helperRunner.fetchServerInfo(
                onlineMongoConnectionInfo.connectionUri(),
                timeoutMs
        );
        if (!info.ok()) {
            return ExternalConnectivityChecker.CheckResult.down("mongo", info.message());
        }
        return ExternalConnectivityChecker.CheckResult.up(
                "mongo",
                "reachable (mode=docdb4, version=%s, wire=%s)".formatted(
                        valueOrUnknown(info.serverVersion()),
                        valueOrUnknown(info.maxWireVersion())
                )
        );
    }

    private OnlineMongoAccessMode resolveModeForOperation() {
        OnlineMongoAccessMode mode = OnlineMongoAccessMode.from(configuredMode);
        if (mode != OnlineMongoAccessMode.AUTO) {
            return mode;
        }

        OnlineMongoAccessMode cached = autoResolvedMode.get();
        if (cached != null) {
            return cached;
        }

        DocDb4HelperRunner.ServerInfoResponse info = helperRunner.fetchServerInfo(
                onlineMongoConnectionInfo.connectionUri(),
                Math.max(timeoutMs, 5000)
        );
        if (!info.ok()) {
            throw new IllegalStateException("online Mongo mode auto detection failed: " + info.message());
        }

        OnlineMongoAccessMode resolved = classify(info);
        cacheAutoMode(resolved, info);
        return resolved;
    }

    private void cacheAutoMode(
            OnlineMongoAccessMode resolved,
            DocDb4HelperRunner.ServerInfoResponse info) {

        if (autoResolvedMode.compareAndSet(null, resolved)) {
            log.info(
                    "[ONLINE_MONGO] driver mode auto resolved: mode={}, version={}, wire={}",
                    resolved,
                    valueOrUnknown(info.serverVersion()),
                    valueOrUnknown(info.maxWireVersion())
            );
        }
    }

    private OnlineMongoAccessMode classify(DocDb4HelperRunner.ServerInfoResponse info) {
        if (info.maxWireVersion() != null && info.maxWireVersion() <= 7) {
            return OnlineMongoAccessMode.DOCDB4;
        }
        if (info.serverVersion() != null && info.serverVersion().startsWith("4.0")) {
            return OnlineMongoAccessMode.DOCDB4;
        }
        return OnlineMongoAccessMode.MODERN;
    }

    private String summarize(Throwable throwable) {
        Throwable root = throwable;
        while (root.getCause() != null) {
            root = root.getCause();
        }
        String message = root.getMessage();
        return (message == null || message.isBlank()) ? root.getClass().getSimpleName() : message;
    }

    private String valueOrUnknown(Object value) {
        return value == null ? "unknown" : value.toString();
    }
}
