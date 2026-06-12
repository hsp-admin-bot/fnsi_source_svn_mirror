package com.fnsi.cloudconverter.docdb4helper;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.mongodb.ConnectionString;
import com.mongodb.MongoClientSettings;
import com.mongodb.client.MongoClient;
import com.mongodb.client.MongoClients;
import com.mongodb.client.MongoDatabase;
import com.mongodb.client.model.Filters;
import org.bson.Document;

import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.TimeUnit;

public final class DocDb4HelperApplication {

    private static final ObjectMapper OBJECT_MAPPER = new ObjectMapper();

    private DocDb4HelperApplication() {
    }

    public static void main(String[] args) throws Exception {
        if (args.length == 0) {
            writeAndExit(new ErrorResponse(false, "Command is required"), 2);
            return;
        }

        String command = args[0];
        Map<String, String> options = parseOptions(Arrays.copyOfRange(args, 1, args.length));

        try {
            switch (command) {
                case "server-info" -> handleServerInfo(options);
                case "clear-facility-data" -> handleClearFacilityData(options);
                default -> writeAndExit(new ErrorResponse(false, "Unknown command: " + command), 2);
            }
        } catch (Exception ex) {
            writeAndExit(new ErrorResponse(false, summarize(ex)), 2);
        }
    }

    private static void handleServerInfo(Map<String, String> options) throws Exception {
        String uri = required(options, "uri");
        int timeoutMs = Integer.parseInt(options.getOrDefault("timeoutMs", "2000"));

        try (MongoClient client = MongoClients.create(settings(uri, timeoutMs))) {
            MongoDatabase admin = client.getDatabase("admin");
            Document buildInfo = admin.runCommand(new Document("buildInfo", 1));
            Document isMaster = admin.runCommand(new Document("isMaster", 1));

            String serverVersion = buildInfo.getString("version");
            Integer maxWireVersion = readInteger(isMaster.get("maxWireVersion"));

            writeAndExit(new ServerInfoResponse(true, "reachable", serverVersion, maxWireVersion), 0);
        }
    }

    private static void handleClearFacilityData(Map<String, String> options) throws Exception {
        String uri = required(options, "uri");
        int timeoutMs = Integer.parseInt(options.getOrDefault("timeoutMs", "5000"));
        Path targetsFile = Path.of(required(options, "targetsFile"));
        Path facilityCodesFile = Path.of(required(options, "facilityCodesFile"));

        List<ClearTarget> targets = OBJECT_MAPPER.readValue(
                Files.readString(targetsFile),
                new TypeReference<>() { }
        );
        List<String> facilityCodes = OBJECT_MAPPER.readValue(
                Files.readString(facilityCodesFile),
                new TypeReference<>() { }
        );

        ConnectionString connectionString = new ConnectionString(uri);
        String databaseName = connectionString.getDatabase();
        if (databaseName == null || databaseName.isBlank()) {
            databaseName = "admin";
        }

        List<CollectionDeleteResult> results = new ArrayList<>();
        long totalDeleted = 0;
        try (MongoClient client = MongoClients.create(settings(uri, timeoutMs))) {
            MongoDatabase database = client.getDatabase(databaseName);
            for (ClearTarget target : targets) {
                if (target.filterField() == null || target.filterField().isBlank()) {
                    continue;
                }
                long deleted = database.getCollection(target.name())
                        .deleteMany(Filters.in(target.filterField(), facilityCodes))
                        .getDeletedCount();
                results.add(new CollectionDeleteResult(target.name(), deleted));
                totalDeleted += deleted;
            }
        }

        writeAndExit(new ClearResponse(true, "completed", totalDeleted, results), 0);
    }

    private static MongoClientSettings settings(String uri, int timeoutMs) {
        ConnectionString connectionString = new ConnectionString(uri);
        return MongoClientSettings.builder()
                .applyConnectionString(connectionString)
                .applyToClusterSettings(builder ->
                        builder.serverSelectionTimeout(timeoutMs, TimeUnit.MILLISECONDS))
                .applyToSocketSettings(builder -> {
                    builder.connectTimeout(timeoutMs, TimeUnit.MILLISECONDS);
                    builder.readTimeout(timeoutMs, TimeUnit.MILLISECONDS);
                })
                .build();
    }

    private static Map<String, String> parseOptions(String[] args) {
        Map<String, String> options = new LinkedHashMap<>();
        for (String arg : args) {
            if (!arg.startsWith("--")) {
                continue;
            }
            int eq = arg.indexOf('=');
            if (eq < 0) {
                options.put(arg.substring(2), "true");
            } else {
                options.put(arg.substring(2, eq), arg.substring(eq + 1));
            }
        }
        return options;
    }

    private static String required(Map<String, String> options, String key) {
        String value = options.get(key);
        if (value == null || value.isBlank()) {
            throw new IllegalArgumentException("Missing required option: " + key);
        }
        return value;
    }

    private static Integer readInteger(Object value) {
        if (value instanceof Number number) {
            return number.intValue();
        }
        return null;
    }

    private static void writeAndExit(Object body, int exitCode) throws Exception {
        System.out.println(OBJECT_MAPPER.writeValueAsString(body));
        System.exit(exitCode);
    }

    private static String summarize(Throwable throwable) {
        Throwable root = throwable;
        while (root.getCause() != null) {
            root = root.getCause();
        }
        String message = root.getMessage();
        return (message == null || message.isBlank()) ? root.getClass().getSimpleName() : message;
    }

    private record ErrorResponse(boolean ok, String message) {
    }

    private record ServerInfoResponse(boolean ok, String message, String serverVersion, Integer maxWireVersion) {
    }

    private record ClearTarget(String name, String filterField) {
    }

    private record CollectionDeleteResult(String name, long deleted) {
    }

    private record ClearResponse(
            boolean ok,
            String message,
            long totalDeleted,
            List<CollectionDeleteResult> results) {
    }
}
