package com.fnsi.cloudconverter.refresh.pg;

import org.springframework.jdbc.core.JdbcTemplate;

/**
 * PG FK 刷新サービス (03_module.md § Module 8)
 */
public interface FkRefreshService {
    /**
     * fk_migration_config に基づき中転 DB の FK カラムを更新する
     * @param jdbcTemplate 中転 DB の JdbcTemplate
     * @param jobId        JOB ID（ログ用）
     * @param taskName     タスク名（ログプレフィックス用、例: TASK4_FK_REFRESH）
     * @return 更新合計件数
     */
    long refreshAll(JdbcTemplate jdbcTemplate, java.util.List<String> codes, long jobId, String taskName);

    /**
     * fk_migration_config に基づき中転 DB の FK カラムを更新する（DB ラベル付き）
     * @param jdbcTemplate 中転 DB の JdbcTemplate
     * @param jobId        JOB ID（ログ用）
     * @param taskName     タスク名（ログプレフィックス用、例: TASK4_FK_REFRESH）
     * @param dbLabel      表示用 DB ラベル（例: db5 / db6）
     * @return 更新合計件数
     */
    default long refreshAll(JdbcTemplate jdbcTemplate, java.util.List<String> codes, long jobId, String taskName, String dbLabel) {
        return refreshAll(jdbcTemplate, codes, jobId, taskName);
    }

    /**
     * fk_migration_config に基づき、中転 DB の対象テーブルだけ FK カラムを更新する
     *
     * @param jdbcTemplate 中転 DB の JdbcTemplate
     * @param codes        facilityCDs
     * @param jobId        JOB ID（ログ用）
     * @param taskName     タスク名（ログプレフィックス用、例: TASK4_FK_REFRESH）
     * @param direction    移行方向（off2on / on2off）
     * @param dbName       対象 DB 名（ntss_db4 / ntss_db5 / ntss_db6）
     * @param dbLabel      表示用 DB ラベル（db4 / db5 / db6）
     * @return 更新合計件数
     */
    default long refreshAll(org.springframework.jdbc.core.JdbcTemplate jdbcTemplate, java.util.List<String> codes, long jobId, String taskName,
                            String direction, String dbName, String dbLabel) {
        return refreshAll(jdbcTemplate, codes, jobId, taskName, dbLabel);
    }
}
