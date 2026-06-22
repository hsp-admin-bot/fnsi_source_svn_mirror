package com.fnsi.cloudconverter.refresh.mongo;

import com.fnsi.cloudconverter.mapping.fkmongo.entity.FkMongoMigrationConfig;
import com.fnsi.cloudconverter.mapping.fkmongo.repository.FkMongoMigrationConfigRepository;
import com.fnsi.cloudconverter.mapping.pk.PkMappingService;
import com.fnsi.cloudconverter.log.MigrationLogService;
import com.mongodb.client.FindIterable;
import com.mongodb.client.MongoCollection;
import com.mongodb.client.MongoDatabase;
import com.mongodb.client.model.Filters;
import com.mongodb.client.model.ReplaceOneModel;
import com.mongodb.client.model.WriteModel;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.bson.Document;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * Mongo FK 刷新サービス実装
 * fk_mongo_migration_config の dot-path 設定に基づき Mongo ドキュメントの FK を更新
 * 参照: 03_module.md § Module 9 / 05_key_tech.md § 6
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class MongoFkRefreshServiceImpl implements MongoFkRefreshService {

    private static final int DOCUMENT_BATCH_SIZE = 200;

    private final FkMongoMigrationConfigRepository mongoFkConfigRepository;
    private final PkMappingService                 pkMappingService;
    private final MongoFkDocumentUpdater           documentUpdater;
    private final MigrationLogService              logService;

    @Override
    public long refreshAll(MongoDatabase database, long jobId) {
        List<FkMongoMigrationConfig> configs =
                mongoFkConfigRepository.findByEnabledTrueOrderByExecutionOrderAscIdAsc();

        long total = 0;
        for (int i = 0; i < configs.size(); i++) {
            FkMongoMigrationConfig cfg = configs.get(i);
            int current = i + 1;
            logService.info(jobId, null, String.format(
                    "[MONGO_FK] 設定開始 (%d/%d): %s.%s -> %s",
                    current, configs.size(), cfg.getCollectionName(), cfg.getFieldPath(), cfg.getRefTableName()));

            MongoCollection<Document> collection =
                    database.getCollection(cfg.getCollectionName());

            long updated = refreshCollection(collection, cfg);
            total += updated;
            logService.info(jobId, null, String.format(
                    "[MONGO_FK] 設定完了 (%d/%d): %s.%s updated=%d",
                    current, configs.size(), cfg.getCollectionName(), cfg.getFieldPath(), updated));
            log.debug("[MONGO_FK] collection={}, field={}, encoding={}, where={}, updated={}",
                    cfg.getCollectionName(), cfg.getFieldPath(), cfg.getFieldEncoding(),
                    cfg.getWhereCondition(), updated);
        }
        log.info("[MONGO_FK] 完了: jobId={}, totalUpdated={}", jobId, total);
        return total;
    }

    private long refreshCollection(MongoCollection<Document> collection,
                                   FkMongoMigrationConfig config) {
        String rootField = config.getFieldPath().split("\\.")[0].replace("[]", "");
        FindIterable<Document> documents = collection.find(Filters.exists(rootField)).batchSize(DOCUMENT_BATCH_SIZE);

        List<Document> documentBatch = new ArrayList<>(DOCUMENT_BATCH_SIZE);
        long updatedCount = 0;
        for (Document document : documents) {
            documentBatch.add(document);
            if (documentBatch.size() >= DOCUMENT_BATCH_SIZE) {
                updatedCount += refreshDocumentBatch(collection, config, documentBatch);
                documentBatch.clear();
            }
        }
        if (!documentBatch.isEmpty()) {
            updatedCount += refreshDocumentBatch(collection, config, documentBatch);
        }
        return updatedCount;
    }

    private long refreshDocumentBatch(MongoCollection<Document> collection,
                                      FkMongoMigrationConfig config,
                                      List<Document> documents) {
        Set<Long> oldIds = new LinkedHashSet<>();
        for (Document document : documents) {
            documentUpdater.collectOldIds(document, config, oldIds);
        }
        if (oldIds.isEmpty()) {
            return 0;
        }

        Map<Long, Long> mapping = pkMappingService.findMappings(config.getRefTableName(), new ArrayList<>(oldIds));
        if (mapping.isEmpty()) {
            return 0;
        }

        List<WriteModel<Document>> writes = new ArrayList<>();
        long updatedCount = 0;
        for (Document document : documents) {
            if (!documentUpdater.apply(document, config, mapping)) {
                continue;
            }
            writes.add(new ReplaceOneModel<>(Filters.eq("_id", document.get("_id")), document));
            updatedCount++;
            if (writes.size() >= DOCUMENT_BATCH_SIZE) {
                collection.bulkWrite(writes);
                writes.clear();
            }
        }
        if (!writes.isEmpty()) {
            collection.bulkWrite(writes);
        }
        return updatedCount;
    }
}
