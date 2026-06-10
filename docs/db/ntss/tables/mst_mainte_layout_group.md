# mst_mainte_layout_group

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mst_mainte_layout_group`
- Logical name: 定期点検機種別レイアウトマスタ
- Physical name: `mst_mainte_layout_group`
- Prefix group: `master`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `mainte_layout_group_cd`
- Column count: 10
- NOT NULL columns: 3

## Related Tables

- Related table: [../tables/mst_mainte_layout_group_hst.md](../tables/mst_mainte_layout_group_hst.md)

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 点検レイアウトグループコード | mainte_layout_group_cd | bigserial |  | 1 |  | シーケンス |
|  | 施設コード | facility_cd | character varying | 6 | 1 |  | mst_facility.facility_cd |
|  | 点検レイアウトグループ名 | group_name | character varying | 256 |  |  |  |
|  | デフォルトレイアウト | layout_default | bigint |  | 1 |  | mst_mainte_layout.mainte_layout_cd |
|  | レイアウトリスト | layout_list | jsonb |  |  |  | [<br>mst_mainte_layout.mainte_layout_cd (Number),<br>..<br>] |
|  | 表示フラグ | is_disp | character varying | 1 |  |  |  |
|  | 削除フラグ | is_del | character varying | 1 |  |  |  |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
|  | 版数 | edition_no | integer |  |  | 1 | 版数 |
