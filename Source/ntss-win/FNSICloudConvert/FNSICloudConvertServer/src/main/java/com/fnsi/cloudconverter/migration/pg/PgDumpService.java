package com.fnsi.cloudconverter.migration.pg;

import java.nio.file.Path;
import java.util.List;

/**
 * PG ダンプ/リストアサービス (03_module.md § Module 2)
 */
public interface PgDumpService {
    /**
     * pg_dump を実行してダンプディレクトリを生成する
     * @param config  テーブル設定
     * @param facilityCodes 対象施設コード
     * @param outputDir 出力先ディレクトリ
     * @param dbConn  接続情報
     */
    DumpResult dump(PgTableConfig config, List<String> facilityCodes,
                    Path outputDir, DbConnectionInfo dbConn);

    /**
     * pg_restore を実行してダンプを DB にインポートする
     * @param tableName テーブル名
     * @param dumpDir   ダンプディレクトリ
     * @param dbConn    接続情報
     */
    DumpResult restore(String tableName, Path dumpDir, DbConnectionInfo dbConn);

    /**
     * psql \COPY TO (FORMAT binary) — クライアント向けエクスポート
     */
    DumpResult dumpToCopy(PgTableConfig config, List<String> facilityCodes,
                          Path dbSubDir, DbConnectionInfo dbConn);

    /**
     * psql \COPY FROM (FORMAT binary) — クライアントアップロード対応リストア
     */
    DumpResult restoreFromCopy(String tableName, Path dbSubDir, DbConnectionInfo dbConn);
}
