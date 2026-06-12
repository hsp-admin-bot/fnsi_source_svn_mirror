# 03 モジュール設計文書

> **技術スタック**: Amazon Corretto 25.0.3 / Spring Boot 4.0.6 / Spring Batch 6.0.x / Gradle 9.5.0
> **パッケージルート**: `com.fns.migration`（実装パッケージ）/ `com.fnsi.cloudconverter`（設計上の名称）

---

## モジュール一覧

| # | モジュール名 | パッケージ | グループ |
|---|------------|---------|---------|
| 1 | 認証モジュール | `auth` | 認証 |
| 2 | PG ダンプ/リストアモジュール | `migration.pg` | データ導出入 |
| 3 | Mongo ダンプ/インポートモジュール | `migration.mongo` | データ導出入 |
| 4 | SEQ バッチ申請モジュール | `mapping.seq` | PK/FK 処理 |
| 5 | PK マッピングモジュール | `mapping.pk` | PK/FK 処理 |
| 6 | FK 設定検索モジュール（PG） | `mapping.fk` | PK/FK 処理 |
| 7 | FK 設定検索モジュール（Mongo） | `mapping.fkmongo` | PK/FK 処理 |
| 8 | PG FK 刷新モジュール | `refresh.pg` | PK/FK 処理 |
| 9 | Mongo FK 刷新モジュール | `refresh.mongo` | PK/FK 処理 |
| 10 | ファイル名 PK 置換モジュール | `refresh.file` | PK/FK 処理 |
| 11 | 圧縮/解凍モジュール | `util.archive` | ファイル処理 |
| 12 | JOB 制御モジュール | `job` | フロー制御 |
| 13 | Task 制御モジュール | `task` | フロー制御 |
| 14 | ログ出力モジュール | `log` | ログ通信 |
| 15 | アップロード/ダウンロードモジュール | `transfer` | ログ通信 |
| 16 | 施設一覧モジュール | `facility` | データ管理 |
| 17 | 在線生産 PG Clear モジュール | `clear.online.pg` | データ管理 |
| 18 | 中転 PG Clear モジュール | `clear.transit.pg` | データ管理 |
| 19 | 在線生産 Mongo Clear モジュール | `clear.online.mongo` | データ管理 |
| 20 | 中転 Mongo Clear モジュール | `clear.transit.mongo` | データ管理 |
| 21 | 在線生産ファイル Clear モジュール | `clear.online.file` | データ管理 |
| 22 | 中転ファイル Clear モジュール | `clear.transit.file` | データ管理 |

---

## グループ 1: 認証モジュール

### Module 1 — 認証モジュール (`auth`)

**職責**:
- Spring Security + JWT を使用したユーザー認証
- アクセストークン（1時間）とリフレッシュトークン（24時間）の発行
- JWT フィルターによる全 API リクエストの認証
- 長時間 JOB 実行中の JWT 自動続約（API リクエスト毎に残り有効期限チェック）
- 二段式認証オプション（設定による有効/無効）

**入力**: ユーザー名・パスワード、リフレッシュトークン
**出力**: JWT アクセストークン、リフレッシュトークン

**関鍵インターフェース**:
```java
package com.fnsi.cloudconverter.auth;

// 認証サービス
public interface AuthService {
    LoginResponse login(LoginRequest request);
    RefreshResponse refresh(String refreshToken);
    // API リクエスト毎に呼ばれる: 残り有効期限 < threshold の場合に新トークン返却
    Optional<String> renewIfNearExpiry(String currentToken);
}

// JWT ユーティリティ
public interface JwtTokenProvider {
    String generateAccessToken(UserDetails userDetails);
    String generateRefreshToken(UserDetails userDetails);
    boolean validateToken(String token);
    String getUsernameFromToken(String token);
    long getExpiryMillis(String token);
}

// Spring Security フィルター
// OncePerRequestFilter を継承
public class JwtAuthenticationFilter extends OncePerRequestFilter {
    // Authorization ヘッダーから JWT を取得・検証・SecurityContext に設定
    // 残り有効期限チェックし、Response ヘッダーに新トークンをセット
}
```

