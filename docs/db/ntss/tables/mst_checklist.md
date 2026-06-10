# mst_checklist

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mst_checklist`
- Logical name: チェックリストマスタ
- Physical name: `mst_checklist`
- Prefix group: `master`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `checklist_cd`
- Column count: 7
- NOT NULL columns: 2

## Related Config / Notes

- [../config/mst_checklist.md](../config/mst_checklist.md)
- [../config/mst_com_fixed_phrase.md](../config/mst_com_fixed_phrase.md)

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | チェックリストコード | checklist_cd | bigserial |  | 1 |  |  |
|  | 施設コード | facility_cd | character varying | 6 | 1 |  |  |
|  | チェックリスト設定 | checklist_settings | jsonb |  |  |  | ■@mst_checklist |
|  | 表示フラグ | is_disp | character varying | 1 |  | '1' | '0'：非表示、'1'：表示 |
|  | 削除フラグ | is_del | character varying | 1 |  | '0' | '0':通常、'1':削除 |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
