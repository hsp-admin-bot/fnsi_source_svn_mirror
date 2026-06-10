# mst_coop_facility

- Source workbook: `NTSSデータベース設計書_外部データ連携.xlsm`
- Source sheet: `mst_coop_facility`
- Logical name: 連携設定マスタ
- Physical name: `mst_coop_facility`
- Source physical cell: `mst_coop_facility`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `ctl_no`

## Related Config / Reference Values

- [../config/mst_coop_facility.md](../config/mst_coop_facility.md)
- [../config/filewatch-parameters.md](../config/filewatch-parameters.md)
- [../config/report-type-settings.md](../config/report-type-settings.md)
- [../config/tshplus-telegram-format.md](../config/tshplus-telegram-format.md)
- [../config/response-telegram.md](../config/response-telegram.md)

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 管理番号 | ctl_no | bigserial |  | 1 |  |  |
|  | 施設コード | facility_cd | character varying | 6 | 1 |  |  |
|  | 説明 | description | character varying |  |  |  |  |
|  | 表示フラグ | is_disp | character varying | 1 |  | '1' | '0'：非表示、'1'：表示 |
|  | 削除フラグ | is_del | character varying | 1 |  | '0' | '0':通常、'1':削除 |
|  | IFエッジ設定 | if_edge_setting | jsonb |  |  |  | IFエッジ側で使用する設定<br>@mst_coop_facility参照 |
|  | 各機能共通設定 | common_setting | jsonb |  |  |  | @mst_coop_facility参照 |
|  | 操作者ID | user_id | bigint |  |  |  |  |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |

## SQL

```sql
↓★以下のSQL文をコピーし、「A5(SQL Mk-2)」から実行して下さい
■SQL文
-- テーブル削除
DROP TABLE IF EXISTS mst_coop_facility;
-- テーブル作成
CREATE TABLE mst_coop_facility
(
ctl_no bigserial NOT NULL,  --管理番号
facility_cd character varying(6) NOT NULL,  --施設コード
description character varying,  --説明
is_disp character varying(1) DEFAULT '1',  --表示フラグ
is_del character varying(1) DEFAULT '0',  --削除フラグ
if_edge_setting jsonb,  --IFエッジ設定
common_setting jsonb,  --各機能共通設定
user_id bigint,  --操作者ID
reg_date timestamp(3),  --登録日時
up_date timestamp(3),  --更新日時
CONSTRAINT unq_mst_coop_facility_01 PRIMARY KEY (ctl_no)
using index tablespace ntss_index5
)
WITH (
OIDS=FALSE
)
tablespace ntss_db5;
-- ユーザ設定
ALTER TABLE mst_coop_facility OWNER TO nkk5;
-- コメント追加
COMMENT ON TABLE "mst_coop_facility" IS E'連携設定マスタ';
COMMENT ON COLUMN "mst_coop_facility"."ctl_no" IS E'管理番号';
COMMENT ON COLUMN "mst_coop_facility"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mst_coop_facility"."description" IS E'説明';
COMMENT ON COLUMN "mst_coop_facility"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "mst_coop_facility"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "mst_coop_facility"."if_edge_setting" IS E'IFエッジ設定';
COMMENT ON COLUMN "mst_coop_facility"."common_setting" IS E'各機能共通設定';
COMMENT ON COLUMN "mst_coop_facility"."user_id" IS E'操作者ID';
COMMENT ON COLUMN "mst_coop_facility"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mst_coop_facility"."up_date" IS E'更新日時';
■テストデータ
ctl_no
```
