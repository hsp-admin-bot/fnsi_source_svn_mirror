package com.fnsi.cloudconverter.migration.mongo;

import java.nio.file.Path;
import java.util.List;

/**
 * Mongo ダンプ/リストアサービス (03_module.md § Module 3)
 * BSON 形式（mongodump / mongorestore）のみ使用
 */
public interface MongoMigrationService {

    /**
     * mongodump で BSON ファイルに書き出す
     * 出力: {outputDir}/{db}/{collection}.bson
     * @param config         コレクション設定
     * @param facilityCodes  施設コードフィルター（null/空の場合は全件）
     * @param outputDir      出力ルートディレクトリ
     * @param mongoConn      接続情報
     */
    StreamResult dump(MongoCollectionConfig config, List<String> facilityCodes,
                      Path outputDir, MongoConnectionInfo mongoConn);

    StreamResult dump(MongoCollectionConfig config, List<String> facilityCodes,
                      Path outputDir, MongoConnectionInfo mongoConn, MongoToolProfile toolProfile);

    /**
     * mongorestore で BSON ファイルからコレクションをリストアする
     * @param collectionName コレクション名
     * @param bsonFile       入力 BSON ファイルパス ({outputDir}/{db}/{col}.bson)
     * @param mongoConn      接続情報
     * @param drop           true: --drop でコレクション全体を置換、false: 追記（他施設データ保持）
     */
    StreamResult restoreCollection(String collectionName, Path bsonFile,
                                   MongoConnectionInfo mongoConn, boolean drop);

    StreamResult restoreCollection(String collectionName, Path bsonFile,
                                   MongoConnectionInfo mongoConn, boolean drop, MongoToolProfile toolProfile);
}
