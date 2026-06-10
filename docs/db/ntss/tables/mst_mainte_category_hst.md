# mst_mainte_category_hst

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mst_mainte_category_hst`
- Logical name: 定期点検項目グループマスタ履歴
- Physical name: `mst_mainte_category_hst`
- Prefix group: `master`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `mainte_category_cd`
- Column count: 10
- NOT NULL columns: 2

## Related Tables

- Related table: [../tables/mst_mainte_category.md](../tables/mst_mainte_category.md)

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 点検カテゴリコード | mainte_category_cd | bigserial |  | 1 |  | シーケンス |
|  | 施設コード | facility_cd | character varying | 6 | 1 |  | mst_facility.facility_cd |
|  | カテゴリー名 | category_name | character | 256 |  |  | 見出し |
|  | 表示フラグ | is_disp | character varying | 1 |  |  |  |
|  | 削除フラグ | is_del | character varying | 1 |  |  |  |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
|  | 版数 | edition_no | integer |  |  | 1 | 版数 |
|  | 詳細 | detail | jsonb |  |  |  | 詳細<br>@mst_mainte_categoryで参考 |
|  | 用途 | mainte_class | character varying | 1 |  |  | 1:日常点検　2:定期点検 |
