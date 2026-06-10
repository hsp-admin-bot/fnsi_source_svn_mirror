# mst_coop_ini

- Source workbook: `NTSSデータベース設計書_外部データ連携.xlsm`
- Source sheet: `mst_coop_ini`
- Logical name: 連携設定マスタ
- Physical name: `mst_coop_ini`
- Source physical cell: `mst_coop_ini`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `coop_ini_cd`

## Related Config / Reference Values

- [../config/mst_coop_ini.md](../config/mst_coop_ini.md)

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 連携設定コード | coop_ini_cd | bigserial |  | 1 |  |  |
|  | 施設コード | facility_cd | varchar | 6 | 1 |  |  |
|  | 設定時メモ | coop_ini_memo | varchar |  |  |  |  |
|  | 設定詳細 | coop_ini_info | jsonb |  |  |  | @mst_coop_ini参照 |
|  | 表示フラグ | is_disp | varchar | 1 |  | '1' | '0'：非表示、'1'：表示 |
|  | 削除フラグ | is_del | varchar | 1 |  | '0' | '0':通常、'1':削除 |
|  | 登録日時 | reg_date | timestamp |  |  |  |  |
|  | 更新日時 | up_date | timestamp |  |  |  |  |
|  | KEYマッピング | key_mapping | jsonb |  |  |  | 設定詳細のkey1のマッピング。無し場合、マッピングが無し。 |

## SQL

```sql
↓★以下のSQL文をコピーし、「A5(SQL Mk-2)」から実行して下さい
■SQL文
-- テーブル削除
DROP TABLE IF EXISTS mst_coop_ini;
-- テーブル作成
CREATE TABLE mst_coop_ini
(
coop_ini_cd bigserial NOT NULL,  --連携設定コード
facility_cd varchar(6) NOT NULL,  --施設コード
coop_ini_memo varchar,  --設定時メモ
coop_ini_info jsonb,  --設定詳細
is_disp varchar(1) DEFAULT '1',  --表示フラグ
is_del varchar(1) DEFAULT '0',  --削除フラグ
reg_date timestamp,  --登録日時
up_date timestamp,  --更新日時
key_mapping jsonb,  --KEYマッピング
CONSTRAINT unq_mst_coop_ini_01 PRIMARY KEY (coop_ini_cd)
using index tablespace ntss_index5
)
WITH (
OIDS=FALSE
)
tablespace ntss_db5;
-- ユーザ設定
ALTER TABLE mst_coop_ini OWNER TO nkk5;
-- コメント追加
COMMENT ON TABLE "mst_coop_ini" IS E'連携設定マスタ';
COMMENT ON COLUMN "mst_coop_ini"."coop_ini_cd" IS E'連携設定コード';
COMMENT ON COLUMN "mst_coop_ini"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mst_coop_ini"."coop_ini_memo" IS E'設定時メモ';
COMMENT ON COLUMN "mst_coop_ini"."coop_ini_info" IS E'設定詳細';
COMMENT ON COLUMN "mst_coop_ini"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "mst_coop_ini"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "mst_coop_ini"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mst_coop_ini"."up_date" IS E'更新日時';
COMMENT ON COLUMN "mst_coop_ini"."key_mapping" IS E'KEYマッピング';
■テストデータ
coop_ini_cd
```
