# 01 業務フロー設計文書

> **対象システム**: FNSi Cloud Converter
> **バージョン**: 1.0
> **作成日**: 2026-02-25

---

## 1. システム全体アーキテクチャ

```
┌─────────────────────────────────────────────────────────────────────────┐
│                          クライアント (CLI / Web UI)                      │
│                     JWT 認証 ／ REST API ／ 1秒ポーリング                  │
└────────────────────────────────┬────────────────────────────────────────┘
                                 │ HTTPS
┌────────────────────────────────▼────────────────────────────────────────┐
│                    FNSi Cloud Converter (Spring Boot 4.0.6)               │
│  ┌─────────────┐  ┌─────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │ AuthFilter   │  │ JobController│  │ FileController│  │FacilityCtrl │  │
│  │ (JWT Guard)  │  │             │  │              │  │             │  │
│  └─────────────┘  └──────┬──────┘  └──────┬───────┘  └─────────────┘  │
│                           │                │                             │
│  ┌────────────────────────▼────────────────▼──────────────────────────┐ │
│  │                    Job / Task Engine (Spring Batch 6.0.x)               │ │
│  │  JobService ─→ TaskExecutor ─→ [Task1 … Task10]                    │ │
│  └───────┬──────────────────────────────────────────┬─────────────────┘ │
│          │                                           │                   │
│  ┌───────▼────────────┐                   ┌─────────▼────────────────┐  │
│  │  変換ライブラリ群   │                   │     設定ファイル群        │  │
│  │  PkMappingService  │                   │  pg_dump_config.yaml      │  │
│  │  FkRefreshService  │                   │  mongo_dump_config.yaml   │  │
│  │  MongoFkService    │                   │                           │  │
│  │  FileRenameService │                   └──────────────────────────┘  │
│  └────────────────────┘                                                  │
└──────────────────────────────────────────────────────────────────────────┘
          │ JDBC                    │ MongoDriver        │ Files API
┌─────────▼──────────┐  ┌──────────▼─────────┐  ┌──────▼──────────────┐
│  中転DB (PG17×3)   │  │  中転Mongo (Mongo8) │  │  中転ファイル領域    │
│  transit_db_1/2/3  │  │  transit_mongo      │  │  /tmp/migration/...  │
└─────────┬──────────┘  └──────────┬─────────┘  └──────┬──────────────┘
          │ pg_dump/restore         │ mongoexport/import  │ rsync/copy
┌─────────▼──────────┐  ┌──────────▼─────────┐  ┌──────▼──────────────┐
│  在線生産DB         │  │  在線生産Mongo      │  │  AWS EFS            │
│  AWS RDS PG17      │  │  AWS DocumentDB 8   │  │  (マウント済みパス)   │
└────────────────────┘  └────────────────────┘  └─────────────────────┘
```

---

## 2. 離線 → 在線 完整フロー（10 Task）

### 2.1 フロー概要

```
Client                      Server (JobEngine)              外部資源
  │                               │                              │
  │──[POST /auth/login]──────────▶│                              │
  │◀─[200 JWT token]──────────────│                              │
  │                               │                              │
  │──[POST /upload (dump files)]─▶│                              │
  │◀─[202 uploadId]───────────────│                              │
  │                               │                              │
  │──[POST /jobs {facilityList}]─▶│                              │
  │◀─[202 jobId]──────────────────│                              │
  │                               │                              │
  │  (1秒ポーリング開始)           │                              │
  │──[GET /jobs/{jobId}]─────────▶│                              │
  │◀─[200 status=RUNNING]─────────│                              │
  │     :  :  :                   │                              │
  │                               │──TASK1: PG Import───────────▶│RDS×3
  │                               │──TASK2: PK Mapping──────────▶│RDS SEQ
  │                               │──TASK3: PK Refresh──────────▶│transit
  │                               │──TASK4: FK Refresh (COLUMN)─▶│transit
  │                               │──TASK5: Mongo Import────────▶│transit
  │                               │──TASK6: Mongo FK Refresh────▶│transit
  │                               │──TASK7: PG Export───────────▶│transit
  │                               │──TASK8: PG Restore to Prod──▶│RDS Prod
  │                               │──TASK9: Mongo Export+Import─▶│DocDB
  │                               │──TASK10: File Copy──────────▶│EFS
  │                               │                              │
  │◀─[200 status=DONE]────────────│                              │
```

