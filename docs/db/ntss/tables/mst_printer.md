# mst_printer

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mst_printer`
- Logical name: プリンターマスタ
- Physical name: `mst_printer`
- Prefix group: `master`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `printer_cd`
- Column count: 9
- NOT NULL columns: 2

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | プリンターCD | printer_cd | bigserial |  | 1 |  | シーケンス使用 |
|  | 施設コード | facility_cd | character varying | 6 | 1 |  | 施設マスタ.施設コード |
|  | クライアント識別子 | client_key | character varying | 256 |  |  | クライアント識別子。<br>WebSocket接続時に通知する{施設コード}{クライアント識別子}の{クライアント識別子}部分<br>例：999900PRINTS01の場合はPRINTS01 |
|  | プリンタ名 | printer_name | character varying | 256 |  |  | プリンタ名。出力先として使用する。 |
|  | 表示プリンタ名 | disp_printer_name | character varying | 256 |  |  | 表示用プリンタ名。同一プリンタを区別するためのプリンタ名 |
|  | 表示フラグ | is_disp | character varying | 1 |  | '1' | '0'：非表示、'1'：表示 |
|  | 削除フラグ | is_del | character varying | 1 |  | '0' | '0':通常、'1':削除 |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
