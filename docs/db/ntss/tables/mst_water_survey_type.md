# mst_water_survey_type

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mst_water_survey_type`
- Logical name: 水質検査種別マスタ
- Physical name: `mst_water_survey_type`
- Prefix group: `master`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `survey_type_cd`
- Column count: 18
- NOT NULL columns: 2

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 水質検査種別コード | survey_type_cd | bigserial |  | 1 |  | シーケンス |
|  | 施設コード | facility_cd | character varying | 6 | 1 |  | mst_facility.facility_cd |
|  | 水質検査種別名 | survey_type_name | character varying |  |  |  |  |
|  | 整数部桁数 | integer_digits | integer |  |  |  |  |
|  | 小数部桁数 | decimal_digits | integer |  |  |  |  |
|  | 単位 | unit | character varying |  |  |  |  |
|  | 結果初期値 | initial_value | character varying |  |  |  |  |
|  | しきい値判断上下区分 | initial_string | character varying |  |  |  | [{"text":"未満","checked":false,"isDefault":true},<br>{"text":"以下","checked":false,"isDefault":true},<br>{"text":"検出感度以下","checked":false,"isDefault":true},<br>{"text":"テスト1","checked":false,"isDefault":false},<br>{"text":"テスト2","checked":true,"isDefault":false}]<br>checked:選択フラグ<br>isDefault:デフォルトオプションフラグ |
|  | 閾値上限 | upper_threshold | numeric |  |  |  |  |
|  | 閾値下限 | lower_threshold | numeric |  |  |  |  |
|  | グラフ表示 | is_show_graph | character varying |  |  |  |  |
|  | グラフ上限 | graph_upper_limit | numeric |  |  |  |  |
|  | グラフ下限 | graph_lower_limit | numeric |  |  |  |  |
|  | 表示フラグ | is_disp | character varying | 1 |  |  |  |
|  | 削除フラグ | is_del | character varying | 1 |  |  |  |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
|  | FNW+で管理する施設内の一意なコード | fn_survey_point_cd | varchar | 10 |  |  |  |
