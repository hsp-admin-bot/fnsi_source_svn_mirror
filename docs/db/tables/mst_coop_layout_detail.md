# mst_coop_layout_detail

- Source workbook: `NTSSデータベース設計書_外部データ連携.xlsm`
- Source sheet: `mst_coop_layout_detail`
- Logical name: 連携電文設定マスタ詳細
- Physical name: `mst_coop_layout_detail`
- Source physical cell: `mst_coop_layout_detail`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `ctl_no`

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 管理番号 | ctl_no | bigserial |  | 1 |  |  |
|  | 施設コード | facility_cd | character varying | 6 | 1 |  |  |
|  | 電文種別 | coop_cd | character varying | 20 | 1 |  | シート@coop_cdを参照 |
|  | 向き（送受信） | direction | character varying | 1 | 1 |  | S:送信　R:受信 |
|  | 電文種別詳細コード | coop_cd_detail | character varying |  | 1 |  |  |
|  | 電文種別詳細補足コード | coop_cd_detail_sub | character varying |  | 1 |  | pre:プレロジック<br>その他自由 |
|  | レイアウト名称 | coop_name | character varying |  |  |  |  |
|  | 説明 | description | character varying |  |  |  |  |
|  | 編集可否フラグ | is_editable | character varying | 1 |  |  | '0'：編集不可、'1'：編集可 |
|  | 連携設定 | coop_setting | XML |  |  |  |  |
|  | 拡張設定 | coop_ext_setting | jsonb |  |  |  | 機能拡張用の設定 |
|  | 表示フラグ | is_disp | character varying | 1 |  | '1' | '0'：非表示、'1'：表示 |
|  | 削除フラグ | is_del | character varying | 1 |  | '0' | '0':通常、'1':削除 |
|  | 操作者ID | user_id | bigint |  |  |  |  |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
|  | 連携版番号 | coop_version | character varying | 10 | 1 | '' |  |

## SQL

```sql
↓★以下のSQL文をコピーし、「A5(SQL Mk-2)」から実行して下さい
■SQL文
-- テーブル削除
DROP TABLE IF EXISTS mst_coop_layout_detail;
-- テーブル作成
CREATE TABLE mst_coop_layout_detail
(
ctl_no bigserial NOT NULL,  --管理番号
facility_cd character varying(6) NOT NULL,  --施設コード
coop_cd character varying(20) NOT NULL,  --電文種別
direction character varying(1) NOT NULL,  --向き（送受信）
coop_cd_detail character varying NOT NULL,  --電文種別詳細コード
coop_cd_detail_sub character varying NOT NULL,  --電文種別詳細補足コード
coop_name character varying,  --レイアウト名称
description character varying,  --説明
is_editable character varying(1),  --編集可否フラグ
coop_setting XML,  --連携設定
coop_ext_setting jsonb,  --拡張設定
is_disp character varying(1) DEFAULT '1',  --表示フラグ
is_del character varying(1) DEFAULT '0',  --削除フラグ
user_id bigint,  --操作者ID
reg_date timestamp(3),  --登録日時
up_date timestamp(3),  --更新日時
coop_version character varying(10) NOT NULL DEFAULT '',  --連携版番号
CONSTRAINT unq_mst_coop_layout_detail_01 PRIMARY KEY (ctl_no)
using index tablespace ntss_index5
)
WITH (
OIDS=FALSE
)
tablespace ntss_db5;
-- ユーザ設定
ALTER TABLE mst_coop_layout_detail OWNER TO nkk5;
-- コメント追加
COMMENT ON TABLE "mst_coop_layout_detail" IS E'連携電文設定マスタ詳細';
COMMENT ON COLUMN "mst_coop_layout_detail"."ctl_no" IS E'管理番号';
COMMENT ON COLUMN "mst_coop_layout_detail"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mst_coop_layout_detail"."coop_cd" IS E'電文種別';
COMMENT ON COLUMN "mst_coop_layout_detail"."direction" IS E'向き（送受信）';
COMMENT ON COLUMN "mst_coop_layout_detail"."coop_cd_detail" IS E'電文種別詳細コード';
COMMENT ON COLUMN "mst_coop_layout_detail"."coop_cd_detail_sub" IS E'電文種別詳細補足コード';
COMMENT ON COLUMN "mst_coop_layout_detail"."coop_name" IS E'レイアウト名称';
COMMENT ON COLUMN "mst_coop_layout_detail"."description" IS E'説明';
COMMENT ON COLUMN "mst_coop_layout_detail"."is_editable" IS E'編集可否フラグ';
COMMENT ON COLUMN "mst_coop_layout_detail"."coop_setting" IS E'連携設定';
COMMENT ON COLUMN "mst_coop_layout_detail"."coop_ext_setting" IS E'拡張設定';
COMMENT ON COLUMN "mst_coop_layout_detail"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "mst_coop_layout_detail"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "mst_coop_layout_detail"."user_id" IS E'操作者ID';
COMMENT ON COLUMN "mst_coop_layout_detail"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mst_coop_layout_detail"."up_date" IS E'更新日時';
COMMENT ON COLUMN "mst_coop_layout_detail"."coop_version" IS E'連携版番号';
■テストデータ
ctl_no
```
