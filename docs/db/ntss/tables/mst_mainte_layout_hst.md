# mst_mainte_layout_hst

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mst_mainte_layout_hst`
- Logical name: 日常・定期点検レイアウトマスタ履歴
- Physical name: `mst_mainte_layout_hst`
- Prefix group: `master`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `mente_layout_cd`
- Column count: 13
- NOT NULL columns: 2

## Related Tables

- Related table: [../tables/mst_mainte_layout.md](../tables/mst_mainte_layout.md)

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 点検レイアウトコード | mente_layout_cd | bigserial |  | 1 |  | シーケンス |
|  | 施設コード | facility_cd | character varying | 6 | 1 |  | mst_facility.facility_cd |
|  | レイアウトクラス | layout_class | character varying | 1 |  |  | '1'：日常点検用、'2'：定期点検用 |
|  | レイアウト名 | layout_name | character varying | 256 |  |  |  |
|  | マシンタイプリスト | type_info | jsonb |  |  |  | @mst_mainte_layoutで参考 |
|  | 詳細検査リスト1 | detail_info_1 | jsonb |  |  |  | 定期点検記録簿<br>@mst_mainte_layoutで参考 |
|  | 詳細検査リスト2 | detail_info_2 | jsonb |  |  |  | 定期交換部品記録簿<br>@mst_mainte_layoutで参考 |
|  | 表示フラグ | is_disp | character varying | 1 |  |  |  |
|  | 削除フラグ | is_del | character varying | 1 |  |  |  |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
|  | 版数 | edition_no | integer |  |  | 1 | 版数 |
|  | 力ラム名 | layout_header | character varying | 40 |  |  |  |
