# 02 REST API 設計文書

> **ベースURL**: `https://{host}/api/v1`
> **認証方式**: JWT Bearer Token（`Authorization: Bearer {token}`）
> **Content-Type**: `application/json`（ファイルアップロードは `multipart/form-data`）

---

## 共通エラーレスポンス形式

```json
{
  "timestamp": "2026-02-25T10:00:00Z",
  "status": 400,
  "error": "Bad Request",
  "message": "エラーの詳細メッセージ",
  "path": "/api/v1/jobs"
}
```

## 共通エラーコード一覧

| HTTPステータス | コード | 説明 |
|--------------|--------|------|
| 400 | BAD_REQUEST | リクエストパラメータ不正 |
| 401 | UNAUTHORIZED | JWT トークン未提供・無効 |
| 403 | FORBIDDEN | 権限不足 |
| 404 | NOT_FOUND | リソースが存在しない |
| 409 | CONFLICT | 同一施設が処理中（並行ロック） |
| 500 | INTERNAL_ERROR | サーバー内部エラー |
| 503 | SERVICE_UNAVAILABLE | 外部 DB/Mongo 接続不可 |

---

## 1. POST /auth/login

**説明**: ユーザー認証を行い、JWT アクセストークンとリフレッシュトークンを返す。
認証は在線生産 DB（ntss_db4）の `mst_user_authentication` テーブルで行う。

### リクエスト

| 項目 | 値 |
|------|----|
| Method | POST |
| Path | `/auth/login` |
| 認証 | 不要 |
| Content-Type | `application/json` |

**リクエストボディ**:
```json
{
  "facilityCd": "11166",
  "dispUserId": "user01",
  "password": "your_password"
}
```

| フィールド | 型 | 必須 | 説明 |
|----------|-----|------|------|
| facilityCd | string | ✅ | 施設コード（`mst_user_authentication.facility_cd` と一致） |
| dispUserId | string | ✅ | 表示用ユーザー ID（`mst_user_authentication.disp_user_id` と一致） |
| password | string | ✅ | パスワード（BCrypt ハッシュで検証） |

### レスポンス

**200 OK**:
```json
{
  "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refreshToken": "dGhpcyBpcyBhIHJlZnJlc2ggdG9rZW4...",
  "expiresIn": 3600,
  "tokenType": "Bearer"
}
```

| フィールド | 型 | 説明 |
|----------|-----|------|
| accessToken | string | JWT アクセストークン（有効期限: 1時間） |
| refreshToken | string | リフレッシュトークン（有効期限: 24時間） |
| expiresIn | number | アクセストークン有効秒数 |
| tokenType | string | 常に "Bearer" |

**エラーコード**:
| ステータス | 条件 |
|----------|------|
| 401 | ユーザー名・パスワード不一致 |
| 423 | アカウントロック中 |

---

## 2. POST /auth/refresh

**説明**: リフレッシュトークンを使用して新しいアクセストークンを発行する。長時間 JOB 実行中のトークン維持に使用。

### リクエスト

| 項目 | 値 |
|------|----|
| Method | POST |
| Path | `/auth/refresh` |
| 認証 | 不要（リフレッシュトークン使用） |

**リクエストボディ**:
```json
{
  "refreshToken": "dGhpcyBpcyBhIHJlZnJlc2ggdG9rZW4..."
}
```

### レスポンス

**200 OK**:
```json
{
  "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...(new)",
  "expiresIn": 3600,
  "tokenType": "Bearer"
}
```

**エラーコード**:
| ステータス | 条件 |
|----------|------|
| 401 | リフレッシュトークン無効・期限切れ |

---

## 3. POST /upload

**説明**: 離線版から在線版への移行用に、ダンプファイル・Mongo エクスポートファイル・その他ファイルを一括アップロードする。

### リクエスト

| 項目 | 値 |
|------|----|
| Method | POST |
| Path | `/upload` |
| 認証 | JWT Bearer 必須 |
| Content-Type | `multipart/form-data` |

**リクエストパラメータ（form-data）**:

| フィールド | 型 | 必須 | 説明 |
|----------|-----|------|------|
| file | File | ✅ | アップロードするアーカイブファイル（.zip 形式） |
| uploadType | string | ✅ | アップロード種別: `PG_DUMP` / `MONGO_DUMP` / `FILES` |
| facilityCode | string | ✅ | 施設コード（複数の場合はカンマ区切り） |

