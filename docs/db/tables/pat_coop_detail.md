# pat_coop_detail

- Source workbook: `NTSSデータベース設計書_外部データ連携.xlsm`
- Source sheet: `pat_coop_detail`
- Logical name: 患者連携情報
- Physical name: `pat_coop_detail`
- Source physical cell: `pat_coop_detail`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `coop_save_no`

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 管理番号 | coop_save_no | bigserial |  | 1 |  |  |
|  | 施設コード | facility_cd | character varying | 6 | 1 |  |  |
|  | 患者番号 | pat_id | bigint |  | 1 |  | 患者基本情報.患者番号 |
|  | 連携情報カラム１ | SAVE_1 | jsonb |  |  |  | {<br>"key_01":連携時に退避しておくデータ（以下10個分）<br>"key_02":<br>"key_03":<br>"key_04":<br>"key_05":<br>"key_06":<br>"key_07":<br>"key_08":<br>"key_09":<br>"key_10":<br>} |
|  | 連携情報カラム２ | SAVE_2 | jsonb |  |  |  | 同上 |
|  | 連携情報カラム３ | SAVE_3 | jsonb |  |  |  | 同上 |
|  | 連携情報カラム４ | SAVE_4 | jsonb |  |  |  | 同上 |
|  | 連携情報カラム５ | SAVE_5 | jsonb |  |  |  | 同上 |
|  | 連携情報カラム６ | SAVE_6 | jsonb |  |  |  | 同上 |
|  | 連携情報カラム７ | SAVE_7 | jsonb |  |  |  | 同上 |
|  | 連携情報カラム８ | SAVE_8 | jsonb |  |  |  | 同上 |
|  | 連携情報カラム９ | SAVE_9 | jsonb |  |  |  | 同上 |
|  | 連携情報カラム１０ | SAVE_10 | jsonb |  |  |  | 同上 |
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
DROP TABLE IF EXISTS pat_coop_detail;
-- テーブル作成
CREATE TABLE pat_coop_detail
(
coop_save_no bigserial NOT NULL,  --管理番号
facility_cd character varying(6) NOT NULL,  --施設コード
pat_id bigint NOT NULL,  --患者番号
SAVE_1 jsonb,  --連携情報カラム１
SAVE_2 jsonb,  --連携情報カラム２
SAVE_3 jsonb,  --連携情報カラム３
SAVE_4 jsonb,  --連携情報カラム４
SAVE_5 jsonb,  --連携情報カラム５
SAVE_6 jsonb,  --連携情報カラム６
SAVE_7 jsonb,  --連携情報カラム７
SAVE_8 jsonb,  --連携情報カラム８
SAVE_9 jsonb,  --連携情報カラム９
SAVE_10 jsonb,  --連携情報カラム１０
is_disp character varying(1) DEFAULT '1',  --表示フラグ
is_del character varying(1) DEFAULT '0',  --削除フラグ
user_id bigint,  --操作者ID
reg_date timestamp(3),  --登録日時
up_date timestamp(3),  --更新日時
coop_version character varying(10) NOT NULL DEFAULT '',  --連携版番号
CONSTRAINT unq_pat_coop_detail_01 PRIMARY KEY (coop_save_no)
using index tablespace ntss_index5
)
WITH (
OIDS=FALSE
)
tablespace ntss_db5;
-- ユーザ設定
ALTER TABLE pat_coop_detail OWNER TO nkk5;
-- コメント追加
COMMENT ON TABLE "pat_coop_detail" IS E'患者連携情報';
COMMENT ON COLUMN "pat_coop_detail"."coop_save_no" IS E'管理番号';
COMMENT ON COLUMN "pat_coop_detail"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "pat_coop_detail"."pat_id" IS E'患者番号';
COMMENT ON COLUMN "pat_coop_detail"."SAVE_1" IS E'連携情報カラム１';
COMMENT ON COLUMN "pat_coop_detail"."SAVE_2" IS E'連携情報カラム２';
COMMENT ON COLUMN "pat_coop_detail"."SAVE_3" IS E'連携情報カラム３';
COMMENT ON COLUMN "pat_coop_detail"."SAVE_4" IS E'連携情報カラム４';
COMMENT ON COLUMN "pat_coop_detail"."SAVE_5" IS E'連携情報カラム５';
COMMENT ON COLUMN "pat_coop_detail"."SAVE_6" IS E'連携情報カラム６';
COMMENT ON COLUMN "pat_coop_detail"."SAVE_7" IS E'連携情報カラム７';
COMMENT ON COLUMN "pat_coop_detail"."SAVE_8" IS E'連携情報カラム８';
COMMENT ON COLUMN "pat_coop_detail"."SAVE_9" IS E'連携情報カラム９';
COMMENT ON COLUMN "pat_coop_detail"."SAVE_10" IS E'連携情報カラム１０';
COMMENT ON COLUMN "pat_coop_detail"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "pat_coop_detail"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "pat_coop_detail"."user_id" IS E'操作者ID';
COMMENT ON COLUMN "pat_coop_detail"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "pat_coop_detail"."up_date" IS E'更新日時';
COMMENT ON COLUMN "pat_coop_detail"."coop_version" IS E'連携版番号';
■テストデータ
coop_save_no
```