**依存関係**: Spring Security、JJWT、Spring Data JPA（UserDetailsService）

---

## グループ 2: データ導出入モジュール

### Module 2 — PG ダンプ/リストアモジュール (`migration.pg`)

**職責**:
- `pg_dump_config.yaml` の読み込みと direction フィルタリング
- `pg_dump` コマンド構築・実行（ProcessBuilder）
- `pg_restore` コマンド構築・実行（並列オプション `-j`）
- テーブルごとの `WHERE` 節（`facility_cd IN (:list)`）適用
- 実行ログを `migration_task_log` に記録

**入力**: `PgDumpConfig`（YAML）、テーブル名、施設コードリスト、DB 接続情報
**出力**: ダンプファイルディレクトリ、またはリストア完了

**関鍵インターフェース**:
```java
package com.fnsi.cloudconverter.migration.pg;

public interface PgDumpService {
    /**
     * pg_dump を実行してダンプディレクトリを生成する
     * @param config テーブル設定
     * @param facilityCodes 対象施設コード
     * @param outputDir 出力ディレクトリパス
     * @param dbKey 対象 DB キー（"db1"/"db2"/"db3"）
     */
    DumpResult dump(PgTableConfig config, List<String> facilityCodes,
                    Path outputDir, String dbKey);

    /**
     * pg_restore を実行してダンプを DB にインポートする
     * @param dumpDir ダンプディレクトリパス
     * @param targetDb ターゲット DB 接続情報
     * @param parallelJobs 並列実行数（-j オプション）
     */
    RestoreResult restore(Path dumpDir, DbConnectionInfo targetDb, int parallelJobs);
}

@ConfigurationProperties(prefix = "pg-dump")
public class PgDumpConfig {
    private List<PgTableConfig> tables;
}

public class PgTableConfig {
    private String name;          // テーブル名
    private String idColumn;      // PK カラム名
    private boolean dump;         // ダンプ対象か
    private String whereTemplate; // WHERE テンプレート
    private boolean toZip;        // ZIP 圧縮するか
    private String direction;     // both / off2on / on2off
}
```

**依存関係**: Module 11（圧縮/解凍）、Module 14（ログ）

---

### Module 3 — Mongo ダンプ/インポートモジュール (`migration.mongo`)

**職責**:
- `mongo_dump_config.yaml` の読み込みと設定管理
- `mongoexport` コマンド構築・実行（ストリーム出力）
- `jq 'del(._id)'` パイプライン処理（`_id` 削除）
- `mongoimport` コマンド構築・実行（ストリーム入力）
- `filterField`（例: `facility_cd`）による施設フィルタリング

**入力**: `MongoDumpConfig`（YAML）、コレクション名、施設コードリスト、Mongo 接続情報
**出力**: JSON エクスポートファイル、またはインポート完了

**関鍵インターフェース**:
```java
package com.fnsi.cloudconverter.migration.mongo;

public interface MongoMigrationService {
    /**
     * mongoexport | jq 'del(._id)' をパイプ実行して JSON 出力
     */
    ExportResult export(MongoCollectionConfig config,
                        List<String> facilityCodes, Path outputDir);

    /**
     * mongoexport | jq 'del(._id)' | mongoimport をストリームパイプ実行
     */
    StreamResult exportAndImport(MongoCollectionConfig config,
                                  List<String> facilityCodes,
                                  MongoConnectionInfo targetConn);
}

@ConfigurationProperties(prefix = "mongo-dump")
public class MongoDumpConfig {
    private List<MongoCollectionConfig> collections;
}

public class MongoCollectionConfig {
    private String name;        // コレクション名
    private boolean dump;       // ダンプ対象か
    private String filterField; // 施設フィルタフィールド名
    private boolean toZip;      // ZIP 圧縮するか
}
```

