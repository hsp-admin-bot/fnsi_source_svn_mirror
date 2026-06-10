# mst_dialysis_progress

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mst_dialysis_progress`
- Logical name: 透析工程マスタ
- Physical name: `mst_dialysis_progress`
- Prefix group: `master`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `dialysis_prog_cd`
- Column count: 9
- NOT NULL columns: 1

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 透析工程コード | dialysis_prog_cd | bigserial |  | 1 |  |  |
|  | 施設コード | facility_cd | character varying | 6 |  |  |  |
|  | FNW+で管理する施設内の一意な透析工程コード | fn_dialysis_prog_cd | character varying | 3 |  |  | FNW+フィードバック用<br>FNW+で管理する施設内の一意なコード<br>'001'：透析開始前、'002':透析中、'003':透析終了後 |
|  | 透析工程名 | dialysis_prog_name | character varying |  |  |  |  |
|  | 入力タイミング | input_time | character varying | 1 |  |  | 入力のタイミング。<br>1:条件送信前、2:透析前、3:透析中、4:透析後 |
|  | 表示フラグ | is_disp | character varying | 1 |  | '1' | '0'：非表示、'1'：表示 |
|  | 削除フラグ | is_del | character varying | 1 |  | '0' | '0':通常、'1':削除 |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
