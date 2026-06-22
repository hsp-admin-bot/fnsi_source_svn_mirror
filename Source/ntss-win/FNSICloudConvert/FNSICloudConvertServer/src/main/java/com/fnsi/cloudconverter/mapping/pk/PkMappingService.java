package com.fnsi.cloudconverter.mapping.pk;

import java.util.List;
import java.util.Map;
import java.util.Optional;

/**
 * PK マッピングサービス (03_module.md § Module 5)
 */
public interface PkMappingService {
    /** 新旧 PK ペアを pk_mapping テーブルに一括 INSERT */
    void insertBatch(String tableName, List<Long> oldIds, List<Long> newIds, long jobId);

    /** 旧 ID → 新 ID 変換（単一） */
    Optional<Long> findNewId(String tableName, long oldId);

    /** テーブルの全 PK マッピング取得 */
    Map<Long, Long> findAllMappings(String tableName);

    /** 指定された旧 ID だけを対象に PK マッピング取得 */
    Map<Long, Long> findMappings(String tableName, List<Long> oldIds);

    /**
     * 在線→離線用: 旧 ID リストと開始 SEQ から pk_mapping を生成
     * @param startSeq 開始シーケンス値（クライアント提供）
     */
    void generateFromStartSeq(String tableName, List<Long> oldIds, long startSeq, long jobId);

    /** 指定 JOB の pk_mapping を全削除（JOB 完了後クリーンアップ） */
    void deleteByJobId(long jobId);
}