### 2.2 各 Task 詳細説明

#### Task 1 — PG ダンプファイル → 中転 DB インポート
- **入力**: クライアントからアップロードされた dump ディレクトリ（3 インスタンス分）
- **処理**: `pg_restore -Fd -j 8 -d transit_db_{1,2,3} {dump_dir}`
- **出力**: 中転 DB に離線データが展開される
- **データフロー**: `uploadDir/pg_dump/ → transit_db_1, transit_db_2, transit_db_3`
- **備考**: 3 インスタンスは並列実行可能

#### Task 2 — PK マッピング生成
- **入力**: `pk_mapping_config`（テーブル一覧）、中転 DB の各テーブル件数
- **処理**:
  1. 中転 DB の対象テーブルを 1 テーブルずつループ
  2. `SELECT COUNT(*) FROM {table}` で件数取得
  3. 在線生産 RDS の SEQ 発行 API を件数分一括リクエスト（`/internal/seq/batch`）
  4. `pk_mapping` テーブルへ `(table_name, old_id, new_id)` を一括 INSERT
- **出力**: `pk_mapping` テーブルに新旧 PK 対照データ挿入完了
- **データフロー**: `transit_db → pk_mapping → online_rds(SEQ)`

#### Task 3 — PK 刷新（中転 DB）
- **入力**: `pk_mapping` テーブル
- **処理**: テーブルごとに `UPDATE {table} SET id = new_id WHERE id = old_id`
- **出力**: 中転 DB の全テーブルの PK が新しい値に更新される
- **データフロー**: `pk_mapping → transit_db(各テーブル)`

#### Task 4 — FK 刷新（COLUMN 型 & JSON 型）
- **入力**: `fk_migration_config` テーブル（enabled=true のレコード群）
- **処理**:
  - COLUMN 型: `UPDATE {table} SET {col} = pm.new_id FROM pk_mapping pm WHERE {col} = pm.old_id AND pm.table_name = '{ref_table}'`
  - JSON 型: `jsonb_set` 関数で JSON フィールド内の旧 ID を新 ID に置換
  - `execution_order` 昇順で 1 外键参照ずつ逐次処理
- **出力**: 中転 DB の全 FK が新しい PK 値に対応
- **データフロー**: `fk_migration_config + pk_mapping → transit_db(各テーブル)`

#### Task 5 — Mongo ダンプ → 中転 Mongo インポート
- **入力**: アップロードされた mongoexport JSON ファイル群
- **処理**: `mongoimport --db transit_mongo --collection {col} --file {file}.json`
- **出力**: 中転 Mongo に離線データが展開される
- **データフロー**: `uploadDir/mongo_dump/ → transit_mongo`

#### Task 6 — Mongo FK 刷新
- **入力**: `fk_mongo_migration_config`、`pk_mapping`
- **処理**:
  - dot path 形式（`field_path`）で MongoDB ドキュメントの旧 ID フィールドを検索
  - `[]` 配列パスは全要素を走査
  - 旧 ID → 新 ID に更新（`pk_mapping` 参照）
- **出力**: 中転 Mongo の全 FK フィールドが新 ID 値に更新
- **データフロー**: `fk_mongo_migration_config + pk_mapping → transit_mongo`

#### Task 7 — 中転 DB → pg_dump（中転データ Export）
- **入力**: `pg_dump_config.yaml`（direction: both / off2on のテーブル）
- **処理**: テーブルごとに `pg_dump -Fd -j 8 --table={table} -f {exportDir}/{table} transit_db_{n}`
- **出力**: エクスポートディレクトリにダンプファイル生成
- **データフロー**: `transit_db → exportDir/pg_dump/`

