package com.fnsi.cloudconverter.migration.pg;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

/**
 * pg_dump_config.yaml バインディング
 */
@Data
@Component
@ConfigurationProperties(prefix = "pg-dump")
public class PgDumpConfig {
    private List<PgTableConfig> tables = new ArrayList<>();

    /** 指定方向に該当するダンプ対象テーブルを返す */
    public List<PgTableConfig> tablesFor(String direction) {
        return tables.stream()
                .filter(PgTableConfig::isDump)
                .filter(t -> "both".equals(t.getDirection())
                             || direction.equals(t.getDirection()))
                .toList();
    }

    /** 指定方向・DB に該当するダンプ対象テーブルを返す */
    public List<PgTableConfig> tablesForDb(String direction, String dbName) {
        return tables.stream()
                .filter(PgTableConfig::isDump)
                .filter(t -> "both".equals(t.getDirection()) || direction.equals(t.getDirection()))
                .filter(t -> dbName.equals(t.getDb()))
                .toList();
    }

    /**
     * DELETE フェーズ用: dump=false を含む全テーブルのうち whereTemplate が設定されているものを返す
     * FK 子テーブルが dump: false でも facility_cd でクリアが必要な場合に使用
     */
    public List<PgTableConfig> allTablesWithTemplateForDb(String direction, String dbName) {
        return tables.stream()
                .filter(t -> "both".equals(t.getDirection()) || direction.equals(t.getDirection()))
                .filter(t -> dbName.equals(t.getDb()))
                .filter(t -> t.getWhereTemplate() != null)
                .toList();
    }

    /** 指定方向・DB に該当する全テーブル名を返す（dump=false を含む） */
    public Set<String> allTableNamesForDb(String direction, String dbName) {
        return tables.stream()
                .filter(t -> "both".equals(t.getDirection()) || direction.equals(t.getDirection()))
                .filter(t -> dbName.equals(t.getDb()))
                .map(PgTableConfig::getName)
                .collect(Collectors.toSet());
    }
}
