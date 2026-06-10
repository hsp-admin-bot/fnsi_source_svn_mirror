# mst_if_edge

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mst_if_edge`
- Logical name: 連携エッジマスタ
- Physical name: `mst_if_edge`
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
| 1 | 製造番号 | serial_no | character varying | 20 | 1 |  |  |
|  | 施設コード | facility_cd | character varying | 6 |  |  |  |
|  | IFエッジ番号 | if_edge_no | numeric | 2 |  |  |  |
|  | IFエッジ名 | if_edge_name | character varying |  |  |  |  |
|  | 表示フラグ | is_disp | character varying | 1 |  |  |  |
|  | 削除フラグ | is_del | character varying | 1 |  |  |  |
|  | 設置日 | setting_date | timestamp(3) |  |  |  |  |
|  | 破棄日 | delete_date | timestamp(3) |  |  |  |  |
|  | メモ | memo | character varying |  |  |  |  |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
