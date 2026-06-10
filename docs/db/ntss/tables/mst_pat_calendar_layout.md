# mst_pat_calendar_layout

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mst_pat_calendar_layout`
- Logical name: 患者カレンダーレイアウトマスタ
- Physical name: `mst_pat_calendar_layout`
- Prefix group: `master`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `pat_calendar_layout_cd`
- Column count: 9
- NOT NULL columns: 1

## Related Config / Notes

- [../config/mst_pat_calendar_layout.md](../config/mst_pat_calendar_layout.md)

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 患者カレンダーレイアウトコード | pat_calendar_layout_cd | bigserial |  | 1 |  |  |
|  | 施設コード | facility_cd | character varying | 6 |  |  | 施設マスタ.施設コード |
|  | 患者カレンダーレイアウト名 | pat_calendar_layout_name | character varying |  |  |  |  |
|  | 表示項目 | disp_item_info | jsonb |  |  |  | 表示項目についてはシート「@mst_pat_calendar_layout」を参照 |
|  | 表示フラグ | is_disp | character varying | 1 |  |  |  |
|  | 削除フラグ | is_del | character varying | 1 |  |  |  |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
|  | 表示区分 | disp_class | character varying | 1 |  |  | "0": 指示/実績、"1": 指示、"2": 実績 |
