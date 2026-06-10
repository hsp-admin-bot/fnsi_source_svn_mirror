# mst_trend_graph_template

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mst_trend_graph_template`
- Logical name: トレンドグラフテンプレートマスタ
- Physical name: `mst_trend_graph_template`
- Prefix group: `master`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `template_cd`
- Column count: 15
- NOT NULL columns: 2

## Related Config / Notes

- [../config/mst_trend_graph_template.md](../config/mst_trend_graph_template.md)

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | テンプレートコード | template_cd | bigserial |  | 1 |  |  |
|  | 施設コード | facility_cd | character varying | 6 | 1 |  | mst_facility.facility_cd |
|  | テンプレート名称 | template_name | character varying | 50 |  |  |  |
|  | 装置種別 | model | character varying | 3 |  |  | mst_machine_type.model |
|  | 縦軸範囲(右)最大値 | vertical_range_right_max | numeric | 6,2 |  |  |  |
|  | 縦軸範囲(右)最小値 | vertical_range_right_min | numeric | 6,2 |  |  |  |
|  | 縦軸範囲(左)最大値 | vertical_range_left_max | numeric | 6,2 |  |  |  |
|  | 縦軸範囲(左)最小値 | vertical_range_left_min | numeric | 6,2 |  |  |  |
|  | グラフ系列情報 | series_info | jsonb |  |  |  | @mst_trend_graph_template |
|  | 表示フラグ | is_disp | character varying | 1 |  | '1' | '0'：非表示、'1'：表示 |
|  | 削除フラグ | is_del | character varying | 1 |  | '0' | '0':通常、'1':削除 |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
|  | 通信フォーマット | com_format_cd | character varying | 1 |  |  |  |
|  | FNW+で管理する施設内の一意なコード | fn_template_cd | character varying |  |  |  |  |
