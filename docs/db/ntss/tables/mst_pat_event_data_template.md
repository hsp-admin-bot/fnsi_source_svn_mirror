# mst_pat_event_data_template

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mst_pat_event_data_template`
- Logical name: 患者イベント項目テンプレートマスタ
- Physical name: `mst_pat_event_data_template`
- Prefix group: `master`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `template_cd`
- Column count: 9
- NOT NULL columns: 2

## Related Config / Notes

- [../config/mst_pat_event_data_template.md](../config/mst_pat_event_data_template.md)

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | テンプレートコード | template_cd | bigserial |  | 1 |  |  |
|  | 施設コード | facility_cd | character varying | 6 | 1 |  | mst_facility.facility_cd |
|  | テンプレート名称 | template_name | character varying | 40 |  |  |  |
|  | 項目情報 | input_params | jsonb |  |  |  | @mst_pat_event_data_template |
|  | 表示フラグ | is_disp | character varying | 1 |  | '1' | '0'：非表示、'1'：表示 |
|  | 削除フラグ | is_del | character varying | 1 |  | '0' | '0':通常、'1':削除 |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
|  | FNW+で管理する施設内の一意なコード | fn_template_cd | integer | 64 |  |  |  |
