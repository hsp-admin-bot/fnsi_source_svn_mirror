# mst_holiday

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mst_holiday`
- Logical name: 休日マスタ
- Physical name: `mst_holiday`
- Prefix group: `master`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `holiday_cd`
- Column count: 11
- NOT NULL columns: 1

## Related Config / Notes

- [../config/holiday_detail.md](../config/holiday_detail.md)

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 休日シーケンス番号 | holiday_cd | bigserial |  | 1 |  | シーケンス |
|  | 施設コード | facility_cd | character varying | 6 |  |  |  |
|  | 年 | holiday_year | integer |  |  |  |  |
|  | 休日リスト | holiday_detail | jsonb |  |  |  | @holiday_detail参考 |
|  | 表示フラグ | is_disp | character varying | 1 |  | '1' | '0' : 非表示、'1' : 表示 |
|  | 削除フラグ | is_del | character varying | 1 |  | '0' | '0' : 通常、'1' : 削除 |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
|  | 種別コード | class | character varying | 1 |  |  | '0' : 祝日、'1' : 施設固有日 |
|  | 休日詳細 | holiday_json | jsonb |  |  |  |  |
|  | 対象年 | holiday_y | bigint | 32 |  |  |  |
