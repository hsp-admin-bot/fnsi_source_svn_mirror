# mst_medicate_timing

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mst_medicate_timing`
- Logical name: 投与タイミング
- Physical name: `mst_medicate_timing`
- Prefix group: `master`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `medicate_timing_cd`
- Column count: 11
- NOT NULL columns: 1

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 投与タイミングコード | medicate_timing_cd | serial |  | 1 |  |  |
|  | 施設コード | facility_cd | character varying | 6 |  |  |  |
|  | FNW+で管理する施設内の一意な投与タイミングコード | fn_medicate_timing_cd | character varying | 3 |  |  | FNW+フィードバック用<br>FNW+で管理する施設内の一意なコード |
|  | 投与タイミング名称 | medicate_timing_name | character varying | 40 |  |  |  |
|  | 透析工程コード | dialysis_progress_cd | character varying | 3 |  |  | 001':透析前<br>'002':透析中<br>'003':透析後<br>(マスタは、使用しない） |
|  | 治療開始後通知時間 | alert_time | smallint |  |  |  | 単位：分 |
|  | 通知フラグ | is_alert | character varying | 1 |  |  | '0'：通知しない、'1'：通知する |
|  | 表示フラグ | is_disp | character varying | 1 |  | '1' | '0'：非表示、'1'：表示 |
|  | 削除フラグ | is_del | character varying | 1 |  | '0' | '0':通常、'1':削除 |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
