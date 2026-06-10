# mst_graph_setting

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mst_graph_setting`
- Logical name: Ca9分割グラフ設定マスタ
- Physical name: `mst_graph_setting`
- Prefix group: `master`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `graph_setting_no,facility_cd`
- Column count: 5
- NOT NULL columns: 2

## Related Config / Notes

- [../config/mst_graph_setting.md](../config/mst_graph_setting.md)

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | Ca9分割グラフ設定番号 | graph_setting_no | character varying | 4 | 1 |  | 一覧は@mst_graph_settingで参照 |
| 1 | 施設コード | facility_cd | character varying | 6 | 1 |  |  |
|  | 値 | value | character varying |  |  |  |  |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
