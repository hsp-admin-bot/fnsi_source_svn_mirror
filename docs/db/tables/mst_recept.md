# mst_recept

- Source workbook: `NTSSデータベース設計書_外部データ連携.xlsm`
- Source sheet: `mst_recept`
- Logical name: 医事コードマスタ
- Physical name: `mst_recept`
- Source physical cell: `mst_recept`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `facility_cd,master_version,recept_cd`

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 施設コード | facility_cd | character varying | 6 | 1 |  |  |
| 1 | 世代（YYYYMM） | master_version | numeric | 6 | 1 |  |  |
| 1 | 医事コード | recept_cd | character varying | 6 | 1 |  |  |
|  | 略称コード | abbr_cd | character varying | 8 |  |  |  |
|  | 診区 | section_type | numeric | 2 |  |  |  |
|  | 診区枝番 | section_sub_id | numeric | 2 |  |  |  |
|  | マスタ区分 | master_category | numeric | 1 |  |  |  |
|  | 表示名称 | display_name | character varying | 72 |  |  |  |
|  | 正式名称 | formal_name | character varying | 200 |  |  |  |
|  | 入力単位 | input_unit | character varying | 6 |  |  |  |
|  | 単価（点数・金額） | unit_price | numeric | 12,4 |  |  |  |
|  | 読み（検索用） | search_name | character varying | 8 |  |  |  |
|  | 使用期限日（YYYYMMDD） | expiry_date | numeric | 8 |  |  |  |
|  | 管理番号 | manage_no | numeric | 10 |  |  |  |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |

## SQL

```sql
↓★以下のSQL文をコピーし、「A5(SQL Mk-2)」から実行して下さい
■SQL文
-- テーブル削除
DROP TABLE IF EXISTS mst_recept;
-- テーブル作成
CREATE TABLE mst_recept
(
facility_cd character varying(6) NOT NULL,  --施設コード
master_version numeric(6) NOT NULL,  --世代（YYYYMM）
recept_cd character varying(6) NOT NULL,  --医事コード
abbr_cd character varying(8),  --略称コード
section_type numeric(2),  --診区
section_sub_id numeric(2),  --診区枝番
master_category numeric(1),  --マスタ区分
display_name character varying(72),  --表示名称
formal_name character varying(200),  --正式名称
input_unit character varying(6),  --入力単位
unit_price numeric(12,4),  --単価（点数・金額）
search_name character varying(8),  --読み（検索用）
expiry_date numeric(8),  --使用期限日（YYYYMMDD）
manage_no numeric(10),  --管理番号
reg_date timestamp(3),  --登録日時
up_date timestamp(3),  --更新日時
CONSTRAINT unq_mst_recept_01 PRIMARY KEY (facility_cd,master_version,recept_cd)
using index tablespace ntss_index5
)
WITH (
OIDS=FALSE
)
tablespace ntss_db5;
-- ユーザ設定
ALTER TABLE mst_recept OWNER TO nkk5;
-- コメント追加
COMMENT ON TABLE "mst_recept" IS E'医事コードマスタ';
COMMENT ON COLUMN "mst_recept"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mst_recept"."master_version" IS E'世代（YYYYMM）';
COMMENT ON COLUMN "mst_recept"."recept_cd" IS E'医事コード';
COMMENT ON COLUMN "mst_recept"."abbr_cd" IS E'略称コード';
COMMENT ON COLUMN "mst_recept"."section_type" IS E'診区';
COMMENT ON COLUMN "mst_recept"."section_sub_id" IS E'診区枝番';
COMMENT ON COLUMN "mst_recept"."master_category" IS E'マスタ区分';
COMMENT ON COLUMN "mst_recept"."display_name" IS E'表示名称';
COMMENT ON COLUMN "mst_recept"."formal_name" IS E'正式名称';
COMMENT ON COLUMN "mst_recept"."input_unit" IS E'入力単位';
COMMENT ON COLUMN "mst_recept"."unit_price" IS E'単価（点数・金額）';
COMMENT ON COLUMN "mst_recept"."search_name" IS E'読み（検索用）';
COMMENT ON COLUMN "mst_recept"."expiry_date" IS E'使用期限日（YYYYMMDD）';
COMMENT ON COLUMN "mst_recept"."manage_no" IS E'管理番号';
COMMENT ON COLUMN "mst_recept"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mst_recept"."up_date" IS E'更新日時';
■テストデータ
facility_cd
```