#### Task 8 — エクスポートダンプ → 在線生産 RDS インポート
- **入力**: Task 7 で生成したダンプファイル群
- **処理**: `pg_restore -Fd -j 8 -d prod_rds {exportDir}/{table}`
- **前処理**: 対象施設データが生産 RDS に存在する場合は CLEAR 処理（Module 17）
- **出力**: 在線生産 RDS に新 PK/FK でデータ挿入完了
- **データフロー**: `exportDir/pg_dump/ → prod_rds`

#### Task 9 — 中転 Mongo → 在線生産 DocumentDB（Export & Import）
- **入力**: `mongo_dump_config.yaml`（dump=true の collection）
- **処理**: `mongoexport ... | jq 'del(._id)' | mongoimport --db prod_mongo --collection {col}`
- **前処理**: 対象施設コレクションが DocumentDB に存在する場合は CLEAR 処理（Module 19）
- **出力**: 在線生産 DocumentDB にデータ挿入完了
- **データフロー**: `transit_mongo → (stream) → prod_documentdb`

#### Task 10 — ファイルコピー & フォルダ名 PK 置換
- **入力**: アップロードされたファイル群、`pk_mapping` テーブル
- **処理**:
  1. ファイル配置フォルダを EFS マウントパスへコピー
  2. フォルダ名が PK 関連の場合、`pk_mapping` を参照してフォルダ名を新 ID に置換
- **前処理**: EFS に同施設のファイルが存在する場合は CLEAR 処理（Module 21）
- **出力**: EFS に新 PK でファイル配置完了
- **データフロー**: `uploadDir/files/ + pk_mapping → EFS`

---

## 3. 在線 → 離線 完整フロー（10 Task）

### 3.1 フロー概要

```
Client                      Server (JobEngine)              外部資源
  │                               │                              │
  │──[POST /auth/login]──────────▶│                              │
  │◀─[200 JWT token]──────────────│                              │
  │                               │                              │
  │──[GET /facilities]───────────▶│                              │
  │◀─[200 facilityList]───────────│                              │
  │                               │                              │
  │──[GET /facilities/count]─────▶│                              │
  │◀─[200 tableRowCounts]─────────│                              │
  │                               │                              │
  │  (クライアント側: 離線DBで SEQ確保、開始SEQを算出)           │
  │                               │                              │
  │──[POST /jobs {facilityList,   │                              │
  │    seqStartMap}]─────────────▶│                              │
  │◀─[202 jobId]──────────────────│                              │
  │                               │                              │
  │  (1秒ポーリング開始)           │                              │
  │──[GET /jobs/{jobId}]─────────▶│                              │
  │     :  :  :                   │                              │
  │                               │──TASK1: PG Export (Prod)────▶│RDS Prod
  │                               │──TASK2: PG Import (Transit)─▶│transit
  │                               │──TASK3: Mongo Export+Import─▶│transit
  │                               │──TASK4: PK Mapping──────────▶│transit
  │                               │──TASK5: PK Refresh──────────▶│transit
  │                               │──TASK6: FK Refresh (COLUMN)─▶│transit
  │                               │──TASK7: Mongo FK Refresh────▶│transit
  │                               │──TASK8: PG Export (Transit)─▶│exportDir
  │                               │──TASK9: Mongo Export────────▶│exportDir
  │                               │──TASK10: File Copy──────────▶│exportDir
  │                               │                              │
  │◀─[200 status=DONE]────────────│                              │
  │                               │                              │
  │──[GET /download/{jobId}/pg]──▶│                              │
  │◀─[200 pg_dump.zip]────────────│                              │
  │──[GET /download/{jobId}/mongo]▶│                              │
  │◀─[200 mongo_dump.zip]─────────│                              │
  │──[GET /download/{jobId}/files]▶│                              │
  │◀─[200 files.zip]──────────────│                              │
```

### 3.2 各 Task 詳細説明

