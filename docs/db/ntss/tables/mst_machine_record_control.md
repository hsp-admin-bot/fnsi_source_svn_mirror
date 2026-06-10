# mst_machine_record_control

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mst_machine_record_control`
- Logical name: 装置記録マスタControl
- Physical name: `mst_machine_record_control`
- Prefix group: `master`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `facility_cd,machine_record_cd`
- Column count: 8
- NOT NULL columns: 2

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 施設コード | facility_cd | character varying | 6 | 1 |  |  |
| 1 | 装置記録コード | machine_record_cd | character varying | 4 | 1 |  | 日機装装置：0000～FFFF<br>死活監視用：G000～GZZZ |
|  | 装置記録メッセージ | machine_record_message | character varying | 256 |  |  |  |
|  | 表示フラグ | disp_flg | character varying | 1 |  |  | 0：表示しない<br>1：愁訴処置画面のみ表示する<br>2：愁訴処置画面+帳票表示する |
|  | 表示フラグ | disp_flg | character varying | 1 |  |  |  |
|  | 表示フラグ | disp_flg | character varying | 1 |  |  |  |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
