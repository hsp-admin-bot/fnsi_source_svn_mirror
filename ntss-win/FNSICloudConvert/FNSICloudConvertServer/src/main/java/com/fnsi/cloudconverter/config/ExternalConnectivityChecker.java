package com.fnsi.cloudconverter.config;

import com.mongodb.ConnectionString;
import com.mongodb.MongoClientSettings;
import com.mongodb.client.MongoClient;
import com.mongodb.client.MongoClients;
import com.fnsi.cloudconverter.onlinemongo.OnlineMongoAccessService;
import com.zaxxer.hikari.HikariDataSource;
import org.bson.Document;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.concurrent.TimeUnit;

/**
 * 外部依存（PostgreSQL / MongoDB）の軽量な疎通確認を行う。
 * 起動成否には関与せず、ログ出力と Health 表示のためだけに使用する。
 */
@Component
public class ExternalConnectivityChecker {

    private final DataSource converterDataSource;
    private final DataSource transitDataSource1;
    private final DataSource transitDataSource2;
    private final DataSource transitDataSource3;
    private final DataSource onlineDefaultDataSource;
    private final DataSource onlinePersonalDataSource;
    private final DataSource onlineAuthDataSource;
    private final OnlineMongoAccessService onlineMongoAccessService;

    @Value("${transit.data.mongodb.connection-string}")
    private String transitMongoUri;

    @Value("${connectivity.check.timeout-ms:2000}")
    private int timeoutMs;

    public ExternalConnectivityChecker(
            @Qualifier("converterDataSource") DataSource converterDataSource,
            @Qualifier("transitDataSource1") DataSource transitDataSource1,
            @Qualifier("transitDataSource2") DataSource transitDataSource2,
            @Qualifier("transitDataSource3") DataSource transitDataSource3,
            @Qualifier("onlineDefaultDataSource") DataSource onlineDefaultDataSource,
            @Qualifier("onlinePersonalDataSource") DataSource onlinePersonalDataSource,
            @Qualifier("onlineAuthDataSource") DataSource onlineAuthDataSource,
            OnlineMongoAccessService onlineMongoAccessService) {
        this.converterDataSource = converterDataSource;
        this.transitDataSource1 = transitDataSource1;
        this.transitDataSource2 = transitDataSource2;
        this.transitDataSource3 = transitDataSource3;
        this.onlineDefaultDataSource = onlineDefaultDataSource;
        this.onlinePersonalDataSource = onlinePersonalDataSource;
        this.onlineAuthDataSource = onlineAuthDataSource;
        this.onlineMongoAccessService = onlineMongoAccessService;
    }

    public Map<String, CheckResult> checkAll() {
        Map<String, CheckResult> results = new LinkedHashMap<>();
        results.put("converterDb", checkConverterDb());
        results.put("transitDb4", checkTransitDb4());
        results.put("transitDb5", checkTransitDb5());
        results.put("transitDb6", checkTransitDb6());
        results.put("onlineDb5", checkOnlineDb5());
        results.put("onlineDb6", checkOnlineDb6());
        results.put("onlineAuthDb4", checkOnlineAuthDb4());
        results.put("transitMongo", checkTransitMongo());
        results.put("onlineMongo", checkOnlineMongo());
        return results;
    }

    public CheckResult checkConverterDb() {
        return checkPostgres(converterDataSource);
    }

    public CheckResult checkTransitDb4() {
        return checkPostgres(transitDataSource1);
    }

    public CheckResult checkTransitDb5() {
        return checkPostgres(transitDataSource2);
    }

    public CheckResult checkTransitDb6() {
        return checkPostgres(transitDataSource3);
    }

    public CheckResult checkOnlineDb5() {
        return checkPostgres(onlineDefaultDataSource);
    }

    public CheckResult checkOnlineDb6() {
        return checkPostgres(onlinePersonalDataSource);
    }

    public CheckResult checkOnlineAuthDb4() {
        return checkPostgres(onlineAuthDataSource);
    }

    public CheckResult checkTransitMongo() {
        return checkMongo(transitMongoUri);
    }

    public CheckResult checkOnlineMongo() {
        return onlineMongoAccessService.checkConnectivity();
    }

    private CheckResult checkPostgres(DataSource dataSource) {
        if (!(dataSource instanceof HikariDataSource hikari)) {
            return CheckResult.down("postgres", "Unsupported DataSource type: " + dataSource.getClass().getName());
        }

        String jdbcUrl = appendPostgresTimeouts(hikari.getJdbcUrl());
        try (Connection connection = DriverManager.getConnection(jdbcUrl, hikari.getUsername(), hikari.getPassword());
             PreparedStatement statement = connection.prepareStatement("SELECT 1")) {
            statement.execute();
            return CheckResult.up("postgres");
        } catch (Exception ex) {
            return CheckResult.down("postgres", summarize(ex));
        }
    }

    private CheckResult checkMongo(String connectionUri) {
        ConnectionString connectionString = new ConnectionString(connectionUri);
        MongoClientSettings settings = MongoClientSettings.builder()
                .applyConnectionString(connectionString)
                .applyToClusterSettings(builder ->
                        builder.serverSelectionTimeout(timeoutMs, TimeUnit.MILLISECONDS))
                .applyToSocketSettings(builder -> {
                    builder.connectTimeout(timeoutMs, TimeUnit.MILLISECONDS);
                    builder.readTimeout(timeoutMs, TimeUnit.MILLISECONDS);
                })
                .build();

        String database = connectionString.getDatabase();
        if (database == null || database.isBlank()) {
            database = "admin";
        }

        try (MongoClient client = MongoClients.create(settings)) {
            client.getDatabase(database).runCommand(new Document("ping", 1));
            return CheckResult.up("mongo");
        } catch (Exception ex) {
            return CheckResult.down("mongo", summarize(ex));
        }
    }

    private String appendPostgresTimeouts(String jdbcUrl) {
        String separator = jdbcUrl.contains("?") ? "&" : "?";
        int timeoutSeconds = Math.max(1, (int) Math.ceil(timeoutMs / 1000.0));
        return jdbcUrl
                + separator + "connectTimeout=" + timeoutSeconds
                + "&socketTimeout=" + timeoutSeconds
                + "&ApplicationName=connectivity-check";
    }

    private String summarize(Throwable throwable) {
        Throwable root = throwable;
        while (root.getCause() != null) {
            root = root.getCause();
        }
        String message = root.getMessage();
        return (message == null || message.isBlank()) ? root.getClass().getSimpleName() : message;
    }

    public record CheckResult(boolean available, String type, String summary) {

        public static CheckResult up(String type) {
            return new CheckResult(true, type, "reachable");
        }

        public static CheckResult up(String type, String summary) {
            return new CheckResult(true, type, summary);
        }

        public static CheckResult down(String type, String summary) {
            return new CheckResult(false, type, summary);
        }

        public String statusLabel() {
            return available ? "UP" : "DOWN";
        }

        public Map<String, Object> toHealthDetail() {
            Map<String, Object> detail = new LinkedHashMap<>();
            detail.put("type", type);
            detail.put("status", statusLabel());
            detail.put("message", summary);
            return detail;
        }
    }
}
