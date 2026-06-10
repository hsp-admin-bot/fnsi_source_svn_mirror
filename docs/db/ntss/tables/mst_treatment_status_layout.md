# mst_treatment_status_layout

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mst_treatment_status_layout`
- Logical name: 治療状況レイアウトマスタ
- Physical name: `mst_treatment_status_layout`
- Prefix group: `master`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `layout_no`
- Column count: 12
- NOT NULL columns: 2

## Related Config / Notes

- [../config/mst_treatment_status_layout.md](../config/mst_treatment_status_layout.md)

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 治療状況レイアウト管理番号 | layout_no | bigserial |  | 1 |  | 治療状況レイアウト管理番号 |
|  | 施設コード | facility_cd | character varying | 6 | 1 |  | 施設マスタ.施設コード |
|  | レイアウト名 | layout_name | character varying | 20 |  |  |  |
|  | 使用区分 | use_class | character varying | 1 |  | '0' | 0'：リスト、'1'：マップ |
|  | DCS表示項目一覧 | dcs_view_items | jsonb |  |  |  | 透析装置(ベッド)で表示される項目一覧 |
|  | DAB表示項目一覧 | dab_view_items | jsonb |  |  |  | 供給装置で表示される項目一覧 |
|  | DAD表示項目一覧 | dad_view_items | jsonb |  |  |  | 溶解装置で表示される項目一覧 |
|  | DRO表示項目一覧 | dro_view_items | jsonb |  |  |  | 逆浸透水処理装置で表示される項目一覧 |
|  | 表示フラグ | is_disp | character varying | 1 |  | '1' | '0'：非表示、'1'：表示 |
|  | 削除フラグ | is_del | character varying | 1 |  | '0' | '0':通常、'1':削除 |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
