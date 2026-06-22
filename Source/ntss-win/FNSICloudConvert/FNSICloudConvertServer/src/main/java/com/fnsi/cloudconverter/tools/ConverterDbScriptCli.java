package com.fnsi.cloudconverter.tools;

import org.springframework.core.io.ClassPathResource;
import org.springframework.core.io.support.EncodedResource;
import org.springframework.jdbc.datasource.init.ScriptUtils;

import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

/**
 * Manual convert_db SQL script entry points.
 */
public final class ConverterDbScriptCli {

    private static final List<String> SCRIPT_LOCATIONS = List.of(
            "db/migration/V1__create_core_tables.sql",
            "db/migration/V2__insert_fk_migration_config.sql",
            "db/migration/V3__insert_fk_mongo_migration_config.sql"
    );

    private ConverterDbScriptCli() {
    }

    public static void main(String[] args) throws Exception {
        String command = args.length == 0 ? "migrate" : args[0];
        ConverterDbSettings settings = ConverterDbSettings.load();

        System.out.printf(
                "[converter-db] command=%s host=%s port=%d database=%s schema=%s%n",
                command,
                settings.host(),
                settings.port(),
                settings.database(),
                settings.schema()
        );

        switch (command) {
            case "migrate" -> migrate(settings);
            case "init" -> init(settings);
            default -> throw new IllegalArgumentException(
                    "Unsupported command: " + command + ". Use 'migrate' or 'init'."
            );
        }
    }

    private static void init(ConverterDbSettings settings) throws Exception {
        validateIdentifier(settings.database(), "database");
        validateIdentifier(settings.adminDatabase(), "admin database");

        try (Connection connection = DriverManager.getConnection(
                settings.adminJdbcUrl(),
                settings.username(),
                settings.password()
        )) {
            connection.setAutoCommit(true);

            List<String> activeSessions = findActiveSessions(connection, settings.database());
            if (!activeSessions.isEmpty()) {
                throw new IllegalStateException(
                        "convert_db is currently in use. Stop the server or disconnect these sessions before running initConverterDb: "
                                + String.join("; ", activeSessions)
                );
            }

            try (Statement statement = connection.createStatement()) {
                statement.execute("DROP DATABASE IF EXISTS \"" + settings.database() + "\"");
                statement.execute("CREATE DATABASE \"" + settings.database() + "\"");
            }
        }

        migrate(settings);
    }

    private static void migrate(ConverterDbSettings settings) throws Exception {
        try (Connection connection = DriverManager.getConnection(
                settings.targetJdbcUrl(),
                settings.username(),
                settings.password()
        )) {
            connection.setAutoCommit(false);

            int scriptsExecuted = 0;
            try {
                for (String scriptLocation : SCRIPT_LOCATIONS) {
                    System.out.printf("[converter-db] apply script: %s%n", scriptLocation);
                    ScriptUtils.executeSqlScript(
                            connection,
                            new EncodedResource(new ClassPathResource(scriptLocation), StandardCharsets.UTF_8)
                    );
                    scriptsExecuted++;
                }
                connection.commit();
                System.out.printf(
                        "[converter-db] script apply complete, scriptsExecuted=%d%n",
                        scriptsExecuted
                );
            } catch (Exception ex) {
                connection.rollback();
                throw ex;
            }
        }
    }

    private static void validateIdentifier(String value, String label) {
        if (!value.matches("[A-Za-z0-9_]+")) {
            throw new IllegalArgumentException(
                    "Unsupported " + label + " name: " + value + ". Use only letters, digits, and underscores."
            );
        }
    }

    private static List<String> findActiveSessions(Connection connection, String database) throws SQLException {
        List<String> sessions = new ArrayList<>();
        String sql = """
                SELECT pid,
                       usename,
                       COALESCE(application_name, '') AS application_name,
                       COALESCE(client_addr::text, 'local') AS client_addr,
                       COALESCE(state, 'unknown') AS state
                  FROM pg_stat_activity
                 WHERE datname = '%s'
                   AND pid <> pg_backend_pid()
                 ORDER BY pid
                """.formatted(database);

        try (Statement statement = connection.createStatement();
             ResultSet resultSet = statement.executeQuery(sql)) {
            while (resultSet.next()) {
                sessions.add(
                        "pid=%d,user=%s,app=%s,client=%s,state=%s".formatted(
                                resultSet.getInt("pid"),
                                resultSet.getString("usename"),
                                blankToPlaceholder(resultSet.getString("application_name")),
                                resultSet.getString("client_addr"),
                                resultSet.getString("state")
                        )
                );
            }
        }
        return sessions;
    }

    private static String blankToPlaceholder(String value) {
        return (value == null || value.isBlank()) ? "<unknown>" : value;
    }

    private record ConverterDbSettings(
            String host,
            int port,
            String database,
            String schema,
            String username,
            String password,
            String adminDatabase
    ) {
        private static ConverterDbSettings load() {
            return new ConverterDbSettings(
                    readSetting("converter.db.host", "localhost"),
                    Integer.parseInt(readSetting("converter.db.port", "5433")),
                    readSetting("converter.db.name", "convert_db"),
                    readSetting("converter.db.schema", "public"),
                    readSetting("converter.db.username", "postgres"),
                    readSetting("converter.db.password", "postgres"),
                    readSetting("converter.db.adminDatabase", "postgres")
            );
        }

        private String adminJdbcUrl() {
            return String.format("jdbc:postgresql://%s:%d/%s", host, port, adminDatabase);
        }

        private String targetJdbcUrl() {
            return String.format(
                    "jdbc:postgresql://%s:%d/%s?currentSchema=%s",
                    host,
                    port,
                    database,
                    schema
            );
        }

        private static String readSetting(String key, String defaultValue) {
            String value = System.getProperty(key);
            return (value == null || value.isBlank()) ? defaultValue : value;
        }
    }
}
