package com.fnsi.cloudconverter.config;

import com.mongodb.ConnectionString;
import com.mongodb.MongoClientSettings;
import com.mongodb.client.MongoClient;
import com.mongodb.client.MongoClients;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;
import org.springframework.data.mongodb.MongoDatabaseFactory;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.SimpleMongoClientDatabaseFactory;

/**
 * MongoDB マルチ接続設定
 *   transit (Primary) — 中転庫 MongoDB
 *   online            — 在線生産 MongoDB
 */
@Configuration
public class MongoConfig {

    // -------------------------------------------------------
    // 中転庫 MongoDB (Primary)
    // -------------------------------------------------------

    @Value("${transit.data.mongodb.connection-string}")
    private String transitMongoUri;

    @Primary
    @Bean("transitMongoClient")
    public MongoClient transitMongoClient() {
        MongoClientSettings settings = MongoClientSettings.builder()
                .applyConnectionString(new ConnectionString(transitMongoUri))
                .build();
        return MongoClients.create(settings);
    }

    @Primary
    @Bean
    public MongoDatabaseFactory mongoDatabaseFactory() {
        return new SimpleMongoClientDatabaseFactory(transitMongoClient(),
                extractDatabase(transitMongoUri));
    }

    @Primary
    @Bean
    public MongoTemplate mongoTemplate() {
        return new MongoTemplate(mongoDatabaseFactory());
    }

    // -------------------------------------------------------
    // 在線生産 MongoDB
    // -------------------------------------------------------

    @Bean("onlineMongoClient")
    public MongoClient onlineMongoClient(OnlineMongoConnectionInfo onlineMongoConnectionInfo) {
        MongoClientSettings settings = MongoClientSettings.builder()
                .applyConnectionString(new ConnectionString(onlineMongoConnectionInfo.connectionUri()))
                .build();
        return MongoClients.create(settings);
    }

    // -------------------------------------------------------
    // ユーティリティ
    // -------------------------------------------------------

    /** mongodb://user:pass@host:port/database?... からDB名を抽出 */
    private String extractDatabase(String uri) {
        // パス部分 "/database?" を取り出す
        String path = uri.replaceAll(".*@[^/]+/([^?]+).*", "$1");
        return path.isBlank() ? "ntss" : path;
    }
}
