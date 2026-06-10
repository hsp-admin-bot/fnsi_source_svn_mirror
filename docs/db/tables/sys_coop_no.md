# sys_coop_no

- Source workbook: `NTSSデータベース設計書_外部データ連携.xlsm`
- Source sheet: `sys_coop_no`
- Logical name: 患者連携情報
- Physical name: `sys_coop_no`
- Source physical cell: `sys_coop_no`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `ctl_no`

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 管理番号 | ctl_no | bigserial |  | 1 |  |  |
|  | 施設コード | facility_cd | character varying | 6 | 1 |  | 施設マスタ.施設コード |
|  | 連携オーダ種別 | coop_ord_cd | jsonb |  |  |  | 採番体系が同じオーダ種別をまとめる<br>[<br>{"ord_cd" : "ini_dial"}<br>{"ord_cd" : "profile"}<br>:<br>] |
|  | 現在の連携オーダ番号シーケンス | cur_coop_ord_no | bigint |  | 1 | 0 |  |
|  | 連携オーダ番号_桁数 | no_of_digit | bigint |  | 1 |  | オーダ番号の桁数<br>番号：９<br>桁数：8<br>の場合'00000009'のようにする |
|  | 連携オーダ番号_パディング文字 | padding_char | character varying | 1 | 1 | '0' | nullの場合は'0'とする |
|  | 連携オーダ番号_パディング位置 | padding_pos | character varying |  | 1 | 'left' | パディングする位置<br>left : 左（デフォルト）<br>right : 右 |
|  | 連携オーダ番号_最大値 | range_max | bigint |  |  |  | 採番の範囲の最大値<br>この値を超える場合にはcoop_ord_no_minに戻る |
|  | 連携オーダ番号_最小値 | range_min | bigint |  | 1 | 0 | 採番の範囲の最小値 |
|  | 連携オーダ番号_前置文字 | prefix_char | character varying |  |  |  | オーダ番号の連番の前に付ける |
|  | 連携オーダ番号_後置文字 | suffix_char | character varying |  |  |  | オーダ番号の連番の後に付ける |
|  | 表示フラグ | is_disp | character varying | 1 |  | '1' | '0'：非表示、'1'：表示 |
|  | 削除フラグ | is_del | character varying | 1 |  | '0' | '0':通常、'1':削除 |
|  | 操作者ID | user_id | bigint |  |  |  |  |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
|  | 連携版番号 | coop_version | character varying | 10 | 1 | '' |  |
|  | 付帯情報（電文） | coop_cd_index | character varying | 10 | 1 |  |  |
|  | 電文種別 | coop_cd | character varying | 20 | 1 |  |  |

## SQL

```sql
↓★以下のSQL文をコピーし、「A5(SQL Mk-2)」から実行して下さい
■SQL文
-- テーブル削除
DROP TABLE IF EXISTS sys_coop_no;
-- テーブル作成
CREATE TABLE sys_coop_no
(
ctl_no bigserial NOT NULL,  --管理番号
facility_cd character varying(6) NOT NULL,  --施設コード
coop_ord_cd jsonb,  --連携オーダ種別
cur_coop_ord_no bigint NOT NULL DEFAULT 0,  --現在の連携オーダ番号シーケンス
no_of_digit bigint NOT NULL,  --連携オーダ番号_桁数
padding_char character varying(1) NOT NULL DEFAULT '0',  --連携オーダ番号_パディング文字
padding_pos character varying NOT NULL DEFAULT 'left',  --連携オーダ番号_パディング位置
range_max bigint,  --連携オーダ番号_最大値
range_min bigint NOT NULL DEFAULT 0,  --連携オーダ番号_最小値
prefix_char character varying,  --連携オーダ番号_前置文字
suffix_char character varying,  --連携オーダ番号_後置文字
is_disp character varying(1) DEFAULT '1',  --表示フラグ
is_del character varying(1) DEFAULT '0',  --削除フラグ
user_id bigint,  --操作者ID
reg_date timestamp(3),  --登録日時
up_date timestamp(3),  --更新日時
coop_version character varying(10) NOT NULL DEFAULT '',  --連携版番号
coop_cd_index character varying(10) NOT NULL,  --付帯情報（電文）
coop_cd character varying(20) NOT NULL,  --電文種別
CONSTRAINT unq_sys_coop_no_01 PRIMARY KEY (ctl_no)
using index tablespace ntss_index5
)
WITH (
OIDS=FALSE
)
tablespace ntss_db5;
-- ユーザ設定
ALTER TABLE sys_coop_no OWNER TO nkk5;
-- コメント追加
COMMENT ON TABLE "sys_coop_no" IS E'患者連携情報';
COMMENT ON COLUMN "sys_coop_no"."ctl_no" IS E'管理番号';
COMMENT ON COLUMN "sys_coop_no"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "sys_coop_no"."coop_ord_cd" IS E'連携オーダ種別';
COMMENT ON COLUMN "sys_coop_no"."cur_coop_ord_no" IS E'現在の連携オーダ番号シーケンス';
COMMENT ON COLUMN "sys_coop_no"."no_of_digit" IS E'連携オーダ番号_桁数';
COMMENT ON COLUMN "sys_coop_no"."padding_char" IS E'連携オーダ番号_パディング文字';
COMMENT ON COLUMN "sys_coop_no"."padding_pos" IS E'連携オーダ番号_パディング位置';
COMMENT ON COLUMN "sys_coop_no"."range_max" IS E'連携オーダ番号_最大値';
COMMENT ON COLUMN "sys_coop_no"."range_min" IS E'連携オーダ番号_最小値';
COMMENT ON COLUMN "sys_coop_no"."prefix_char" IS E'連携オーダ番号_前置文字';
COMMENT ON COLUMN "sys_coop_no"."suffix_char" IS E'連携オーダ番号_後置文字';
COMMENT ON COLUMN "sys_coop_no"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "sys_coop_no"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "sys_coop_no"."user_id" IS E'操作者ID';
COMMENT ON COLUMN "sys_coop_no"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "sys_coop_no"."up_date" IS E'更新日時';
COMMENT ON COLUMN "sys_coop_no"."coop_version" IS E'連携版番号';
COMMENT ON COLUMN "sys_coop_no"."coop_cd_index" IS E'付帯情報（電文）';
COMMENT ON COLUMN "sys_coop_no"."coop_cd" IS E'電文種別';
■テストデータ
ctl_no
```
