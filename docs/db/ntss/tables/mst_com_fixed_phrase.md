# mst_com_fixed_phrase

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mst_com_fixed_phrase`
- Logical name: 共通定型文マスタ
- Physical name: `mst_com_fixed_phrase`
- Prefix group: `master`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `com_fixed_phrase_cd`
- Column count: 9
- NOT NULL columns: 1

## Related Config / Notes

- [../config/mst_com_fixed_phrase.md](../config/mst_com_fixed_phrase.md)

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 共通定型文コード | com_fixed_phrase_cd | serial |  | 1 |  |  |
|  | 施設コード | facility_cd | character varying | 6 |  |  |  |
|  | 定型文 | com_fixed_phrase | character varying |  |  |  |  |
|  | 職種 | occupations | jsonb |  |  |  |  |
|  | 表示フラグ | is_disp | character varying | 1 |  | '1' | '0'：非表示、'1'：表示 |
|  | 削除フラグ | is_del | character varying | 1 |  | '0' | '0':通常、'1':削除 |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
|  | FNW+で管理する施設内の一意な指示簿指示コード | fn_addition_cd | varchar | 10 |  |  |  |
