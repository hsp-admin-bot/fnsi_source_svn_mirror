package com.fnsi.cloudconverter.config;

import com.zaxxer.hikari.HikariDataSource;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.boot.jdbc.DataSourceBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;
import org.springframework.jdbc.core.JdbcTemplate;

import javax.sql.DataSource;

/**
 * マルチデータソース設定
 * 参照: 04_database.md § 8 / 06_reference_admin_web.md § 7.2
 *
 * データソース構成:
 *   converter (Primary) — convert_db: 管理テーブル（JPA 対象）
 *   transitDb1/2/3      — transit_db_1/2/3: 中転 DB（JdbcTemplate で直接操作）
 *   onlineProd          — 在線生産 RDS（SEQ 取得・CLEAR 処理用）
 */
@Configuration
public class DataSourceConfig {

    // -------------------------------------------------------
    // Primary DataSource (convert_db) — JPA 用
    // -------------------------------------------------------

    @Primary
    @Bean
    @ConfigurationProperties("spring.datasource")
    public DataSource converterDataSource() {
        return DataSourceBuilder.create().type(HikariDataSource.class).build();
    }

    // -------------------------------------------------------
    // Transit DB 1 (ntss_db4 相当)
    // -------------------------------------------------------

    @Bean
    @ConfigurationProperties("transit.datasource.db1")
    public DataSource transitDataSource1() {
        return DataSourceBuilder.create().type(HikariDataSource.class).build();
    }

    @Bean("transitJdbc1")
    public JdbcTemplate transitJdbcTemplate1() {
        return new JdbcTemplate(transitDataSource1());
    }

    // -------------------------------------------------------
    // Transit DB 2 (ntss_db5 相当)
    // -------------------------------------------------------

    @Bean
    @ConfigurationProperties("transit.datasource.db2")
    public DataSource transitDataSource2() {
        return DataSourceBuilder.create().type(HikariDataSource.class).build();
    }

    @Bean("transitJdbc2")
    public JdbcTemplate transitJdbcTemplate2() {
        return new JdbcTemplate(transitDataSource2());
    }

    // -------------------------------------------------------
    // Transit DB 3 (ntss_db6 相当)
    // -------------------------------------------------------

    @Bean
    @ConfigurationProperties("transit.datasource.db3")
    public DataSource transitDataSource3() {
        return DataSourceBuilder.create().type(HikariDataSource.class).build();
    }

    @Bean("transitJdbc3")
    public JdbcTemplate transitJdbcTemplate3() {
        return new JdbcTemplate(transitDataSource3());
    }

    // -------------------------------------------------------
    // Online Production — 業務メイン (ntss_db5)
    // -------------------------------------------------------

    @Bean
    @ConfigurationProperties("online.datasource.default")
    public DataSource onlineDefaultDataSource() {
        return DataSourceBuilder.create().type(HikariDataSource.class).build();
    }

    @Bean("onlineDefaultJdbc")
    public JdbcTemplate onlineDefaultJdbcTemplate() {
        return new JdbcTemplate(onlineDefaultDataSource());
    }

    // -------------------------------------------------------
    // Online Production — 個人データ (ntss_db6)
    // -------------------------------------------------------

    @Bean
    @ConfigurationProperties("online.datasource.personal")
    public DataSource onlinePersonalDataSource() {
        return DataSourceBuilder.create().type(HikariDataSource.class).build();
    }

    @Bean("onlinePersonalJdbc")
    public JdbcTemplate onlinePersonalJdbcTemplate() {
        return new JdbcTemplate(onlinePersonalDataSource());
    }

    // -------------------------------------------------------
    // Online Production — 認証・権限 (ntss_db4)
    // -------------------------------------------------------

    @Bean
    @ConfigurationProperties("online.datasource.auth")
    public DataSource onlineAuthDataSource() {
        return DataSourceBuilder.create().type(HikariDataSource.class).build();
    }

    @Bean("onlineAuthJdbc")
    public JdbcTemplate onlineAuthJdbcTemplate() {
        return new JdbcTemplate(onlineAuthDataSource());
    }

    // -------------------------------------------------------
    // Converter DB JdbcTemplate (施設ロック等に使用)
    // -------------------------------------------------------

    @Bean("converterJdbc")
    public JdbcTemplate converterJdbcTemplate() {
        return new JdbcTemplate(converterDataSource());
    }
}