**依存関係**: Module 11（圧縮/解凍）、Module 14（ログ）

---

## グループ 3: PK/FK 処理モジュール

### Module 4 — SEQ バッチ申請モジュール (`mapping.seq`)

**職責**:
- 在線生産 RDS の各テーブルシーケンスから、必要件数分の連番を一括取得
- `SELECT nextval('{table}_id_seq') FROM generate_series(1, {count})` などで一括発行
- 取得した SEQ リストを PK マッピング生成モジュールへ渡す

**入力**: テーブル名、必要 SEQ 件数
**出力**: `List<Long>` 新 ID リスト

**関鍵インターフェース**:
```java
package com.fnsi.cloudconverter.mapping.seq;

public interface SeqBatchService {
    /**
     * 指定テーブルのシーケンスから count 個の連番を一括取得
     * @param tableName テーブル名（ホワイトリスト検証済み）
     * @param count 必要件数
     * @return 新規 ID リスト
     */
    List<Long> fetchNextIds(String tableName, int count);
}
```

**依存関係**: 在線生産 RDS DataSource（JdbcTemplate）

---

### Module 5 — PK マッピングモジュール (`mapping.pk`)

**職責**:
- `pk_mapping` 分区テーブルへの新旧 PK ペアの一括 INSERT
- テーブル名による高速検索（`WHERE table_name = ? AND old_id = ?`）
- 在線→離線フロー用: クライアント提供の開始 SEQ から累加して新 ID を生成
- バッチ INSERT（JDBC バッチ更新）での高速処理

**入力**: テーブル名、旧 ID リスト、新 ID リスト
**出力**: `pk_mapping` テーブルへのデータ挿入完了

**関鍵インターフェース**:
```java
package com.fnsi.cloudconverter.mapping.pk;

public interface PkMappingService {
    /**
     * 新旧 PK ペアを pk_mapping テーブルに一括 INSERT
     */
    void insertBatch(String tableName, List<Long> oldIds, List<Long> newIds);

    /**
     * 旧 ID → 新 ID の変換（単一）
     */
    Optional<Long> findNewId(String tableName, long oldId);

    /**
     * テーブルの全 PK マッピング取得（FK 刷新用）
     * @return Map<oldId, newId>
     */
    Map<Long, Long> findAllMappings(String tableName);

    /**
     * 在線→離線用: 旧 ID リストと開始 SEQ から pk_mapping を生成
     * @param startSeq 開始シーケンス値
     */
    void generateFromStartSeq(String tableName, List<Long> oldIds, long startSeq);
}
```

**依存関係**: `pk_mapping` テーブル（JdbcTemplate）

---

### Module 6 — FK 設定検索モジュール（PG）(`mapping.fk`)

**職責**:
- `fk_migration_config` テーブルの検索
- `enabled=true` のレコードを `execution_order` 昇順で取得
- テーブル名・FK タイプ（COLUMN/JSON）による絞り込み検索

**入力**: 検索条件（テーブル名、FK タイプ、有効フラグ）
**出力**: `List<FkMigrationConfig>`

**関鍵インターフェース**:
```java
package com.fnsi.cloudconverter.mapping.fk;

public interface FkConfigRepository extends JpaRepository<FkMigrationConfig, Long> {
    List<FkMigrationConfig> findByEnabledTrueOrderByExecutionOrderAsc();
    List<FkMigrationConfig> findByTableNameAndEnabledTrue(String tableName);
    List<FkMigrationConfig> findByFkTypeAndEnabledTrue(String fkType);
}

@Entity
@Table(name = "fk_migration_config")
public class FkMigrationConfig {
    private Long id;
    private String tableName;
    private String fkType;       // "COLUMN" / "JSON"
    private String columnName;
    private String jsonColumn;
    private String jsonPath;
    private String refTable;
    private int executionOrder;
    private boolean enabled;
    private String remark;
}
```

**依存関係**: Spring Data JPA

---

### Module 7 — FK 設定検索モジュール（Mongo）(`mapping.fkmongo`)

