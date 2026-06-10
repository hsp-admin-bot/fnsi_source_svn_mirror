# mnt_websocket_certification

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mnt_websocket_certification`
- Logical name: WebSocket認証キー情報
- Physical name: `mnt_websocket_certification`
- Prefix group: `maintenance-state`
- User: `nkk4`
- Tablespace DB: `ntss_db4`
- Tablespace INDEX: `ntss_index4`
- Primary key definition: `certification_cd`
- Column count: 4
- NOT NULL columns: 2

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 認証コード | certification_cd | character varying | 32 | 1 |  | 認証コード(UUID：ハイフンなし) |
|  | 施設コード | facility_cd | character varying | 6 | 1 |  | 施設マスタ.施設コード |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