#### Task 1 — 在線生産 RDS → pg_dump（Export）
- **入力**: `pg_dump_config.yaml`（direction: both / on2off）、`facility_cd` リスト
- **処理**: `pg_dump -Fd -j 8 --table={table} --where="facility_cd IN ({list})" -f {exportDir}/{table} prod_rds_{n}`
- **前処理**: 中転 DB に同施設データが存在する場合は CLEAR（Module 18）
- **出力**: 中転 DB インポート用ダンプファイル
- **データフロー**: `prod_rds → exportDir/pg_dump_raw/`

#### Task 2 — ダンプ → 中転 DB インポート
- **入力**: Task 1 のダンプファイル
- **処理**: `pg_restore -Fd -j 8 -d transit_db_{n} {exportDir}/pg_dump_raw/{table}`
- **出力**: 中転 DB に在線データ展開
- **データフロー**: `exportDir/pg_dump_raw/ → transit_db`

#### Task 3 — 在線 Mongo → 中転 Mongo（Export & Import）
- **入力**: `mongo_dump_config.yaml`、`facility_cd` リスト
- **処理**: `mongoexport --query='{facility_cd:{$in:[...]}}' | jq 'del(._id)' | mongoimport transit_mongo`
- **前処理**: 中転 Mongo に同施設データが存在する場合は CLEAR（Module 20）
- **出力**: 中転 Mongo に在線データ展開
- **データフロー**: `prod_documentdb → (stream) → transit_mongo`

#### Task 4 — PK マッピング生成（クライアント指定 SEQ 起点）
- **入力**: JOB 起動時の `seqStartMap`（各テーブルの開始 SEQ、クライアントが離線 DB から確保）
- **処理**:
  1. 中転 DB の各テーブルを 1 テーブルずつループ
  2. `SELECT id FROM {table} ORDER BY id` で旧 ID 列取得
  3. 開始 SEQ から 1 ずつ累加して新 ID を生成
  4. `pk_mapping` テーブルへ `(table_name, old_id, new_id)` を一括 INSERT
- **出力**: `pk_mapping` テーブルに新旧 PK 対照データ
- **データフロー**: `seqStartMap + transit_db → pk_mapping`

#### Task 5 — PK 刷新（中転 DB）
- **処理**: Task 3（離線→在線）と同一ロジック
- **データフロー**: `pk_mapping → transit_db`

#### Task 6 — FK 刷新（COLUMN 型 & JSON 型）
- **処理**: Task 4（離線→在線）と同一ロジック
- **データフロー**: `fk_migration_config + pk_mapping → transit_db`

#### Task 7 — Mongo FK 刷新
- **処理**: Task 6（離線→在線）と同一ロジック
- **データフロー**: `fk_mongo_migration_config + pk_mapping → transit_mongo`

#### Task 8 — 中転 DB → pg_dump（離線配布用 Export）
- **入力**: `pg_dump_config.yaml`（direction: both / on2off）
- **処理**: `pg_dump -Fd -j 8 --table={table} -f {exportDir}/pg_dump/{table} transit_db_{n}`
- **出力**: 離線 DB インポート用ダンプファイル
- **データフロー**: `transit_db → exportDir/pg_dump/`

#### Task 9 — 中転 Mongo → mongoexport（離線配布用 Export）
- **入力**: `mongo_dump_config.yaml`（dump=true）
- **処理**: `mongoexport --db transit_mongo --collection {col} | jq 'del(._id)' > {exportDir}/mongo/{col}.json`
- **出力**: 離線 Mongo インポート用 JSON ファイル
- **データフロー**: `transit_mongo → exportDir/mongo/`

#### Task 10 — ファイルコピー & フォルダ名 PK 置換（EFS → Export）
- **入力**: EFS 上の対象施設ファイル群、`pk_mapping`
- **処理**:
  1. EFS → exportDir/files/ へコピー
  2. PK 関連フォルダ名を `pk_mapping` の旧 ID で置換