**アップロードファイル内部構造（zip解凍後）**:
```
pg_dump.zip/
  ├── db1/
  │   ├── order_tbl/          # pg_dump -Fd 形式ディレクトリ
  │   └── order_detail/
  ├── db2/
  └── db3/

mongo_dump.zip/
  ├── orders.json
  └── invoice.json

files.zip/
  ├── {facilityCode}/
  │   └── {pk_related_folder}/
  └── ...
```

### レスポンス

**202 Accepted**:
```json
{
  "uploadId": "upload-20260225-abc123",
  "uploadType": "PG_DUMP",
  "storagePath": "/tmp/migration/upload-20260225-abc123/",
  "fileSize": 10485760,
  "uploadedAt": "2026-02-25T10:00:00Z",
  "message": "ファイルのアップロードが完了しました"
}
```

**エラーコード**:
| ステータス | 条件 |
|----------|------|
| 400 | ファイル形式不正・必須フィールド欠如 |
| 413 | ファイルサイズ超過（デフォルト上限: 50GB） |
| 507 | サーバーディスク容量不足 |

---

## 4. GET /download/{jobId}/{fileType}

**説明**: 在線 → 離線 JOB 完了後、変換済みダンプファイルやファイル群をダウンロードする。

### リクエスト

| 項目 | 値 |
|------|----|
| Method | GET |
| Path | `/download/{jobId}/{fileType}` |
| 認証 | JWT Bearer 必須 |

**パスパラメータ**:

| パラメータ | 型 | 必須 | 説明 |
|----------|-----|------|------|
| jobId | long | ✅ | JOB ID |
| fileType | string | ✅ | `pg`（PG ダンプ）/ `mongo`（Mongo エクスポート）/ `files`（ファイル群） |

### レスポンス

**200 OK**: バイナリストリーム（zip ファイル）
```
Content-Type: application/zip
Content-Disposition: attachment; filename="pg_dump_job123.zip"
Content-Length: 10485760
```

**エラーコード**:
| ステータス | 条件 |
|----------|------|
| 404 | JOB が存在しない / ファイルタイプ不正 |
| 409 | JOB がまだ完了していない（status != DONE） |

---

## 5. GET /facilities

**説明**: 在線生産 RDS から施設（Facility）一覧を取得する。在線 → 離線 フロー開始前の施設選択に使用。

### リクエスト

| 項目 | 値 |
|------|----|
| Method | GET |
| Path | `/facilities` |
| 認証 | JWT Bearer 必須 |

**クエリパラメータ**（任意）:

| パラメータ | 型 | 必須 | 説明 |
|----------|-----|------|------|
| page | int | ❌ | ページ番号（0始まり、デフォルト: 0） |
| size | int | ❌ | 1ページの件数（デフォルト: 100） |
| keyword | string | ❌ | 施設名で部分一致検索 |

### レスポンス

**200 OK**:
```json
{
  "total": 250,
  "page": 0,
  "size": 100,
  "facilities": [
    {
      "facilityCd": "FAC001",
      "facilityName": "〇〇施設",
      "region": "東京",
      "status": "ACTIVE",
      "lastMigratedAt": "2025-12-01T00:00:00Z"
    },
    {
      "facilityCd": "FAC002",
      "facilityName": "△△施設",
      "region": "大阪",
      "status": "ACTIVE",
      "lastMigratedAt": null
    }
  ]
}
```

**エラーコード**:
| ステータス | 条件 |
|----------|------|
| 503 | 在線 RDS への接続失敗 |

---

## 6. GET /facilities/count

**説明**: 指定した施設コードの各テーブルのデータ件数を取得する。在線 → 離線 フローで離線側の SEQ 確保量の計算に使用。

### リクエスト

| 項目 | 値 |
|------|----|
| Method | GET |
| Path | `/facilities/count` |
| 認証 | JWT Bearer 必須 |

**クエリパラメータ**:

| パラメータ | 型 | 必須 | 説明 |
|----------|-----|------|------|
| facility_cd | string | ✅ | 施設コード（複数はカンマ区切り例: `FAC001,FAC002`） |

**リクエスト例**:
```
GET /facilities/count?facility_cd=FAC001,FAC002
```

### レスポンス