**職責**:
- `fk_mongo_migration_config` テーブルの検索
- コレクション名・フィールドパス・参照テーブル名による絞り込み

**入力**: 検索条件（コレクション名、有効フラグ）
**出力**: `List<FkMongoMigrationConfig>`

**関鍵インターフェース**:
```java
package com.fnsi.cloudconverter.mapping.fkmongo;

public interface FkMongoConfigRepository extends JpaRepository<FkMongoMigrationConfig, Long> {
    List<FkMongoMigrationConfig> findByEnabledTrue();
    List<FkMongoMigrationConfig> findByCollectionNameAndEnabledTrue(String collectionName);
}

@Entity
@Table(name = "fk_mongo_migration_config")
public class FkMongoMigrationConfig {
    private Long id;
    private String collectionName;
    private String fieldPath;       // dot path, [] 配列サポート
    private String refTableName;
    private boolean enabled;
    private String remark;
}
```

**依存関係**: Spring Data JPA

---

### Module 8 — PG FK 刷新モジュール (`refresh.pg`)

**職責**:
- `fk_migration_config` の COLUMN 型 FK を UPDATE 文で刷新
- JSON 型 FK を `jsonb_set` 関数で更新
- `execution_order` 順に 1 外键参照ずつ逐次処理
- SQL インジェクション対策: テーブル名・カラム名のホワイトリスト検証

**入力**: `FkMigrationConfig` リスト、中転 DB JdbcTemplate
**出力**: 更新件数（各 FK ごと）

**関鍵インターフェース**:
```java
package com.fnsi.cloudconverter.refresh.pg;

public interface FkRefreshService {
    /**
     * COLUMN 型 FK を更新
     */
    int refreshColumnFk(FkMigrationConfig config, JdbcTemplate transitJdbc);

    /**
     * JSON 型 FK を jsonb_set で更新
     */
    int refreshJsonFk(FkMigrationConfig config, JdbcTemplate transitJdbc);

    /**
     * fk_migration_config の全有効レコードを順次処理
     */
    FkRefreshResult refreshAll(JdbcTemplate transitJdbc);
}
```

**依存関係**: Module 5（PK マッピング）、Module 6（FK 設定）、Module 14（ログ）

---

### Module 9 — Mongo FK 刷新モジュール (`refresh.mongo`)

**職責**:
- `fk_mongo_migration_config` の `field_path`（dot path）に従って MongoDB ドキュメントの FK を更新
- `[]` 配列表記サポート（ネストした配列全要素を走査）
- `pk_mapping` を参照して旧 ID → 新 ID に置換
- バルク更新（BulkWrite）での高速処理

**入力**: `FkMongoMigrationConfig` リスト、中転 Mongo 接続情報
**出力**: 更新ドキュメント件数

**関鍵インターフェース**:
```java
package com.fnsi.cloudconverter.refresh.mongo;

public interface MongoFkRefreshService {
    /**
     * dot path（[] 配列サポート）で Mongo ドキュメントの FK を刷新
     * 例: "items[].item_id" → 配列内全要素の item_id を更新
     */
    MongoRefreshResult refreshByFieldPath(FkMongoMigrationConfig config,
                                           MongoDatabase transitDb);

    /**
     * fk_mongo_migration_config の全有効レコードを処理
     */
    MongoRefreshResult refreshAll(MongoDatabase transitDb);
}
```

**依存関係**: Module 5（PK マッピング）、Module 7（Mongo FK 設定）、Module 14（ログ）

---

### Module 10 — ファイル名 PK 置換モジュール (`refresh.file`)

**職責**:
- ファイル配置フォルダを対象ディレクトリにコピー
- PK 関連フォルダ名（数値名のフォルダ）を `pk_mapping` を参照して新 ID のフォルダ名に変更
- 再帰的なフォルダツリーの走査
- 大量ファイルの効率的なコピー（NIO2 Files.copy）

