# mst_if_edge

- Source workbook: `NTSSデータベース設計書_外部データ連携.xlsm`
- Source sheet: `mst_if_edge`
- Logical name: 連携エッジマスタ
- Physical name: `mst_if_edge`
- Source physical cell: `mst_if_edge`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `serial_no`

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 製造番号 | serial_no | character varying | 20 | 1 |  |  |
|  | 施設コード | facility_cd | character varying | 6 |  |  |  |
|  | IFエッジ番号 | if_edge_no | numeric | 2 |  |  |  |
|  | IFエッジ名 | if_edge_name | character varying |  |  |  |  |
|  | 表示フラグ | is_disp | character varying | 1 |  |  |  |
|  | 削除フラグ | is_del | character varying | 1 |  |  |  |
|  | 設置日 | setting_date | timestamp(3) |  |  |  |  |
|  | 破棄日 | delete_date | timestamp(3) |  |  |  |  |
|  | メモ | memo | character varying |  |  |  |  |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |

## SQL

```sql
↓★以下のSQL文をコピーし、「A5(SQL Mk-2)」から実行して下さい
■SQL文
-- テーブル削除
DROP TABLE IF EXISTS mst_if_edge;
-- テーブル作成
CREATE TABLE mst_if_edge
(
serial_no character varying(20) NOT NULL,  --製造番号
facility_cd character varying(6),  --施設コード
if_edge_no numeric(2),  --IFエッジ番号
if_edge_name character varying,  --IFエッジ名
is_disp character varying(1),  --表示フラグ
is_del character varying(1),  --削除フラグ
setting_date timestamp(3),  --設置日
delete_date timestamp(3),  --破棄日
memo character varying,  --メモ
reg_date timestamp(3),  --登録日時
up_date timestamp(3),  --更新日時
CONSTRAINT unq_mst_if_edge_01 PRIMARY KEY (serial_no)
using index tablespace ntss_index5
)
WITH (
OIDS=FALSE
)
tablespace ntss_db5;
-- ユーザ設定
ALTER TABLE mst_if_edge OWNER TO nkk5;
-- コメント追加
COMMENT ON TABLE "mst_if_edge" IS E'連携エッジマスタ';
COMMENT ON COLUMN "mst_if_edge"."serial_no" IS E'製造番号';
COMMENT ON COLUMN "mst_if_edge"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mst_if_edge"."if_edge_no" IS E'IFエッジ番号';
COMMENT ON COLUMN "mst_if_edge"."if_edge_name" IS E'IFエッジ名';
COMMENT ON COLUMN "mst_if_edge"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "mst_if_edge"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "mst_if_edge"."setting_date" IS E'設置日';
COMMENT ON COLUMN "mst_if_edge"."delete_date" IS E'破棄日';
COMMENT ON COLUMN "mst_if_edge"."memo" IS E'メモ';
COMMENT ON COLUMN "mst_if_edge"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mst_if_edge"."up_date" IS E'更新日時';
■テストデータ
serial_no
```
