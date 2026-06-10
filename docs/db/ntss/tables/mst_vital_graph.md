# mst_vital_graph

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mst_vital_graph`
- Logical name: バイタルグラフマスタ
- Physical name: `mst_vital_graph`
- Prefix group: `master`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `vital_graph_cd`
- Column count: 14
- NOT NULL columns: 1

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | バイタルグラフコード | vital_graph_cd | serial |  | 1 |  |  |
|  | 施設コード | facility_cd | character varying | 6 |  |  | mst_facility.facility_cd |
|  | バイタルグラフ名 | vital_graph_name | character varying | 256 |  |  |  |
|  | 線色 | vital_line_color | character varying | 7 |  |  |  |
|  | 線サイズ | vital_line_size | integer |  |  |  |  |
|  | 線タイプ | vital_line_type_value | character varying | 10 |  |  |  |
|  | ポイント色 | vital_point_color | character varying | 7 |  |  |  |
|  | ポイントサイズ | vital_point_size | integer |  |  |  |  |
|  | ポイントタイプ | vital_point_type_value | character varying | 15 |  |  |  |
|  | 表示フラグ | is_disp | character varying | 1 |  | '1' | '0'：非表示、'1'：表示 |
|  | 削除フラグ | is_del | character varying | 1 |  | '0' | '0':通常、'1':削除 |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
|  | FNW+で管理する施設内の一意な職種コード | fn_vital_graph_cd | character varying | 3 |  |  |  |
