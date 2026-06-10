# mnt_client_connect

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mnt_client_connect`
- Logical name: WebSocketクライアント接続状態
- Physical name: `mnt_client_connect`
- Prefix group: `maintenance-state`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `ip_address,facility_cd`
- Column count: 5
- NOT NULL columns: 2

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 通信サービス稼働IPアドレス | ip_address | inet |  | 1 |  | 通信サービスが稼働しているEC2のIPアドレス |
| 1 | 施設コード | facility_cd | character varying | 6 | 1 |  | 接続した施設コード |
|  | サーバ種別 | server_type | smallint |  |  |  | 0：DeviceServer、1：WebApServer |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
