# mst_zai_output_map

- Source workbook: `NTSSデータベース設計書_外部データ連携.xlsm`
- Source sheet: `mst_zai_output_map`
- Logical name: 剤出力マッピングマスタ
- Physical name: `mst_zai_output_map`
- Source physical cell: `mst_zai_output_map`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `facility_cd,map_calc_cd`

## Related Config / Reference Values

- [../config/mst_zai_output_map.md](../config/mst_zai_output_map.md)

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 施設コード | facility_cd | character varying | 6 | 1 |  |  |
| 1 | 算定コード | map_calc_cd | character varying | 24 | 1 |  |  |
|  | 算定名 | map_calc_name | character varying | 100 |  |  |  |
|  | 剤パターンコード | pattern_cd | numeric | 3 |  |  | 剤処理パターン定義マスタのコード |
|  | 表示順 | disp_order | numeric | 3 |  |  | 画面表示順序 |
|  | 削除フラグ（0：有効、1：削除） | is_del | character varying | 1 |  |  | 0：有効、1：削除 |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |

## SQL

```sql
↓★以下のSQL文をコピーし、「A5(SQL Mk-2)」から実行して下さい
■SQL文
-- テーブル削除
DROP TABLE IF EXISTS mst_zai_output_map;
-- テーブル作成
CREATE TABLE mst_zai_output_map
(
facility_cd character varying(6) NOT NULL,  --施設コード
map_calc_cd character varying(24) NOT NULL,  --算定コード
map_calc_name character varying(100),  --算定名
pattern_cd numeric(3),  --剤パターンコード
disp_order numeric(3),  --表示順
is_del character varying(1),  --削除フラグ（0：有効、1：削除）
reg_date timestamp(3),  --登録日時
up_date timestamp(3),  --更新日時
CONSTRAINT unq_mst_zai_output_map_01 PRIMARY KEY (facility_cd,map_calc_cd)
using index tablespace ntss_index5
)
WITH (
OIDS=FALSE
)
tablespace ntss_db5;
-- ユーザ設定
ALTER TABLE mst_zai_output_map OWNER TO nkk5;
-- コメント追加
COMMENT ON TABLE "mst_zai_output_map" IS E'剤出力マッピングマスタ';
COMMENT ON COLUMN "mst_zai_output_map"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mst_zai_output_map"."map_calc_cd" IS E'算定コード';
COMMENT ON COLUMN "mst_zai_output_map"."map_calc_name" IS E'算定名';
COMMENT ON COLUMN "mst_zai_output_map"."pattern_cd" IS E'剤パターンコード';
COMMENT ON COLUMN "mst_zai_output_map"."disp_order" IS E'表示順';
COMMENT ON COLUMN "mst_zai_output_map"."is_del" IS E'削除フラグ（0：有効、1：削除）';
COMMENT ON COLUMN "mst_zai_output_map"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mst_zai_output_map"."up_date" IS E'更新日時';
■テストデータ
facility_cd
```