- **出力**: 離線用ファイル群（古い PK でフォルダ名が整合）
- **データフロー**: `EFS + pk_mapping → exportDir/files/`

**完了後**: クライアントが `/download/{jobId}/{type}` API を呼び出し、3 種類のアーカイブをダウンロード

---

## 3.5 クライアントログアップロードフロー

```
Client (DbMigrationTool)             Server (LogUploaderController)
  │                                          │
  │  (アプリ終了イベント)                     │
  │  BusinessApiClient.IsLoggedIn == true?    │
  │        │                                  │
  │        YES                                │
  │        │                                  │
  │──[POST /ntss-admin-web/api/log/          │
  │    uploader/{appName}]──────────────────▶│
  │   Header: Authorization: Bearer {jwt}    │
  │   Content-Type: text/plain               │
  │   Body: {appName}_{yyyyMMdd}.log の      │
  │         生バイト列                        │
  │                                          │
  │                          JwtAuthFilter → JWT 検証
  │                          保存先: {log.upload.path}/
  │                                {yyyyMMdd}/{appName}_{yyyyMMdd}.log
  │                                          │
  │◀─[200 OK {success:true}]────────────────│
  │  (クライアントはレスポンスを無視)         │
```

**呼び出しタイミング**: アプリ終了時（`FormLogin_FormClosed` → `Application.Exit` 前）
**ログファイルパス（クライアント側）**: `{LogFolder}/{appName}_{yyyyMMdd}.log`
**失敗時の動作**: サイレントキャッチ（警告ログのみ）、アプリ終了をブロックしない

---

## 4. Job / Task ステータスマシン図

```
                    ┌──────────────────────────────────────────────┐
                    │               migration_job                  │
                    │                                              │
              ┌─────▼─────┐                                       │
              │   INIT    │◀── POST /jobs で作成                   │
              └─────┬─────┘                                       │
                    │ JobService.start()                           │
                    ▼                                              │
              ┌───────────┐                                        │
              │  RUNNING  │                                        │
              └─────┬─────┘                                       │
           ┌────────┤                                              │
           │        │                                              │
    全Task成功      全Task失敗 or 手動中断                          │
           │        │                                              │
           ▼        ▼                                              │
        ┌──────┐  ┌────────┐                                      │
        │ DONE │  │ FAILED │◀── DELETE /jobs/{jobId}              │
        └──────┘  └────────┘                                      │
                       │                                           │
                  POST /jobs/{jobId}/resume                       │
                       │                                           │
                       └──▶ RUNNING (FAILED Task から再開)        │
                    └──────────────────────────────────────────────┘


                    ┌──────────────────────────────────────────────┐
                    │               migration_task                 │
                    │                                              │
              ┌─────▼─────┐                                       │
              │  PENDING  │◀── JOB 開始時に一括作成                │
              └─────┬─────┘                                       │
                    │ TaskExecutor が pick up                      │
                    ▼                                              │
              ┌───────────┐                                        │
              │  RUNNING  │                                        │
              └─────┬─────┘                                       │
           ┌────────┤                                              │
           │        │ 例外発生                                     │
     処理成功        │                                              │
           │        ▼                                              │
           │  retry_count < MAX_RETRY?                            │
           │      │         │                                      │
           │      YES       NO                                     │
           │      │         │                                      │
           │  再度 RUNNING  ▼                                     │
           │            ┌────────┐                                 │
           ▼            │ FAILED │                                 │
        ┌──────┐        └────────┘                                 │
        │ DONE │                                                   │
        └──────┘                                                   │
                    └──────────────────────────────────────────────┘
```

### 4.1 リトライポリシー

| パラメータ | デフォルト値 | 説明 |
|-----------|------------|------|
| `MAX_RETRY` | 3 | 1 Task あたりの最大リトライ回数 |
| `RETRY_INTERVAL_MS` | 5000 | リトライ間隔（ミリ秒） |
| リトライ対象 | 接続エラー、タイムアウト | 業務ロジックエラーは対象外 |

---

