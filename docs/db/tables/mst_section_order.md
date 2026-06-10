# mst_section_order

- Source workbook: `NTSSデータベース設計書_外部データ連携.xlsm`
- Source sheet: `mst_section_order`
- Logical name: テーブル名(論理名)
- Physical name: `mst_section_order`
- Source physical cell: `mst_section_order`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `facility_cd,section_type`

## Related Config / Reference Values

- [../config/mst_section_order.md](../config/mst_section_order.md)

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 施設コード | facility_cd | character varying | 6 | 1 |  |  |
| 1 | 診療区分コード | section_type | numeric | 3 | 1 |  |  |
|  | 診療区分コード名 | section_name | character varying | 100 |  |  |  |
|  | ソート番号 | sort_order | numeric | 3 |  |  |  |
|  | 表示順 | disp_order | numeric | 3 |  |  | 画面表示順序 |
|  | 削除フラグ | is_del | character varying | 1 |  | '0' | 0：有効　1：削除 |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |

## SQL

```sql
↓★以下のSQL文をコピーし、「A5(SQL Mk-2)」から実行して下さい
■SQL文
-- テーブル削除
DROP TABLE IF EXISTS mst_section_order;
-- テーブル作成
CREATE TABLE mst_section_order
(
facility_cd character varying(6) NOT NULL,  --施設コード
section_type numeric(3) NOT NULL,  --診療区分コード
section_name character varying(100),  --診療区分コード名
sort_order numeric(3),  --ソート番号
disp_order numeric(3),  --表示順
is_del character varying(1) DEFAULT '0',  --削除フラグ
reg_date timestamp(3),  --登録日時
up_date timestamp(3),  --更新日時
CONSTRAINT unq_mst_section_order_01 PRIMARY KEY (facility_cd,section_type)
using index tablespace ntss_index5
)
WITH (
OIDS=FALSE
)
tablespace ntss_db5;
-- ユーザ設定
ALTER TABLE mst_section_order OWNER TO nkk5;
-- コメント追加
COMMENT ON TABLE "mst_section_order" IS E'テーブル名(論理名)';
COMMENT ON COLUMN "mst_section_order"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mst_section_order"."section_type" IS E'診療区分コード';
COMMENT ON COLUMN "mst_section_order"."section_name" IS E'診療区分コード名';
COMMENT ON COLUMN "mst_section_order"."sort_order" IS E'ソート番号';
COMMENT ON COLUMN "mst_section_order"."disp_order" IS E'表示順';
COMMENT ON COLUMN "mst_section_order"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "mst_section_order"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mst_section_order"."up_date" IS E'更新日時';
■テストデータ
facility_cd
```
