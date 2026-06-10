# ord_coop_no

- Source workbook: `NTSSデータベース設計書_外部データ連携.xlsm`
- Source sheet: `ord_coop_no`
- Logical name: 連携オーダ番号
- Physical name: `ord_coop_no`
- Source physical cell: `ord_coop_no`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `ctl_no`

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 管理番号 | ctl_no | bigserial |  | 1 |  | 治療情報.オーダー番号 |
|  | 施設コード | facility_cd | character varying | 6 | 1 |  | 施設マスタ.施設コード |
|  | 患者番号 | pat_id | bigint |  |  |  |  |
|  | オーダ番号 | ord_no | bigint |  |  |  | シート@coop_cdを参照 |
|  | 連携種別 | coop_cd | character varying |  |  |  |  |
|  | 連携オーダ番号 | coop_ord_no | character varying |  |  |  |  |
|  | 表示フラグ | is_disp | character varying | 1 |  | '1' | '0'：非表示、'1'：表示 |
|  | 削除フラグ | is_del | character varying | 1 |  | '0' | '0':通常、'1':削除 |
|  | 操作者ID | user_id | bigint |  |  |  |  |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
|  | ステータス | status | character varying | 1 |  | '0' | 0'：未処理、'1'：処理済 |
|  | 患者番号（連携用） | hosp_pat_id | character varying | 12 |  |  |  |
|  | 連携版番号 | coop_version | character varying | 10 | 1 | '' |  |
|  | 付帯情報（電文） | coop_cd_index | character varying | 10 |  |  |  |

## SQL

```sql
↓★以下のSQL文をコピーし、「A5(SQL Mk-2)」から実行して下さい
■SQL文
-- テーブル削除
DROP TABLE IF EXISTS ord_coop_no;
-- テーブル作成
CREATE TABLE ord_coop_no
(
ctl_no bigserial NOT NULL,  --管理番号
facility_cd character varying(6) NOT NULL,  --施設コード
pat_id bigint,  --患者番号
ord_no bigint,  --オーダ番号
coop_cd character varying,  --連携種別
coop_ord_no character varying,  --連携オーダ番号
is_disp character varying(1) DEFAULT '1',  --表示フラグ
is_del character varying(1) DEFAULT '0',  --削除フラグ
user_id bigint,  --操作者ID
reg_date timestamp(3),  --登録日時
up_date timestamp(3),  --更新日時
status character varying(1) DEFAULT '0',  --ステータス
hosp_pat_id character varying(12),  --患者番号（連携用）
coop_version character varying(10) NOT NULL DEFAULT '',  --連携版番号
coop_cd_index character varying(10),  --付帯情報（電文）
CONSTRAINT unq_ord_coop_no_01 PRIMARY KEY (ctl_no)
using index tablespace ntss_index5
)
WITH (
OIDS=FALSE
)
tablespace ntss_db5;
-- ユーザ設定
ALTER TABLE ord_coop_no OWNER TO nkk5;
-- コメント追加
COMMENT ON TABLE "ord_coop_no" IS E'連携オーダ番号';
COMMENT ON COLUMN "ord_coop_no"."ctl_no" IS E'管理番号';
COMMENT ON COLUMN "ord_coop_no"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "ord_coop_no"."pat_id" IS E'患者番号';
COMMENT ON COLUMN "ord_coop_no"."ord_no" IS E'オーダ番号';
COMMENT ON COLUMN "ord_coop_no"."coop_cd" IS E'連携種別';
COMMENT ON COLUMN "ord_coop_no"."coop_ord_no" IS E'連携オーダ番号';
COMMENT ON COLUMN "ord_coop_no"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "ord_coop_no"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "ord_coop_no"."user_id" IS E'操作者ID';
COMMENT ON COLUMN "ord_coop_no"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "ord_coop_no"."up_date" IS E'更新日時';
COMMENT ON COLUMN "ord_coop_no"."status" IS E'ステータス';
COMMENT ON COLUMN "ord_coop_no"."hosp_pat_id" IS E'患者番号（連携用）';
COMMENT ON COLUMN "ord_coop_no"."coop_version" IS E'連携版番号';
COMMENT ON COLUMN "ord_coop_no"."coop_cd_index" IS E'付帯情報（電文）';
=IF(D25="","","COMMENT ON COLUMN " & """" & $C$5 & """.""" & D25 & """ IS E'" & C25 & "';")
■テストデータ
ctl_no
```
