package com.fnsi.cloudconverter.migration.pg;

import com.zaxxer.hikari.HikariDataSource;

import javax.sql.DataSource;

/**
 * DB 接続情報（ProcessBuilder コマンド構築用）
 */
public record DbConnectionInfo(
        String host,
        int    port,
        String database,
        String username,
        String password
) {
    /** HikariDataSource から接続情報を抽出する */
    public static DbConnectionInfo from(DataSource dataSource) {
        HikariDataSource hds = (HikariDataSource) dataSource;
        String url = hds.getJdbcUrl();
        // jdbc:postgresql://host:port/database?params
        String withoutPrefix = url.substring("jdbc:postgresql://".length());
        int queryIdx = withoutPrefix.indexOf('?');
        String hostPortDb = queryIdx >= 0
                ? withoutPrefix.substring(0, queryIdx)
                : withoutPrefix;
        String[] parts = hostPortDb.split("/", 2);
        String[] hostPort = parts[0].split(":", 2);

        String host     = hostPort[0];
        int    port     = hostPort.length > 1 ? Integer.parseInt(hostPort[1]) : 5432;
        String database = parts.length > 1 ? parts[1] : "postgres";

        return new DbConnectionInfo(host, port, database,
                hds.getUsername(), hds.getPassword());
    }
}
