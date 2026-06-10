# mst_pat_viewer_layout

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mst_pat_viewer_layout`
- Logical name: 患者経過総合ビューアレイアウトマスタ
- Physical name: `mst_pat_viewer_layout`
- Prefix group: `master`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `layout_cd`
- Column count: 10
- NOT NULL columns: 1

## Related Config / Notes

- [../config/mst_pat_viewer_layout.md](../config/mst_pat_viewer_layout.md)
- [../config/mst_pat_viewer_layout_2.md](../config/mst_pat_viewer_layout_2.md)

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | レイアウトコード | layout_cd | bigserial |  | 1 |  |  |
|  | 施設コード | facility_cd | character varying | 6 |  |  |  |
|  | レイアウト名 | layout_name | character varying |  |  |  |  |
|  | 表示項目 | disp_item_info | jsonb |  |  | E'[{"categoryNo":1,"categoryItem":[{"subCategoryNo":1,"subCategoryItem":[{"itemNo":1}]},{"subCategoryNo":2,"subCategoryItem":[{"itemNo":1}]},{"subCategoryNo":3,"subCategoryItem":[{"itemNo":1},{"itemNo":2},{"itemNo":3}]},{"subCategoryNo":4,"subCategoryItem":[{"itemNo":1},{"itemNo":2},{"itemNo":39},{"itemNo":3},{"itemNo":4},{"itemNo":5},{"itemNo":6},{"itemNo":7},{"itemNo":8},{"itemNo":9},{"itemNo":10},{"itemNo":11},{"itemNo":12},{"itemNo":13},{"itemNo":14},{"itemNo":15},{"itemNo":16},{"itemNo":17},{"itemNo":18},{"itemNo":19},{"itemNo":20},{"itemNo":21},{"itemNo":22},{"itemNo":23},{"itemNo":24},{"itemNo":25},{"itemNo":26},{"itemNo":27},{"itemNo":28},{"itemNo":29},{"itemNo":30},{"itemNo":31},{"itemNo":32},{"itemNo":33},{"itemNo":34},{"itemNo":35},{"itemNo":36},{"itemNo":37},{"itemNo":38}]},{"subCategoryNo":5,"subCategoryItem":[{"itemNo":1}]},{"subCategoryNo":6,"subCategoryItem":[{"itemNo":1}]},{"subCategoryNo":7,"subCategoryItem":[{"itemNo":1}]},{"subCategoryNo":8,"subCategoryItem":[{"itemNo":1}]},{"subCategoryNo":9,"subCategoryItem":[{"itemNo":1}]}]}]' | 表示項目についてはシート「@mst_pat_viewer_layout」を参照 |
|  | 表示フラグ | is_disp | character varying | 1 |  | '1' |  |
|  | 削除フラグ | is_del | character varying | 1 |  | '0' |  |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
|  | 表示期間区分 | disp_period_class | character varying | 1 |  |  | 0：3日・7日・14日、<br>1：12週・6ケ月・1年・3年 |
|  | FNW+で管理する施設内の一意な職種コード | fn_layout_cd | character varying | 5 |  |  |  |
