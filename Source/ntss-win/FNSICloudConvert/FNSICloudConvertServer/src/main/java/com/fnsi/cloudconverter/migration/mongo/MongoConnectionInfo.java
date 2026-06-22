package com.fnsi.cloudconverter.migration.mongo;

/**
 * Mongo 接続情報（ProcessBuilder コマンド構築用）
 */
public record MongoConnectionInfo(
        String host,
        int    port,
        String database,
        String username,
        String password
) {
    /** URI から接続情報を抽出する: mongodb://[user:pass@]host:port/database[?params] */
    public static MongoConnectionInfo fromUri(String uri) {
        String withoutScheme = uri.substring("mongodb://".length());

        // user:password@ を抽出
        String username = null;
        String password = null;
        int atIdx = withoutScheme.indexOf('@');
        if (atIdx >= 0) {
            String credentials = withoutScheme.substring(0, atIdx);
            String[] credParts = credentials.split(":", 2);
            username = credParts[0];
            password = credParts.length > 1 ? credParts[1] : null;
            withoutScheme = withoutScheme.substring(atIdx + 1);
        }

        int queryIdx = withoutScheme.indexOf('?');
        String hostDb = queryIdx >= 0 ? withoutScheme.substring(0, queryIdx) : withoutScheme;
        String[] parts    = hostDb.split("/", 2);
        String[] hostPort = parts[0].split(":", 2);

        String host     = hostPort[0];
        int    port     = hostPort.length > 1 ? Integer.parseInt(hostPort[1]) : 27017;
        String database = parts.length > 1 ? parts[1] : "admin";
        return new MongoConnectionInfo(host, port, database, username, password);
    }
}
