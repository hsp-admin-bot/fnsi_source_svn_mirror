# mnt_find_machine

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mnt_find_machine`
- Logical name: 装置自動登録処理用ワークテーブル
- Physical name: `mnt_find_machine`
- Prefix group: `maintenance-state`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `facility_cd,com_format_cd,machine_serial,com_type,ip_address`
- Column count: 8
- NOT NULL columns: 2

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 施設コード | facility_cd | character varying | 6 | 1 |  | 施設マスタ.施設コード |
| 1 | 通信フォーマット | com_format_cd | character varying | 1 |  |  | 「@mst_machine」シート参照 |
| 1 | 製造番号 | machine_serial | character varying | 8 | 1 |  | 新通信：7桁<br>NX通信：8桁<br>医器工：8桁（ダミーの製造番号使用）<br>★製造番号が8桁未満の場合、右側に半角スペースをパディング<br>★比較時はTrim後に比較すること |
| 1 | 通信種別 | com_type | numeric | 1,0 |  |  | 0：通信なし(オフライン運用)、1：新通信、2：NX通信、3：医器工V4 |
| 1 | IPアドレス | ip_address | inet |  |  |  |  |
|  | デバイスエッジ番号 | device_edge_no | numeric | 2,0 |  |  | デバイスエッジマスタ.デバイスエッジ番号 |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