**入力**: ソースディレクトリ、ターゲットディレクトリ、`pk_mapping` テーブル参照
**出力**: フォルダ名置換・コピー完了

**関鍵インターフェース**:
```java
package com.fnsi.cloudconverter.refresh.file;

public interface FileRenameRefreshService {
    /**
     * ソースディレクトリをターゲットにコピーしつつ、
     * PK 関連フォルダ名を pk_mapping を参照して置換する
     * @param sourceDir コピー元
     * @param targetDir コピー先
     * @param tableName pk_mapping の参照テーブル名
     */
    FileRefreshResult copyAndRename(Path sourceDir, Path targetDir, String tableName);
}
```

**依存関係**: Module 5（PK マッピング）、Module 14（ログ）

---

## グループ 4: ファイル処理モジュール

### Module 11 — 圧縮/解凍モジュール (`util.archive`)

**職責**:
- ZIP 圧縮・解凍（java.util.zip + NIO2）
- 大ファイル対応（ストリーミング処理）
- 通用解凍ソフト（7-Zip、WinRAR など）での展開を保証する標準 ZIP 形式

**入力**: ソースパス（ファイルまたはディレクトリ）、出力パス
**出力**: ZIP ファイルまたは解凍ディレクトリ

**関鍵インターフェース**:
```java
package com.fnsi.cloudconverter.util.archive;

public interface ArchiveService {
    /**
     * ディレクトリまたはファイルを ZIP 圧縮
     */
    Path compress(Path source, Path outputZip);

    /**
     * ZIP ファイルを解凍
     */
    Path decompress(Path zipFile, Path targetDir);
}
```

---

## グループ 5: フロー制御モジュール

### Module 12 — JOB 制御モジュール (`job`)

**職責**:
- `migration_job` テーブルの CRUD
- JOB 起動（非同期 Task チェーンの開始）
- JOB 中断（実行中 Task への中断シグナル送信）
- JOB 再開（FAILED Task → PENDING リセット → 再実行）
- 施設ごとの並行ロック（`facility_lock` 行ロック）管理

**入力**: `CreateJobRequest`、施設コードリスト、方向（direction）
**出力**: `MigrationJob` エンティティ

**関鍵インターフェース**:
```java
package com.fnsi.cloudconverter.job;

public interface JobService {
    MigrationJob createJob(CreateJobRequest request);
    void startJob(long jobId);
    void interruptJob(long jobId, String reason);
    void resumeJob(long jobId, ResumeJobRequest request);
    MigrationJob getJob(long jobId);
    JobProgressResponse getJobProgress(long jobId);
}
```

**依存関係**: Module 13（Task 制御）、Module 14（ログ）、全 clear モジュール（17-22）

---

### Module 13 — Task 制御モジュール (`task`)

**職責**:
- `migration_task` テーブルの CRUD
- Task の順次・並列実行制御（`@Async` + `CompletableFuture`）
- リトライロジック（接続エラー: 最大 3 回、5 秒間隔）
- Task 進捗の `migration_task_log` への記録
- 中断シグナル（`InterruptedFlag`）の監視

**入力**: `MigrationTask` エンティティ、Task 実行関数（`Callable<TaskResult>`）
**出力**: `TaskResult`（成功/失敗、影響行数）

**関鍵インターフェース**:
```java
package com.fnsi.cloudconverter.task;

public interface TaskExecutorService {
    /**
     * Task を実行（リトライ込み）
     */
    TaskResult execute(MigrationTask task, Callable<TaskResult> action);

    /**
     * 複数 Task を並列実行（並列可能 Task をまとめて渡す）
     */
    List<TaskResult> executeParallel(List<MigrationTask> tasks,
                                      List<Callable<TaskResult>> actions);

    /**
     * Task の状態を更新
     */
    void updateStatus(long taskId, TaskStatus status, String errorMsg);
}
```

**依存関係**: Module 14（ログ）

---

## グループ 6: ログ・通信モジュール

### Module 14 — ログ出力モジュール (`log`)

