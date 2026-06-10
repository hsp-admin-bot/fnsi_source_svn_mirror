# mst_if_edge_command

- Source workbook: `NTSSデータベース設計書_外部データ連携.xlsm`
- Source sheet: `mst_if_edge_command`
- Logical name: 連携エッジコマンドマスタ
- Physical name: `mst_if_edge_command`
- Source physical cell: `mst_if_edge_command`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `ctl_no`

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 管理番号 | ctl_no | bigserial |  | 1 |  |  |
|  | コマンドキー | command_key | character varying | 30 | 1 |  |  |
|  | コマンド内容 | command | character varying |  |  |  |  |
|  | 設定ファイル追加 | add_setting | character varying | 1 |  |  | '1'. mst_coop_facility.if_edge_settingを指定ディレクトリに保管<br>上記以外、何もなし |
|  | 削除フラグ | is_del | character varying | 1 |  |  |  |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
|  |  | processing | character varying | 255 |  |  |  |
|  |  | processing_detail | character varying | 255 |  |  |  |

## SQL

```sql
↓★以下のSQL文をコピーし、「A5(SQL Mk-2)」から実行して下さい
■SQL文
-- テーブル削除
DROP TABLE IF EXISTS mst_if_edge_command;
-- テーブル作成
CREATE TABLE mst_if_edge_command
(
ctl_no bigserial NOT NULL,  --管理番号
command_key character varying(30) NOT NULL,  --コマンドキー
command character varying,  --コマンド内容
add_setting character varying(1),  --設定ファイル追加
is_del character varying(1),  --削除フラグ
reg_date timestamp(3),  --登録日時
up_date timestamp(3),  --更新日時
processing character varying(255),
processing_detail character varying(255),
CONSTRAINT unq_mst_if_edge_command_01 PRIMARY KEY (ctl_no)
using index tablespace ntss_index5
)
WITH (
OIDS=FALSE
)
tablespace ntss_db5;
-- ユーザ設定
ALTER TABLE mst_if_edge_command OWNER TO nkk5;
-- コメント追加
COMMENT ON TABLE "mst_if_edge_command" IS E'連携エッジコマンドマスタ';
COMMENT ON COLUMN "mst_if_edge_command"."ctl_no" IS E'管理番号';
COMMENT ON COLUMN "mst_if_edge_command"."command_key" IS E'コマンドキー';
COMMENT ON COLUMN "mst_if_edge_command"."command" IS E'コマンド内容';
COMMENT ON COLUMN "mst_if_edge_command"."add_setting" IS E'設定ファイル追加';
COMMENT ON COLUMN "mst_if_edge_command"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "mst_if_edge_command"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mst_if_edge_command"."up_date" IS E'更新日時';
=IF(D17="","","COMMENT ON COLUMN " & """" & $C$5 & """.""" & D17 & """ IS E'" & C17 & "';")
■テストデータ
ctl_no
```
