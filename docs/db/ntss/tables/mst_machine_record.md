# mst_machine_record

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mst_machine_record`
- Logical name: 装置記録マスタ
- Physical name: `mst_machine_record`
- Prefix group: `master`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `machine_record_cd`
- Column count: 8
- NOT NULL columns: 2

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 装置記録コード | machine_record_cd | character varying | 4 | 1 |  | 日機装装置：0000～FFFF<br>死活監視用：G000～GZZZ |
|  | 装置記録メッセージ | machine_record_message | character varying | 256 |  |  |  |
|  | 推奨項目 | is_default | character varying | 1 | 1 | '1' | '0'：非対象、'1'：対象 |
|  | ログ分類 | log_class | character varying | 1 |  |  | '1'：警報、'2'：報知、'3'：テスト、'4'：工程変更、'5'：操作、'6'：その他 |
|  | 対象機種 | target_model | character varying | 1 |  |  | '1'：共通、'2'：RO装置、'3'：溶解装置、'4'：供給装置、'5'：透析装置、'6'：その他 |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
|  | 表示フラグ | disp_flg | character varying | 1 |  | '0' |  |