**200 OK**:
```json
{
  "facilityCodes": ["FAC001", "FAC002"],
  "tableCounts": {
    "order_tbl": 15230,
    "order_detail": 48920,
    "invoice": 8310
  },
  "totalRows": 72460,
  "calculatedAt": "2026-02-25T10:05:00Z"
}
```

**エラーコード**:
| ステータス | 条件 |
|----------|------|
| 400 | facility_cd パラメータ未指定 |
| 503 | 在線 RDS への接続失敗 |

---

## 7. POST /jobs

**説明**: 新しい移行 JOB を作成・起動する。方向（direction）によって異なるパラメータが必要。

### リクエスト

| 項目 | 値 |
|------|----|
| Method | POST |
| Path | `/jobs` |
| 認証 | JWT Bearer 必須 |

**リクエストボディ（離線 → 在線）**:
```json
{
  "direction": "off2on",
  "facilityCodes": ["FAC001", "FAC002"],
  "uploadIds": {
    "pgDump": "upload-20260225-abc123",
    "mongoDump": "upload-20260225-def456",
    "files": "upload-20260225-ghi789"
  },
  "options": {
    "parallelTasks": 4,
    "retryLimit": 3
  }
}
```

**リクエストボディ（在線 → 離線）**:
```json
{
  "direction": "on2off",
  "facilityCodes": ["FAC001", "FAC002"],
  "seqStartMap": {
    "order_tbl": 500001,
    "order_detail": 1200001,
    "invoice": 300001
  },
  "options": {
    "parallelTasks": 4,
    "retryLimit": 3
  }
}
```

| フィールド | 型 | 必須 | 説明 |
|----------|-----|------|------|
| direction | string | ✅ | `off2on`（離線→在線）/ `on2off`（在線→離線） |
| facilityCodes | string[] | ✅ | 移行対象施設コードのリスト |
| uploadIds | object | off2on時✅ | 事前アップロードのID |
| seqStartMap | object | on2off時✅ | 各テーブルの SEQ 開始値（離線 DB で確保済み） |
| options.parallelTasks | int | ❌ | 並列実行 Task 数（デフォルト: 4） |
| options.retryLimit | int | ❌ | リトライ上限（デフォルト: 3） |

### レスポンス

**202 Accepted**:
```json
{
  "jobId": 1001,
  "jobName": "off2on_FAC001_20260225_100500",
  "direction": "off2on",
  "facilityCodes": ["FAC001", "FAC002"],
  "status": "INIT",
  "createdAt": "2026-02-25T10:05:00Z",
  "estimatedTasks": 10
}
```

**エラーコード**:
| ステータス | 条件 |
|----------|------|
| 400 | direction 不正・必須フィールド欠如 |
| 409 | 指定施設コードのいずれかが現在処理中 |
| 422 | seqStartMap に必須テーブルが不足（on2off 時） |

---

## 8. GET /jobs/{jobId}

**説明**: 指定 JOB と配下の全 Task のステータス・進捗を取得する。クライアントは 1 秒間隔でポーリングする。

### リクエスト

| 項目 | 値 |
|------|----|
| Method | GET |
| Path | `/jobs/{jobId}` |
| 認証 | JWT Bearer 必須 |

**パスパラメータ**:

| パラメータ | 型 | 必須 | 説明 |
|----------|-----|------|------|
| jobId | long | ✅ | JOB ID |

### レスポンス

**200 OK**:
```json
{
  "jobId": 1001,
  "jobName": "off2on_FAC001_20260225_100500",
  "direction": "off2on",
  "status": "RUNNING",
  "startedAt": "2026-02-25T10:05:01Z",
  "finishedAt": null,
  "elapsedSeconds": 3620,
  "tasks": [
    {
      "taskId": 5001,
      "taskName": "TASK1_PG_IMPORT",
      "phase": "IMPORT",
      "tableName": "order_tbl",
      "status": "DONE",
      "retryCount": 0,
      "estimatedRows": 15230,
      "affectedRows": 15230,
      "startedAt": "2026-02-25T10:05:02Z",
      "finishedAt": "2026-02-25T10:15:00Z",
      "lastError": null
    },
    {
      "taskId": 5002,
      "taskName": "TASK2_PK_MAPPING",
      "phase": "PK",
      "tableName": "order_tbl",
      "status": "RUNNING",
      "retryCount": 0,
      "estimatedRows": 15230,
      "affectedRows": 8000,
      "startedAt": "2026-02-25T10:15:01Z",
      "finishedAt": null,
      "lastError": null
    }
  ],
  "progress": {
    "totalTasks": 10,
    "doneTasks": 1,
    "runningTasks": 1,
    "pendingTasks": 8,
    "failedTasks": 0,
    "percentComplete": 10
  }
}
```

