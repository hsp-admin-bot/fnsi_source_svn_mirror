# mst_zai_output_pattern

- Source workbook: `NTSSデータベース設計書_外部データ連携.xlsm`
- Source sheet: `mst_zai_output_pattern`
- Logical name: 剤出力パターンマスタ
- Physical name: `mst_zai_output_pattern`
- Source physical cell: `mst_zai_output_pattern`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `facility_cd         ,pattern_cd`

## Related Config / Reference Values

- [../config/mst_zai_output_pattern.md](../config/mst_zai_output_pattern.md)

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 施設コード | facility_cd | character varying | 6 | 1 |  |  |
| 1 | 剤出力パターンコード | pattern_cd | numeric | 3 | 1 |  |  |
|  | 剤出力パターン名称 | pattern_name | character varying | 100 |  |  |  |
|  | 医事コード | recept_cd | character varying | 6 |  |  | 剤グループの先頭に付加する医事コード |
|  | 剤閉じフラグ | is_close | character varying | 1 |  | '0' | 剤グループ医事コードを出力した直後に、剤区切り明細（剤閉じ）を出力するかを指定します。_x000D_<br>0：剤を閉じない　1：剤を閉じる |
|  | 個別剤フラグ | is_individual | character varying | 1 |  | '0' | 同一剤グループ内の薬剤を個別の剤として算定します。_x000D_<br>0：別剤としない　1：別剤とする |
|  | 開始：医事コード | start_recept_cd | character varying | 6 |  |  | 薬剤明細として出力される医事コードの前に、医事コードまたはコメントを付加します。_x000D_<br>マスタ参照時に使用（数値で入る） |
|  | 開始：コメント | start_comment | character varying | 40 |  |  | 薬剤明細として出力される医事コードの前に、医事コードまたはコメントを付加します。_x000D_<br>自由記述時に使用（文字で入る） |
|  | 終了：医事コード | end_recept_cd | character varying | 6 |  |  | 薬剤明細として出力される医事コードの後に、医事コードまたはコメントを付加します。_x000D_<br>マスタ参照時に使用（数値で入る） |
|  | 終了：コメント | end_comment | character varying | 40 |  |  | 薬剤明細として出力される医事コードの後に、医事コードまたはコメントを付加します。_x000D_<br>自由記述時に使用（文字で入る） |
|  | レセプト診区 | rezept_type | numeric | 2 |  |  |  |
|  | レセプト表示診区名 | claim_section_disp | character varying | 4 |  |  |  |
|  | レセプト診区名 | claim_section_name | character varying | 64 |  |  |  |
|  | 有効無効フラグ | is_enabled | character varying | 1 |  | '0' |  |
|  | 表示順 | disp_order | numeric | 3 |  |  | 画面表示順序 |
|  | 削除フラグ（0：有効、1：削除） | is_del | character varying | 1 |  | '0' | 0：有効、1：削除 |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |

## SQL

```sql
↓★以下のSQL文をコピーし、「A5(SQL Mk-2)」から実行して下さい
■SQL文
-- テーブル削除
DROP TABLE IF EXISTS mst_zai_output_pattern;
-- テーブル作成
CREATE TABLE mst_zai_output_pattern
(
facility_cd          character varying(6) NOT NULL,  --施設コード
pattern_cd           numeric(3) NOT NULL,  --剤出力パターンコード
pattern_name         character varying(100),  --剤出力パターン名称
recept_cd            character varying(6),  --医事コード
is_close             character varying(1) DEFAULT '0',  --剤閉じフラグ
is_individual        character varying(1) DEFAULT '0',  --個別剤フラグ
start_recept_cd      character varying(6),  --開始：医事コード
start_comment        character varying(40),  --開始：コメント
end_recept_cd        character varying(6),  --終了：医事コード
end_comment          character varying(40),  --終了：コメント
rezept_type          numeric(2),  --レセプト診区
claim_section_disp  character varying(4),  --レセプト表示診区名
claim_section_name  character varying(64),  --レセプト診区名
is_enabled           character varying(1) DEFAULT '0',  --有効無効フラグ
disp_order           numeric(3),  --表示順
is_del              character varying(1) DEFAULT '0',  --削除フラグ（0：有効、1：削除）
reg_date             timestamp(3),  --登録日時
up_date              timestamp(3),  --更新日時
CONSTRAINT unq_mst_zai_output_pattern_01 PRIMARY KEY (facility_cd         ,pattern_cd          )
using index tablespace ntss_index5
)
WITH (
OIDS=FALSE
)
tablespace ntss_db5;
-- ユーザ設定
ALTER TABLE mst_zai_output_pattern OWNER TO nkk5;
-- コメント追加
COMMENT ON TABLE "mst_zai_output_pattern" IS E'剤出力パターンマスタ';
COMMENT ON COLUMN "mst_zai_output_pattern"."facility_cd         " IS E'施設コード';
COMMENT ON COLUMN "mst_zai_output_pattern"."pattern_cd          " IS E'剤出力パターンコード';
COMMENT ON COLUMN "mst_zai_output_pattern"."pattern_name        " IS E'剤出力パターン名称';
COMMENT ON COLUMN "mst_zai_output_pattern"."recept_cd           " IS E'医事コード';
COMMENT ON COLUMN "mst_zai_output_pattern"."is_close            " IS E'剤閉じフラグ';
COMMENT ON COLUMN "mst_zai_output_pattern"."is_individual       " IS E'個別剤フラグ';
COMMENT ON COLUMN "mst_zai_output_pattern"."start_recept_cd     " IS E'開始：医事コード';
COMMENT ON COLUMN "mst_zai_output_pattern"."start_comment       " IS E'開始：コメント';
COMMENT ON COLUMN "mst_zai_output_pattern"."end_recept_cd       " IS E'終了：医事コード';
COMMENT ON COLUMN "mst_zai_output_pattern"."end_comment         " IS E'終了：コメント';
COMMENT ON COLUMN "mst_zai_output_pattern"."rezept_type         " IS E'レセプト診区';
COMMENT ON COLUMN "mst_zai_output_pattern"."claim_section_disp " IS E'レセプト表示診区名';
COMMENT ON COLUMN "mst_zai_output_pattern"."claim_section_name " IS E'レセプト診区名';
COMMENT ON COLUMN "mst_zai_output_pattern"."is_enabled          " IS E'有効無効フラグ';
COMMENT ON COLUMN "mst_zai_output_pattern"."disp_order          " IS E'表示順';
COMMENT ON COLUMN "mst_zai_output_pattern"."is_del              " IS E'削除フラグ（0：有効、1：削除）';
COMMENT ON COLUMN "mst_zai_output_pattern"."reg_date            " IS E'登録日時';
COMMENT ON COLUMN "mst_zai_output_pattern"."up_date             " IS E'更新日時';
■テストデータ
facility_cd
```
