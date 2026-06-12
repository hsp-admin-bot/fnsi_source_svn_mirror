package com.fnsi.cloudconverter.mapping.fk.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.time.Instant;

/**
 * PG FK 刷新設定エンティティ (04_database.md § 2.5)
 */
@Entity
@Table(name = "fk_migration_config")
@Getter
@Setter
public class FkMigrationConfig {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "table_name", nullable = false)
    private String tableName;

    @Column(name = "fk_type", nullable = false)
    private String fkType;        // "COLUMN" / "JSON"

    @Column(name = "column_name")
    private String columnName;

    @Column(name = "json_column")
    private String jsonColumn;

    @Column(name = "json_path")
    private String jsonPath;      // 旧式: {items,itemId} / 新式: items.itemId, [].cd, aaa.[].cd

    @Column(name = "ref_table", nullable = false)
    private String refTable;

    @Column(name = "execution_order", nullable = false)
    private int executionOrder = 0;

    @Column(name = "enabled", nullable = false)
    private boolean enabled = true;

    @Column(name = "where_template")
    private String whereTemplate;   // 多態FK 過滤条件（SQL片段）。新規は @ を現在JSON文脈として使う

    @Column(name = "remark")
    private String remark;

    @Column(name = "created_at", updatable = false)
    private Instant createdAt;

    @Column(name = "where_column")
    private String whereColumn;   // 多態FK 過滤条件（SQL片段）。新規は @ を現在JSON文脈として使う


    @Column(name = "encryptFlag")
    private Boolean encryptFlag = true;
}