**エラーコード**:
| ステータス | 条件 |
|----------|------|
| 404 | JOB が存在しない |

---

## 9. GET /jobs/{jobId}/logs

**説明**: 指定 JOB のログを取得する。オフセット指定で差分取得（ポーリング）に対応。

### リクエスト

| 項目 | 値 |
|------|----|
| Method | GET |
| Path | `/jobs/{jobId}/logs` |
| 認証 | JWT Bearer 必須 |

**パスパラメータ**:

| パラメータ | 型 | 必須 | 説明 |
|----------|-----|------|------|
| jobId | long | ✅ | JOB ID |

**クエリパラメータ**:

| パラメータ | 型 | 必須 | 説明 |
|----------|-----|------|------|
| offset | long | ❌ | 取得開始 log_id（初回は 0 または未指定） |
| limit | int | ❌ | 取得件数上限（デフォルト: 200、最大: 1000） |
| level | string | ❌ | ログレベルフィルタ: `INFO`/`WARN`/`ERROR` |
| taskId | long | ❌ | 特定 Task のログのみ取得 |

**リクエスト例**:
```
GET /jobs/1001/logs?offset=500&limit=200&level=INFO
```

### レスポンス

**200 OK**:
```json
{
  "jobId": 1001,
  "logs": [
    {
      "logId": 501,
      "taskId": 5001,
      "taskName": "TASK1_PG_IMPORT",
      "logTime": "2026-02-25T10:05:05Z",
      "level": "INFO",
      "message": "[TASK1] pg_restore 開始: order_tbl (15230行)"
    },
    {
      "logId": 502,
      "taskId": 5001,
      "taskName": "TASK1_PG_IMPORT",
      "logTime": "2026-02-25T10:15:00Z",
      "level": "INFO",
      "message": "[TASK1] pg_restore 完了: order_tbl 所要時間 9分58秒"
    }
  ],
  "nextOffset": 503,
  "hasMore": true,
  "totalLogs": 3200
}
```

| フィールド | 説明 |
|----------|------|
| nextOffset | 次回ポーリング時の offset 値 |
| hasMore | まだ取得できるログが存在するか |
| totalLogs | このJOBの総ログ件数 |

**エラーコード**:
| ステータス | 条件 |
|----------|------|
| 404 | JOB が存在しない |

---

## 10. DELETE /jobs/{jobId}

**説明**: 実行中または INIT 状態の JOB を中断する。DONE/FAILED 状態の JOB には適用不可。

### リクエスト

| 項目 | 値 |
|------|----|
| Method | DELETE |
| Path | `/jobs/{jobId}` |
| 認証 | JWT Bearer 必須 |

**パスパラメータ**:

| パラメータ | 型 | 必須 | 説明 |
|----------|-----|------|------|
| jobId | long | ✅ | JOB ID |

**クエリパラメータ**:

| パラメータ | 型 | 必須 | 説明 |
|----------|-----|------|------|
| reason | string | ❌ | 中断理由（ログに記録される） |

### レスポンス

**200 OK**:
```json
{
  "jobId": 1001,
  "status": "FAILED",
  "message": "JOB を手動中断しました",
  "reason": "テスト中断",
  "interruptedAt": "2026-02-25T11:00:00Z"
}
```

**エラーコード**:
| ステータス | 条件 |
|----------|------|
| 404 | JOB が存在しない |
| 409 | JOB がすでに DONE または FAILED 状態 |

---

## 11. POST /jobs/{jobId}/resume

**説明**: FAILED 状態の JOB を断点から再開する。完了済み（DONE）の Task はスキップし、未完了の Task から実行を再開する。

### リクエスト

| 項目 | 値 |
|------|----|
| Method | POST |
| Path | `/jobs/{jobId}/resume` |
| 認証 | JWT Bearer 必須 |

**パスパラメータ**:

| パラメータ | 型 | 必須 | 説明 |
|----------|-----|------|------|
| jobId | long | ✅ | JOB ID |

**リクエストボディ**（任意）:
```json
{
  "skipFailedTasks": false,
  "note": "ネットワーク障害回復後に再開"
}
```

