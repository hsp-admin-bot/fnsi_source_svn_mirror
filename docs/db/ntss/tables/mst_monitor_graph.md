# mst_monitor_graph

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mst_monitor_graph`
- Logical name: モニタグラフマスタ
- Physical name: `mst_monitor_graph`
- Prefix group: `master`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `monitor_graph_cd`
- Column count: 28
- NOT NULL columns: 1

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | モニタグラフコード | monitor_graph_cd | serial |  | 1 |  |  |
|  | 施設コード | facility_cd | character varying | 6 |  |  | mst_facility.facility_cd |
|  | モニタグラフ名 | monitor_graph_name | character varying | 256 |  |  |  |
|  | 左項目コード | left_data_index | character varying | 5 |  |  | 「sys_monitor_item」シートの「新通信/特殊浄化」に該当する「moni_data_cd」を設定する。 |
|  | 左グラフ色 | left_color | character varying | 7 |  |  |  |
|  | 右項目コード | right_data_index | character varying | 5 |  |  | 「sys_monitor_item」シートの「新通信/特殊浄化」に該当する「moni_data_cd」を設定する。 |
|  | 右グラフ色 | right_color | character varying | 7 |  |  |  |
|  | 表示フラグ | is_disp | character varying | 1 |  | '1' | '0'：非表示、'1'：表示 |
|  | 削除フラグ | is_del | character varying | 1 |  | '0' | '0':通常、'1':削除 |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
|  | 左線サイズ | left_line_size | integer |  |  |  |  |
|  | 左線タイプ値 | left_line_type_value | character varying | 10 |  |  |  |
|  | 左ポイント色 | left_point_color | character varying | 7 |  |  |  |
|  | 左ポイントサイズ | left_point_size | integer |  |  |  |  |
|  | 左ポイントタイプ値 | left_point_type_value | character varying | 15 |  |  |  |
|  | 右線サイズ | right_line_size | integer |  |  |  |  |
|  | 右線タイプ値 | right_line_type_value | character varying | 10 |  |  |  |
|  | 右ポイント色 | right_point_color | character varying | 7 |  |  |  |
|  | 右ポイントサイズ | right_point_size | integer |  |  |  |  |
|  | 右ポイントタイプ値 | right_point_type_value | character varying | 15 |  |  |  |
|  | 左項目元 | left_is_mst_monitor | integer | 5 |  | 0 | 0 : sys_monitor_item<br>1 : mst_add_monitor |
|  | 右項目元 | right_is_mst_monitor | integer | 5 |  | 0 | 0 : sys_monitor_item<br>1 : mst_add_monitor |
|  | 左グラフ上限 | left_graph_upper_limit | integer | 10 |  |  |  |
|  | 右グラフ上限 | right_graph_upper_limit | integer | 10 |  |  |  |
|  | 左グラフ下限 | left_graph_lower_limit | integer | 10 |  |  |  |
|  | 右グラフ下限' | right_graph_lower_limit | integer | 10 |  |  |  |
|  | FNW+で管理する施設内の一意なコード | fn_monitor_graph_cd | integer | 64 |  |  |  |