## 5. エラー処理と断点再開フロー

### 5.1 エラー発生時の動作

```
[Task 実行中]
      │
      ├── 接続エラー / タイムアウト
      │       │
      │       ├── retry_count < 3 ──▶ 5秒後に再実行
      │       │
      │       └── retry_count == 3 ──▶ Task.status = FAILED
      │                                 last_error に例外メッセージ保存
      │                                 Job.status = FAILED
      │                                 migration_task_log へエラーログ挿入
      │
      └── 業務ロジックエラー（データ不整合など）
              │
              └── 即座に Task.status = FAILED
                  Job.status = FAILED（後続 Task は実行せず）
```

### 5.2 断点再開フロー（POST /jobs/{jobId}/resume）

```
[POST /jobs/{jobId}/resume]
      │
      ├── migration_job.status == FAILED ? チェック
      │       └── NO ──▶ 400 エラー返却
      │
      ├── migration_task を status で分類:
      │       DONE  ──▶ スキップ（再実行しない）
      │       FAILED ──▶ status = PENDING にリセット、retry_count = 0
      │       PENDING ──▶ そのまま（未実行なので継続）
      │
      ├── migration_job.status = RUNNING にリセット
      │
      └── JobService.start(jobId) 呼び出し（PENDING Task から順次実行）
```

### 5.3 並行施設ロック（DB 行ロック）

```
[新規 JOB 開始リクエスト]
      │
      ├── BEGIN TRANSACTION
      │
      ├── SELECT * FROM facility_lock
      │   WHERE facility_cd = ? FOR UPDATE NOWAIT
      │       │
      │       ├── ロック取得成功 ──▶ JOB 処理継続
      │       │
      │       └── ロック取得失敗 ──▶ 409 Conflict 返却
      │                              "該当施設は処理中です"
      │
      └── JOB 完了後 / エラー後: COMMIT / ROLLBACK（ロック解放）
```

### 5.4 ディスク空間管理

| 条件 | 処理 |
|------|------|
| JOB 正常完了（DONE） | 中転データ・エクスポートディレクトリを自動削除 |
| JOB 失敗（FAILED） | データを保持（人工確認用） |
| 断点再開完了 | 再開前と同様、完了後に自動削除 |

---

## 6. データフロー全体図

### 離線 → 在線

```
[離線版データ（クライアント持参）]
  pg_dump/*.dump  ───────────────────▶  transit_db_1/2/3
  mongo/*.json    ───────────────────▶  transit_mongo
  files/*         ───────────────────▶  /tmp/migration/{jobId}/files/

         │ PK置換（pk_mapping生成）
         ▼
  transit_db_1/2/3（PK/FK更新済み）
  transit_mongo（FK更新済み）

         │ pg_dump / mongoexport
         ▼
  exportDir/pg_dump/
  exportDir/mongo/
  exportDir/files/（フォルダ名PK置換済み）

         │ pg_restore / mongoimport
         ▼
  [在線生産環境]
  AWS RDS PG17     ◀── pg_restore
  AWS DocumentDB   ◀── mongoimport
  AWS EFS          ◀── ファイルコピー
```

### 在線 → 離線

```
[在線生産環境]
  AWS RDS PG17     ───────────────────▶  transit_db_1/2/3
  AWS DocumentDB   ───────────────────▶  transit_mongo
  AWS EFS          ───────────────────▶  /tmp/migration/{jobId}/files/

         │ PK置換（client指定SEQ起点）
         ▼
  transit_db_1/2/3（PK/FK更新済み）
  transit_mongo（FK更新済み）

         │ pg_dump / mongoexport
         ▼
  exportDir/pg_dump/（離線インポート用）
  exportDir/mongo/ （離線インポート用）
  exportDir/files/ （旧PKフォルダ名）

         │ クライアントがダウンロード
         ▼
  [離線版環境（almalinux9）]
  PG17+  ◀── pg_restore
  Mongo8+ ◀── mongoimport
  ローカルディスク ◀── ファイルコピー
```