| フィールド | 型 | 必須 | 説明 |
|----------|-----|------|------|
| skipFailedTasks | boolean | ❌ | true の場合、FAILED Task をスキップして後続 Task から継続（デフォルト: false） |
| note | string | ❌ | 再開理由（ログに記録） |

### レスポンス

**202 Accepted**:
```json
{
  "jobId": 1001,
  "status": "RUNNING",
  "message": "JOB を再開しました",
  "resumedTasks": [
    {
      "taskId": 5002,
      "taskName": "TASK2_PK_MAPPING",
      "previousStatus": "FAILED",
      "newStatus": "PENDING"
    }
  ],
  "skippedTasks": [],
  "resumedAt": "2026-02-25T11:05:00Z"
}
```

**エラーコード**:
| ステータス | 条件 |
|----------|------|
| 404 | JOB が存在しない |
| 409 | JOB が FAILED 状態でない（RUNNING / DONE の場合） |

---

## 12. POST /ntss-admin-web/api/log/uploader/{appName}

**説明**: クライアントアプリ（DbMigrationTool 等）が終了時にローカルのログファイルをサーバーへアップロードする。
失敗してもクライアント側は無視する（fire-and-forget）。

### リクエスト

| 項目 | 値 |
|------|----|
| Method | POST |
| Path | `/ntss-admin-web/api/log/uploader/{appName}` |
| 認証 | JWT Bearer 必須 |
| Content-Type | `text/plain` |

**パスパラメータ**:

| パラメータ | 型 | 必須 | 説明 |
|----------|-----|------|------|
| appName | string | ✅ | アプリケーション名（例: `DbMigrationTool`）。URI エスケープ済み。 |

**リクエストボディ**: ログファイルの生バイト列（`text/plain`）

**保存先**: `${log.upload.path}/{yyyyMMdd}/{appName}_{yyyyMMdd}.log`
- デフォルト: `${java.io.tmpdir}/migration-client-logs/...`
- `application.yml` の `log.upload.path` で変更可能

### レスポンス

**200 OK**:
```json
{
  "success": true,
  "path": "C:/tmp/migration-client-logs/20260312/DbMigrationTool_20260312.log"
}
```

```json
// エラー時（ファイル書き込み失敗等）
{
  "success": false,
  "message": "エラーメッセージ"
}
```

**備考**:
- 認証に失敗した場合は 401 を返す（JWT 検証失敗）
- ボディが空の場合は `{"success": true, "message": "empty body"}` を返す
- 同日に同じアプリ名のログが再アップロードされた場合は上書き

---

## API 使用フロー例

### 離線 → 在線 フロー

```bash
# 1. 認証
POST /auth/login
→ { accessToken: "eyJ..." }

# 2. ファイルアップロード（3種別）
POST /upload (PG_DUMP)   → { uploadId: "upload-abc" }
POST /upload (MONGO_DUMP) → { uploadId: "upload-def" }
POST /upload (FILES)     → { uploadId: "upload-ghi" }

# 3. JOB 起動
POST /jobs { direction:"off2on", facilityCodes:["FAC001"], uploadIds:{...} }
→ { jobId: 1001, status: "INIT" }

# 4. 1秒ポーリング（JWT 自動更新）
GET /jobs/1001  → { status: "RUNNING", progress: {...} }
GET /jobs/1001/logs?offset=0  → { logs:[...], nextOffset:200 }
... (status=DONE になるまで繰り返し)
```

### 在線 → 離線 フロー

```bash
# 1. 認証
POST /auth/login → { accessToken: "eyJ..." }

# 2. 施設一覧・件数取得
GET /facilities → { facilities: [{facilityCd:"FAC001",...}] }
GET /facilities/count?facility_cd=FAC001 → { tableCounts:{order_tbl:15230,...} }

# 3. クライアント側: 離線 DB で SEQ を確保 → seqStartMap を計算

# 4. JOB 起動
POST /jobs { direction:"on2off", facilityCodes:["FAC001"], seqStartMap:{...} }
→ { jobId: 1002, status: "INIT" }

# 5. ポーリング
GET /jobs/1002 → status=DONE

# 6. ダウンロード
GET /download/1002/pg    → pg_dump_job1002.zip
GET /download/1002/mongo → mongo_dump_job1002.zip
GET /download/1002/files → files_job1002.zip
```
