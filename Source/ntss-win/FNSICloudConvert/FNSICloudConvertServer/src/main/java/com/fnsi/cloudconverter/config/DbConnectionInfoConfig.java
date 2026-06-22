package com.fnsi.cloudconverter.config;

import com.fnsi.cloudconverter.migration.pg.DbConnectionInfo;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import javax.sql.DataSource;

/**
 * ProcessBuilder (pg_dump/pg_restore) 用 DB 接続情報ビーン
 * HikariDataSource の JDBC URL から host/port/database を抽出する
 */
@Configuration
public class DbConnectionInfoConfig {

    @Bean("transitDb1ConnInfo")
    public DbConnectionInfo transitDb1ConnInfo(
            @Qualifier("transitDataSource1") DataSource ds) {
        return DbConnectionInfo.from(ds);
    }

    @Bean("transitDb2ConnInfo")
    public DbConnectionInfo transitDb2ConnInfo(
            @Qualifier("transitDataSource2") DataSource ds) {
        return DbConnectionInfo.from(ds);
    }

    @Bean("transitDb3ConnInfo")
    public DbConnectionInfo transitDb3ConnInfo(
            @Qualifier("transitDataSource3") DataSource ds) {
        return DbConnectionInfo.from(ds);
    }

    @Bean("onlineDefaultConnInfo")
    public DbConnectionInfo onlineDefaultConnInfo(
            @Qualifier("onlineDefaultDataSource") DataSource ds) {
        return DbConnectionInfo.from(ds);
    }

    @Bean("onlinePersonalConnInfo")
    public DbConnectionInfo onlinePersonalConnInfo(
            @Qualifier("onlinePersonalDataSource") DataSource ds) {
        return DbConnectionInfo.from(ds);
    }

    @Bean("onlineAuthConnInfo")
    public DbConnectionInfo onlineAuthConnInfo(
            @Qualifier("onlineAuthDataSource") DataSource ds) {
        return DbConnectionInfo.from(ds);
    }
}
