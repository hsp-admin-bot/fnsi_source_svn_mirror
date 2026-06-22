package com.fnsi.cloudconverter.refresh.mongo;

import com.mongodb.client.MongoDatabase;

/**
 * Mongo FK 刷新サービス (03_module.md § Module 9)
 */
public interface MongoFkRefreshService {
    /**
     * fk_mongo_migration_config に基づき Mongo コレクションの FK フィールドを更新する
     * @param database  対象 Mongo データベース
     * @param jobId     JOB ID
     * @return 更新合計件数
     */
    long refreshAll(MongoDatabase database, long jobId);
}
