# mnt_if_edge_client_connect

- Source workbook: `NTSSデータベース設計書_外部データ連携.xlsm`
- Source sheet: `mnt_if_edge_client_connect`
- Logical name: 連携エッジクライアント接続状態
- Physical name: `mnt_if_edge_client_connect`
- Source physical cell: `mnt_if_edge_client_connect`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `facility_cd`

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 施設コード | facility_cd | character varying | 6 | 1 |  | 接続した施設コード |
|  | 通信サービス稼働IPアドレス | ip_address | inet |  |  |  |  |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |

## SQL

```sql
↓★以下のSQL文をコピーし、「A5(SQL Mk-2)」から実行して下さい
■SQL文
-- テーブル削除
DROP TABLE IF EXISTS mnt_if_edge_client_connect;
-- テーブル作成
CREATE TABLE mnt_if_edge_client_connect
(
facility_cd character varying(6) NOT NULL,  --施設コード
ip_address inet,  --通信サービス稼働IPアドレス
reg_date timestamp(3),  --登録日時
up_date timestamp(3),  --更新日時
CONSTRAINT unq_mnt_if_edge_client_connect_01 PRIMARY KEY (facility_cd)
using index tablespace ntss_index5
)
WITH (
OIDS=FALSE
)
tablespace ntss_db5;
-- ユーザ設定
ALTER TABLE mnt_if_edge_client_connect OWNER TO nkk5;
-- コメント追加
COMMENT ON TABLE "mnt_if_edge_client_connect" IS E'連携エッジクライアント接続状態';
COMMENT ON COLUMN "mnt_if_edge_client_connect"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mnt_if_edge_client_connect"."ip_address" IS E'通信サービス稼働IPアドレス';
COMMENT ON COLUMN "mnt_if_edge_client_connect"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mnt_if_edge_client_connect"."up_date" IS E'更新日時';
■テストデータ
facility_cd
```
