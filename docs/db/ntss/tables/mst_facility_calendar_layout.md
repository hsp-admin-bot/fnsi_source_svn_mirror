# mst_facility_calendar_layout

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mst_facility_calendar_layout`
- Logical name: 施設カレンダーレイアウトマスタ
- Physical name: `mst_facility_calendar_layout`
- Prefix group: `master`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `facility_calendar_layout_cd`
- Column count: 8
- NOT NULL columns: 2

## Related Config / Notes

- [../config/mst_facility_calendar_layout.md](../config/mst_facility_calendar_layout.md)

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 施設カレンダーレイアウトコード | facility_calendar_layout_cd | bigserial |  | 1 |  | シーケンス |
|  | 施設コード | facility_cd | character varying |  | 1 |  | mst_facility.facility_cd |
|  | 施設カレンダーレイアウト名 | facility_calendar_layout_name | character varying |  |  |  |  |
|  | 表示項目 | disp_item_info | jsonb |  |  |  | @mst_facility_calendar_layoutの参考 |
|  | 表示フラグ | is_disp | character varying | 1 |  |  |  |
|  | 削除フラグ | is_del | character varying | 1 |  |  |  |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
