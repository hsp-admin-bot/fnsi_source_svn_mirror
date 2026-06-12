package com.fnsi.cloudconverter.mapping.fkmongo.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.time.Instant;

/**
 * Mongo FK 刷新設定エンティティ (04_database.md § 2.6)
 */
@Entity
@Table(name = "fk_mongo_migration_config")
@Getter
@Setter
public class FkMongoMigrationConfig {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "collection_name", nullable = false)
    private String collectionName;

    @Column(name = "field_path", nullable = false)
    private String fieldPath;     // dot path: user_id / items[].item_id / info.*.user_id

    @Column(name = "ref_table_name", nullable = false)
    private String refTableName;

    @Column(name = "field_encoding", nullable = false)
    private String fieldEncoding = "BSON";   // BSON or JSON_STRING

    @Column(name = "execution_order", nullable = false)
    private int executionOrder = 0;

    @Column(name = "enabled", nullable = false)
    private boolean enabled = true;

    @Column(name = "where_condition")
    private String whereCondition;  // 兄弟フィールド条件（JSON）。NULL=無条件

    @Column(name = "remark")
    private String remark;

    @Column(name = "created_at", updatable = false)
    private Instant createdAt;
}