**職責**:
- `migration_task_log` テーブルへのログ書き込み（INFO/WARN/ERROR）
- ログレベル別フォーマット（開始・完了・エラー・手動中断・エラースキップ）
- クライアントからのログ読み取りリクエスト対応（オフセットポーリング）
- 非同期ログ書き込み（メインスレッドをブロックしない）

**入力**: Task ID、ログレベル、メッセージ
**出力**: `migration_task_log` テーブルへ挿入

**関鍵インターフェース**:
```java
package com.fnsi.cloudconverter.log;

public interface MigrationLogService {
    void info(long taskId, String message);
    void warn(long taskId, String message);
    void error(long taskId, String message, Throwable cause);

    /**
     * クライアント向けログ取得（オフセットポーリング対応）
     */
    LogQueryResult fetchLogs(long jobId, long offset, int limit,
                              String level, Long taskId);
}
```

---

### Module 15 — アップロード/ダウンロードモジュール (`transfer`)

**職責**:
- マルチパートファイルアップロード受信・一時ディレクトリ展開
- 大ファイル転送（ストリーミング、チャンク分割）
- ダウンロード用 ZIP アーカイブ生成・ストリーミング配信
- 転送ファイルの自動 ZIP 圧縮（通用解凍ソフト対応）

**入力**: `MultipartFile`、upload 種別、施設コード
**出力**: アップロード ID、または ZIP バイナリストリーム

**関鍵インターフェース**:
```java
package com.fnsi.cloudconverter.transfer;

public interface TransferService {
    UploadResult upload(MultipartFile file, String uploadType, String facilityCodes);
    void download(long jobId, String fileType, HttpServletResponse response);
}
```

---

## グループ 7: データ管理モジュール

### Module 16 — 施設一覧モジュール (`facility`)

**職責**:
- 在線生産 RDS の施設テーブルを検索して一覧返却
- 施設名キーワード検索、ページネーション対応
- 各テーブルの施設別データ件数集計

**関鍵インターフェース**:
```java
package com.fnsi.cloudconverter.facility;

public interface FacilityService {
    PagedResult<FacilityInfo> getFacilities(FacilitySearchCondition condition);
    TableCountResult getTableCounts(List<String> facilityCodes);
}
```

---

### Module 17 — 在線生産 PG Clear モジュール (`clear.online.pg`)

**職責**:
- 在線生産 RDS の指定施設のデータ削除（`DELETE WHERE facility_cd = ?`）
- CLEAR 前に確認ログを記録
- 外键制約の順序を考慮した削除順序制御

**関鍵インターフェース**:
```java
public interface OnlinePgClearService {
    void clearFacilityData(List<String> facilityCodes, JdbcTemplate prodJdbc);
}
```

---

### Module 18 — 中転 PG Clear モジュール (`clear.transit.pg`)

**職責**:
- 中転 DB の指定施設のデータ削除

**関鍵インターフェース**:
```java
public interface TransitPgClearService {
    void clearFacilityData(List<String> facilityCodes, JdbcTemplate transitJdbc);
}
```

---

### Module 19 — 在線生産 Mongo Clear モジュール (`clear.online.mongo`)

**職責**:
- 在線生産 DocumentDB の指定施設コレクションデータ削除
- `deleteMany({ facility_cd: { $in: [...] } })`

**関鍵インターフェース**:
```java
public interface OnlineMongoClearService {
    void clearFacilityData(List<String> facilityCodes, MongoDatabase prodMongo);
}
```

---

### Module 20 — 中転 Mongo Clear モジュール (`clear.transit.mongo`)

**職責**:
- 中転 Mongo の指定施設コレクションデータ削除

**関鍵インターフェース**:
```java
public interface TransitMongoClearService {
    void clearFacilityData(List<String> facilityCodes, MongoDatabase transitMongo);
}
```

---

### Module 21 — 在線生産ファイル Clear モジュール (`clear.online.file`)

**職責**:
- AWS EFS 上の指定施設フォルダを削除（`Files.delete` 再帰）

