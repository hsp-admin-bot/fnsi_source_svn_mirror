package com.fnsi.cloudconverter.migration.mongo;

import lombok.Data;

/**
 * Mongo ダンプ対象コレクション設定 (mongo_dump_config.yaml の 1 エントリ)
 */
@Data
public class MongoCollectionConfig {
    /** コレクション名 */
    private String  name;
    /** ダンプ対象か */
    private boolean dump = true;
    /** 施設フィルターフィールド名（null の場合は全件） */
    private String  filterField;
}
