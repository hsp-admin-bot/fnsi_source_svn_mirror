# mst_coop_distribute

- Source workbook: `NTSSデータベース設計書_外部データ連携.xlsm`
- Source sheet: `mst_coop_distribute`
- Logical name: 連携配信設定マスタ
- Physical name: `mst_coop_distribute`
- Source physical cell: `mst_coop_distribute`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `ctl_no`

## Related Config / Reference Values

- [../config/mst_cop_distribute.md](../config/mst_cop_distribute.md)

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 管理番号 | ctl_no | bigserial |  | 1 |  |  |
|  | 施設コード | facility_cd | character varying | 6 | 1 |  |  |
|  | 電文種別 | coop_cd | character varying | 20 | 1 |  | シート@coop_cdを参照 |
|  | 付帯情報（電文） | coop_cd_index | character varying | 10 | 1 | '' | （IBM)電文種別の付帯情報<br>レポート等にも使う? |
|  | 向き（送受信） | direction | character varying | 1 | 1 |  | S:送信　R:受信 |
|  | 対応ベンダー名 | coop_vender | character varying |  |  |  |  |
|  | 説明 | description | character varying |  |  |  |  |
|  | 編集可否フラグ | is_editable | character varying | 1 |  |  | '0'：編集不可、'1'：編集可 |
|  | 配信設定 | distribute_setting | jsonb |  |  |  |  |
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
DROP TABLE IF EXISTS mst_coop_distribute;
-- テーブル作成
CREATE TABLE mst_coop_distribute
(
ctl_no bigserial NOT NULL,  --管理番号
facility_cd character varying(6) NOT NULL,  --施設コード
coop_cd character varying(20) NOT NULL,  --電文種別
coop_cd_index character varying(10) NOT NULL DEFAULT '',  --付帯情報（電文）
direction character varying(1) NOT NULL,  --向き（送受信）
coop_vender character varying,  --対応ベンダー名
description character varying,  --説明
is_editable character varying(1),  --編集可否フラグ
distribute_setting jsonb,  --配信設定
is_disp character varying(1) DEFAULT '1',  --表示フラグ
is_del character varying(1) DEFAULT '0',  --削除フラグ
user_id bigint,  --操作者ID
reg_date timestamp(3),  --登録日時
up_date timestamp(3),  --更新日時
coop_version character varying(10) NOT NULL DEFAULT '',  --連携版番号
CONSTRAINT unq_mst_coop_distribute_01 PRIMARY KEY (ctl_no)
using index tablespace ntss_index5
)
WITH (
OIDS=FALSE
)
tablespace ntss_db5;
-- ユーザ設定
ALTER TABLE mst_coop_distribute OWNER TO nkk5;
-- コメント追加
COMMENT ON TABLE "mst_coop_distribute" IS E'連携配信設定マスタ';
COMMENT ON COLUMN "mst_coop_distribute"."ctl_no" IS E'管理番号';
COMMENT ON COLUMN "mst_coop_distribute"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mst_coop_distribute"."coop_cd" IS E'電文種別';
COMMENT ON COLUMN "mst_coop_distribute"."coop_cd_index" IS E'付帯情報（電文）';
COMMENT ON COLUMN "mst_coop_distribute"."direction" IS E'向き（送受信）';
COMMENT ON COLUMN "mst_coop_distribute"."coop_vender" IS E'対応ベンダー名';
COMMENT ON COLUMN "mst_coop_distribute"."description" IS E'説明';
COMMENT ON COLUMN "mst_coop_distribute"."is_editable" IS E'編集可否フラグ';
COMMENT ON COLUMN "mst_coop_distribute"."distribute_setting" IS E'配信設定';
COMMENT ON COLUMN "mst_coop_distribute"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "mst_coop_distribute"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "mst_coop_distribute"."user_id" IS E'操作者ID';
COMMENT ON COLUMN "mst_coop_distribute"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mst_coop_distribute"."up_date" IS E'更新日時';
COMMENT ON COLUMN "mst_coop_distribute"."coop_version" IS E'連携版番号';
■テストデータ
ctl_no
```
