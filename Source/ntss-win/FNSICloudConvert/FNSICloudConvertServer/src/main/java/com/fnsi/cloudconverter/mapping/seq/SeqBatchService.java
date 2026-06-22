package com.fnsi.cloudconverter.mapping.seq;

import com.fnsi.cloudconverter.migration.pg.PgTableConfig;

import java.util.List;

/**
 * SEQ バッチ申請サービス (03_module.md § Module 4)
 */
public interface SeqBatchService {
    /**
     * 指定テーブルのシーケンスから count 個の連番を一括取得する。
     * シーケンス名は cfg.resolveSeqName()、接続先 DB は cfg.getDb() から自動導出する。
     *
     * @param cfg   pg_dump_config エントリ（idColumn / seqName / db を参照）
     * @param count 必要件数
     * @return 新規 ID リスト（在線本番 DB のシーケンスから払い出し）
     */
    List<Long> fetchNextIds(PgTableConfig cfg, int count);
}
