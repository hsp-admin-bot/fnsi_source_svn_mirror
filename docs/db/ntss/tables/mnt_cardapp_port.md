# mnt_cardapp_port

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mnt_cardapp_port`
- Logical name: カードアプリポート管理
- Physical name: `mnt_cardapp_port`
- Prefix group: `maintenance-state`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `guid`
- Column count: 6
- NOT NULL columns: 5

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | カードアプリのGUID | guid | character varying | 80 | 1 |  |  |
|  | 施設コード | facility_cd | character varying | 6 | 1 |  |  |
|  | クライアント識別子 | client_key | character varying | 256 | 1 |  |  |
|  | ポート | port | integer |  | 1 |  |  |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  | 1 |  |  |
