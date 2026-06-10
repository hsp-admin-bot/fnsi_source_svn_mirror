# mst_calc_setting

- Source workbook: `NTSSデータベース設計書_外部データ連携.xlsm`
- Source sheet: `mst_calc_setting`
- Logical name: 医事算定設定マスタ
- Physical name: `mst_calc_setting`
- Source physical cell: `mst_calc_setting`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `facility_cd,master_version,calc_cd`

## Related Config / Reference Values

- [../config/mst_calc_setting.md](../config/mst_calc_setting.md)

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 施設コード | facility_cd | character varying | 6 | 1 |  |  |
| 1 | 世代（YYYYMM） | master_version | numeric | 6 | 1 |  |  |
| 1 | 算定コード | calc_cd | character varying | 24 | 1 |  |  |
|  | 算定名 | calc_name | character varying | 200 |  |  |  |
|  | 医事コード | recept_cd | character varying | 6 |  |  |  |
|  | 画面表示順 | disp_order | numeric | 5 |  |  |  |
|  | 削除フラグ（0：有効、1：削除） | is_del | character varying | 1 |  | '0' |  |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |

## SQL

```sql
↓★以下のSQL文をコピーし、「A5(SQL Mk-2)」から実行して下さい
■SQL文
-- テーブル削除
DROP TABLE IF EXISTS mst_calc_setting;
-- テーブル作成
CREATE TABLE mst_calc_setting
(
facility_cd character varying(6) NOT NULL,  --施設コード
master_version numeric(6) NOT NULL,  --世代（YYYYMM）
calc_cd character varying(24) NOT NULL,  --算定コード
calc_name character varying(200),  --算定名
recept_cd character varying(6),  --医事コード
disp_order numeric(5),  --画面表示順
is_del character varying(1) DEFAULT '0',  --削除フラグ（0：有効、1：削除）
reg_date timestamp(3),  --登録日時
up_date timestamp(3),  --更新日時
CONSTRAINT unq_mst_calc_setting_01 PRIMARY KEY (facility_cd,master_version,calc_cd)
using index tablespace ntss_index5
)
WITH (
OIDS=FALSE
)
tablespace ntss_db5;
-- ユーザ設定
ALTER TABLE mst_calc_setting OWNER TO nkk5;
-- コメント追加
COMMENT ON TABLE "mst_calc_setting" IS E'医事算定設定マスタ';
COMMENT ON COLUMN "mst_calc_setting"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mst_calc_setting"."master_version" IS E'世代（YYYYMM）';
COMMENT ON COLUMN "mst_calc_setting"."calc_cd" IS E'算定コード';
COMMENT ON COLUMN "mst_calc_setting"."calc_name" IS E'算定名';
COMMENT ON COLUMN "mst_calc_setting"."recept_cd" IS E'医事コード';
COMMENT ON COLUMN "mst_calc_setting"."disp_order" IS E'画面表示順';
COMMENT ON COLUMN "mst_calc_setting"."is_del" IS E'削除フラグ（0：有効、1：削除）';
COMMENT ON COLUMN "mst_calc_setting"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mst_calc_setting"."up_date" IS E'更新日時';
■テストデータ
facility_cd
```
