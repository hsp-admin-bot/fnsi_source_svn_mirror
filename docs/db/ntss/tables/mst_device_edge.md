# mst_device_edge

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mst_device_edge`
- Logical name: デバイスエッジマスタ
- Physical name: `mst_device_edge`
- Prefix group: `master`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `serial_no`
- Column count: 11
- NOT NULL columns: 1

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 製造番号 | serial_no | character varying | 20 | 1 |  | デバイスエッジの製造番号 |
|  | 施設コード | facility_cd | character varying | 6 |  |  | 施設マスタ.施設コード |
|  | デバイスエッジ番号 | device_edge_no | numeric | 2,0 |  |  |  |
|  | デバイス名 | device_name | character varying | 20 |  |  | デバイスエッジの名前 |
|  | 表示フラグ | is_disp | character varying | 1 |  | '1' | '0'：非表示、'1'：表示 |
|  | 削除フラグ | is_del | character varying | 1 |  | '0' | '0':通常、'1':削除 |
|  | 設置日 | setting_date | timestamp(3) |  |  |  |  |
|  | 破棄日 | delete_date | timestamp(3) |  |  |  |  |
|  | メモ | memo | character varying | 255 |  |  |  |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
