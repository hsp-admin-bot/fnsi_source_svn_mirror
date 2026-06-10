# mst_trend_graph_monitor_set

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mst_trend_graph_monitor_set`
- Logical name: トレンドグラフモニタ項目一覧セットマスタ
- Physical name: `mst_trend_graph_monitor_set`
- Prefix group: `master`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `monitor_set_cd`
- Column count: 10
- NOT NULL columns: 2

## Related Config / Notes

- [../config/mst_trend_graph_monitor_set.md](../config/mst_trend_graph_monitor_set.md)

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 項目セットコード | monitor_set_cd | bigserial |  | 1 |  |  |
|  | 施設コード | facility_cd | character varying | 6 | 1 |  | mst_facility.facility_cd |
|  | 項目セット名称 | monitor_set_name | character varying | 50 |  |  |  |
|  | 装置種別 | model | character varying | 3 |  |  | mst_machine_type.model |
|  | モニタ項目一覧セット | series_info | jsonb |  |  |  | @mst_trend_graph_monitor_set |
|  | 表示フラグ | is_disp | character varying | 1 |  | '1' | '0'：非表示、'1'：表示 |
|  | 削除フラグ | is_del | character varying | 1 |  | '0' | '0':通常、'1':削除 |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
|  | 通信フォーマット | com_format_cd | character varying | 1 |  |  |  |
