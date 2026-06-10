# mst_exam_item

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mst_exam_item`
- Logical name: 検査項目マスタ
- Physical name: `mst_exam_item`
- Prefix group: `master`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `exam_item_cd`
- Column count: 37
- NOT NULL columns: 2

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | システムで管理する一意な検査項目コード | exam_item_cd | bigserial |  | 1 |  |  |
|  | 施設コード | facility_cd | character varying | 6 | 1 |  |  |
|  | FNW+で管理する施設内の一意な検査項目コード | fn_exam_item_cd | character varying | 10 |  |  |  |
|  | 検査項目名 | exam_item_name | character varying | 40 |  |  |  |
|  | データ形式 | data_type | character varying | 1 |  | '1' | 0'：文字、'1'：数値 |
|  | 単位 | unit | character varying | 20 |  |  |  |
|  | 正常値区分 | normal_value_class | character varying | 1 |  | '0' | 0'：共通、'1'：男女 |
|  | 正常値(上限) | normal_value_upper | character varying |  |  |  |  |
|  | 正常値(下限) | normal_value_lower | character varying |  |  |  |  |
|  | 正常値(男性上限) | normal_value_upper_m | character varying |  |  |  |  |
|  | 正常値(男性下限) | normal_value_lower_m | character varying |  |  |  |  |
|  | 正常値(女性上限) | normal_value_upper_w | character varying |  |  |  |  |
|  | 正常値(女性下限) | normal_value_lower_w | character varying |  |  |  |  |
|  | 入力整数部桁数 | input_integer_figure | numeric | 2 |  |  |  |
|  | 入力小数部桁数 | input_decimal_figure | numeric | 2 |  |  |  |
|  | 入力上限値 | input_upper | character varying |  |  |  |  |
|  | 入力下限値 | input_lower | character varying |  |  |  |  |
|  | グラフ上限値 | graph_upper | character varying |  |  |  |  |
|  | グラフ下限値 | graph_lower | character varying |  |  |  |  |
|  | 仮想端末表示対象区分 | console_class | character varying | 1 |  | '0' | 0'：対象外、'1'：対象 |
|  | 検査使用区分 | exam_class | character varying | 1 |  | '0' | ’0'：検査項目、'1'：システム標準計算項目、'2'：検査計算項目 |
|  | 院内コード1 | in_hospital_cd1 | character varying | 20 |  |  |  |
|  | 属性コード1 | sbt_cd1 | character varying | 20 |  |  |  |
|  | 院内コード2 | in_hospital_cd2 | character varying | 20 |  |  |  |
|  | 属性コード2 | sbt_cd2 | character varying | 20 |  |  |  |
|  | 院内コード3 | in_hospital_cd3 | character varying | 20 |  |  |  |
|  | 属性コード3 | sbt_cd3 | character varying | 20 |  |  |  |
|  | 採血管コード | spitz_cd | bigint |  |  |  |  |
|  | JLAC10コード | jlac10_cd | character varying | 17 |  |  | Medis（医療情報システム開発センター）で管理されている検査項目毎のコード<br>mst_exam_standard.jlac10_cd |
|  | システム標準計算検査項目 | default_calc_exam_item_cd | character varying | 2 |  |  | 検査計算時に使用する検査項目を選択<br>0:未使用、1:BUN、2:血清Ca濃度、3:血清アルブミン、4:クレアチニン、5:血清鉄、6:総鉄結合能、7:検査計算使用 |
|  | 感染症コード | infection_cd | integer |  |  |  | mst_infection.infection_cd |
|  | 計算式領域 | free_calc | character varying | 1000 |  |  | 検査計算時の算出式 |
|  | 表示フラグ | is_disp | character varying | 1 |  | '1' | '0'：非表示、'1'：表示 |
|  | 削除フラグ | is_del | character varying | 1 |  | '0' | '0'：通常、'1'：削除 |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
|  | 透析工程フラグ | dialysis_progress_flag | character varying | 2 |  |  | 1：透析前 、2：透析後   3：すべて選択 |
