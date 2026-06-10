# mst_status_map_bed_layout

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mst_status_map_bed_layout`
- Logical name: 治療状況マップ用レイアウトマスタ
- Physical name: `mst_status_map_bed_layout`
- Prefix group: `master`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `layout_id`
- Column count: 10
- NOT NULL columns: 2

## Related Config / Notes

- [../config/mst_status_map_bed_layout.md](../config/mst_status_map_bed_layout.md)

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | システムで管理する一意なレイアウト番号 | layout_id | bigserial |  | 1 |  |  |
|  | 登録施設コード | facility_cd | character varying | 6 | 1 |  |  |
|  | レイアウト名 | layout_name | character varying | 40 |  |  |  |
|  | ベッドレイアウト | bed_layout | jsonb |  |  |  | ベッドレイアウト情報<br>@mst_status_map_bed_layout参照 |
|  | 背景画像 | background_image | bytea |  |  |  |  |
|  | 表示フラグ | is_disp | character varying | 1 |  | '1' | '0'：非表示、'1'：表示 |
|  | 削除フラグ | is_del | character varying | 1 |  | '0' | '0':通常、'1':削除 |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
|  | 在宅フラグ | is_home_dialysis | character varying | 1 |  |  |  |
