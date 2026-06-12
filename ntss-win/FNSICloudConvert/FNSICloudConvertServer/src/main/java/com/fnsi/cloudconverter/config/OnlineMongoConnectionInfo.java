package com.fnsi.cloudconverter.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

/**
 * 在線 MongoDB の接続情報を組み立てる。
 */
@Component
public class OnlineMongoConnectionInfo {

    @Value("${online.data.mongodb.host:localhost}")
    private String host;

    @Value("${online.data.mongodb.port:27017}")
    private int port;

    @Value("${online.data.mongodb.database:ntss}")
    private String database;

    @Value("${online.data.mongodb.username:nkk}")
    private String username;

    @Value("${online.data.mongodb.password:nkk}")
    private String password;

    public String connectionUri() {
        return "mongodb://%s:%s@%s:%d/%s?authSource=%s".formatted(
                username,
                password,
                host,
                port,
                database,
                database
        );
    }

    public String database() {
        return database;
    }
}
