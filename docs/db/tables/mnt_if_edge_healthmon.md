# mnt_if_edge_healthmon

- Source workbook: `NTSSデータベース設計書_外部データ連携.xlsm`
- Source sheet: `mnt_if_edge_healthmon`
- Logical name: 連携エッジヘルスモニタ
- Physical name: `mnt_if_edge_healthmon`
- Source physical cell: `mnt_if_edge_healthmon`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `ctl_no`

## Related Config / Reference Values

- [../config/healthmon_facility_conn.md](../config/healthmon_facility_conn.md)

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 管理番号 | ctl_no | bigserial |  |  |  |  |
|  | 施設コード | facility_cd | character varying | 6 | 1 |  |  |
|  | IFエッジ番号 | if_edge_no | numeric | 2 | 1 |  |  |
|  | エッジステータス | healthmon_facility_conn | jsonb |  |  |  | 外部との通信ができているかを見ることができるモニター<br><br>「@healthmon_facility_conn」シート参照 |
|  | サーバステータス | healthmon_server_conn | jsonb |  |  |  | REST通信ができているかを見ることができるモニター（＝エッジの生存確認）<br><br>{<br>        "status": "xx",<br>        "moni_time": "2020-01-01 00:00:01"<br>}<br><br>/** サーバステータス：正常 */<br>SERVER_ACTIVE("01"),<br>/** サーバステータス：手動停止 */<br>SERVER_INACTIVE("F0"), |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
|  | 連携版番号 | coop_version | character varying | 10 | 1 | '' |  |

## SQL

```sql
↓★以下のSQL文をコピーし、「A5(SQL Mk-2)」から実行して下さい
■SQL文
-- テーブル削除
DROP TABLE IF EXISTS mnt_if_edge_healthmon;
-- テーブル作成
CREATE TABLE mnt_if_edge_healthmon
(
ctl_no bigserial,  --管理番号
facility_cd character varying(6) NOT NULL,  --施設コード
if_edge_no numeric(2) NOT NULL,  --IFエッジ番号
healthmon_facility_conn jsonb,  --エッジステータス
healthmon_server_conn jsonb,  --サーバステータス
reg_date timestamp(3),  --登録日時
up_date timestamp(3),  --更新日時
coop_version character varying(10) NOT NULL DEFAULT '',  --連携版番号
CONSTRAINT unq_mnt_if_edge_healthmon_01 PRIMARY KEY (ctl_no)
using index tablespace ntss_index5
)
WITH (
OIDS=FALSE
)
tablespace ntss_db5;
-- ユーザ設定
ALTER TABLE mnt_if_edge_healthmon OWNER TO nkk5;
-- コメント追加
COMMENT ON TABLE "mnt_if_edge_healthmon" IS E'連携エッジヘルスモニタ';
COMMENT ON COLUMN "mnt_if_edge_healthmon"."ctl_no" IS E'管理番号';
COMMENT ON COLUMN "mnt_if_edge_healthmon"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mnt_if_edge_healthmon"."if_edge_no" IS E'IFエッジ番号';
COMMENT ON COLUMN "mnt_if_edge_healthmon"."healthmon_facility_conn" IS E'エッジステータス';
COMMENT ON COLUMN "mnt_if_edge_healthmon"."healthmon_server_conn" IS E'サーバステータス';
COMMENT ON COLUMN "mnt_if_edge_healthmon"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mnt_if_edge_healthmon"."up_date" IS E'更新日時';
COMMENT ON COLUMN "mnt_if_edge_healthmon"."coop_version" IS E'連携版番号';
■テストデータ
ctl_no
```
