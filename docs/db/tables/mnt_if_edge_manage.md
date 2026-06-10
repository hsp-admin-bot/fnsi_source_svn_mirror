# mnt_if_edge_manage

- Source workbook: `NTSSデータベース設計書_外部データ連携.xlsm`
- Source sheet: `mnt_if_edge_manage`
- Logical name: 連携エッジ制御指示管理
- Physical name: `mnt_if_edge_manage`
- Source physical cell: `mnt_if_edge_manage`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `ctl_no`

## Related Config / Reference Values

- [../config/edge_result.md](../config/edge_result.md)

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 管理番号 | ctl_no | bigserial |  | 1 |  |  |
|  | 施設コード | facility_cd | character varying | 6 | 1 |  | mst_facility.facility_cd |
|  | 応答ステータス | response_status | smallint |  | 1 |  | ステータス<br>　-2：異常<br>　-1：タイムアウト<br>　0：依頼中（応答なし含む）<br>　1：処理中<br>　2：完了 |
|  | 連携エッジ実行結果 | edge_result | jsonb |  |  |  | @edge_result |
|  | 削除フラグ | is_del | character varying | 1 |  |  |  |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |

## SQL

```sql
↓★以下のSQL文をコピーし、「A5(SQL Mk-2)」から実行して下さい
■SQL文
-- テーブル削除
DROP TABLE IF EXISTS mnt_if_edge_manage;
-- テーブル作成
CREATE TABLE mnt_if_edge_manage
(
ctl_no bigserial NOT NULL,  --管理番号
facility_cd character varying(6) NOT NULL,  --施設コード
response_status smallint NOT NULL,  --応答ステータス
edge_result jsonb,  --連携エッジ実行結果
is_del character varying(1),  --削除フラグ
reg_date timestamp(3),  --登録日時
up_date timestamp(3),  --更新日時
CONSTRAINT unq_mnt_if_edge_manage_01 PRIMARY KEY (ctl_no)
using index tablespace ntss_index5
)
WITH (
OIDS=FALSE
)
tablespace ntss_db5;
-- ユーザ設定
ALTER TABLE mnt_if_edge_manage OWNER TO nkk5;
-- コメント追加
COMMENT ON TABLE "mnt_if_edge_manage" IS E'連携エッジ制御指示管理';
COMMENT ON COLUMN "mnt_if_edge_manage"."ctl_no" IS E'管理番号';
COMMENT ON COLUMN "mnt_if_edge_manage"."response_status" IS E'応答ステータス';
COMMENT ON COLUMN "mnt_if_edge_manage"."edge_result" IS E'連携エッジ実行結果';
COMMENT ON COLUMN "mnt_if_edge_manage"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "mnt_if_edge_manage"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mnt_if_edge_manage"."up_date" IS E'更新日時';
■テストデータ
ctl_no
```