**関鍵インターフェース**:
```java
public interface OnlineFileClearService {
    void clearFacilityFiles(List<String> facilityCodes, Path efsRootPath);
}
```

---

### Module 22 — 中転ファイル Clear モジュール (`clear.transit.file`)

**職責**:
- 中転ファイル領域（`/tmp/migration/{jobId}/files/`）の指定施設フォルダを削除

**関鍵インターフェース**:
```java
public interface TransitFileClearService {
    void clearFacilityFiles(List<String> facilityCodes, Path transitFilePath);
}
```

---

## モジュール依存関係図

```
┌─────────────────────────────────────────────────────────────┐
│                      Controller 層                           │
│  JobController  FileController  FacilityController  Auth    │
└────────────────────────────┬────────────────────────────────┘
                             │
┌────────────────────────────▼────────────────────────────────┐
│                    Service 層 (フロー制御)                    │
│           Module 12 (JobService)                            │
│                     │                                        │
│           Module 13 (TaskExecutorService)                   │
└──────────┬──────────┬──────────┬──────────┬────────────────┘
           │          │          │          │
    ┌──────▼──┐ ┌─────▼────┐ ┌──▼────┐ ┌──▼────────────┐
    │ Mod 2   │ │ Mod 3    │ │ Mod 4 │ │   Mod 5       │
    │ PgDump  │ │ MongoDump│ │ Seq   │ │   PkMapping   │
    └────┬────┘ └────┬─────┘ └───────┘ └───────┬───────┘
         │           │                          │
    ┌────▼────────────▼──────────────┐   ┌─────▼────────────┐
    │ Mod 11 (Archive)               │   │ Mod 6 FkConfig   │
    │ Mod 14 (Log)                   │   │ Mod 7 MongoFkConf│
    │ Mod 15 (Transfer)              │   └──────┬───────────┘
    └────────────────────────────────┘          │
                                         ┌──────▼───────────┐
                                         │ Mod 8 PgFkRefresh│
                                         │ Mod 9 MongoFkRef │
                                         │ Mod 10 FileRename│
                                         └──────────────────┘

Clear モジュール (17-22) は Module 12 から呼ばれる
```

---

## パッケージ構造例

```
com.fnsi.cloudconverter/
├── auth/
│   ├── AuthController.java
│   ├── AuthService.java
│   ├── JwtTokenProvider.java
│   └── JwtAuthenticationFilter.java
├── job/
│   ├── JobController.java
│   ├── JobService.java
│   └── model/ (MigrationJob, CreateJobRequest, ...)
├── task/
│   ├── TaskExecutorService.java
│   └── model/ (MigrationTask, TaskResult, ...)
├── migration/
│   ├── pg/ (PgDumpService, PgDumpConfig, PgTableConfig)
│   └── mongo/ (MongoMigrationService, MongoDumpConfig, ...)
├── mapping/
│   ├── seq/ (SeqBatchService)
│   ├── pk/ (PkMappingService)
│   ├── fk/ (FkConfigRepository, FkMigrationConfig)
│   └── fkmongo/ (FkMongoConfigRepository, ...)
├── refresh/
│   ├── pg/ (FkRefreshService)
│   ├── mongo/ (MongoFkRefreshService)
│   └── file/ (FileRenameRefreshService)
├── clear/
│   ├── online/
│   │   ├── pg/ (OnlinePgClearService)
│   │   ├── mongo/ (OnlineMongoClearService)
│   │   └── file/ (OnlineFileClearService)
│   └── transit/
│       ├── pg/ (TransitPgClearService)
│       ├── mongo/ (TransitMongoClearService)
│       └── file/ (TransitFileClearService)
├── facility/
│   ├── FacilityController.java
│   └── FacilityService.java
├── transfer/
│   ├── TransferController.java
│   └── TransferService.java
├── log/
│   └── MigrationLogService.java
└── util/
    └── archive/ (ArchiveService)
```
