# mnt_water_survey

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mnt_water_survey`
- Logical name: 水質管理
- Physical name: `mnt_water_survey`
- Prefix group: `maintenance-state`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `survey_record_no`
- Column count: 8
- NOT NULL columns: 2

## Related Config / Notes

- [../config/mnt_water_survey.md](../config/mnt_water_survey.md)

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 検査結果コード | survey_record_no | bigserial |  | 1 |  | シーケンス |
|  | 施設コード | facility_cd | character varying | 6 | 1 |  | mst_facility.facility_cd |
|  | 水質データ | survey_data | jsonb |  |  |  | @mnt_water_surveyで参考 |
|  | 検査日 | inspection_date | timestamp(3) |  |  |  |  |
|  | 表示フラグ | is_disp | character varying | 1 |  |  |  |
|  | 削除フラグ | is_del | character varying | 1 |  |  |  |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
