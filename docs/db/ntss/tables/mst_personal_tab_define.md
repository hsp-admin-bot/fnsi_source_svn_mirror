# mst_personal_tab_define

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mst_personal_tab_define`
- Logical name: 施設ごとの個人設定タブ定義
- Physical name: `mst_personal_tab_define`
- Prefix group: `master`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `tab_define_cd`
- Column count: 10
- NOT NULL columns: 5

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | タブ定義コード | tab_define_cd | serial |  | 1 |  |  |
|  | 施設コード | facility_cd | character varying |  |  |  |  |
|  | タブ表示名 | display_name | character varying | 100 | 1 |  |  |
|  | タブコンテンツID | contents_id | character varying | 500 | 1 |  | タブに表示したいコンポーネントを紐付けるID |
|  | タブの表示順（昇順） | disp_order | smallint |  | 1 |  |  |
|  | モード | mode | character varying | 1 | 1 |  | '1':共通画面を使用、'2':個別画面を使用 |
|  | 表示フラグ | is_disp | character varying | 1 |  | '1' | '0'：非表示、'1'：表示 |
|  | 削除フラグ | is_del | character varying | 1 |  | '0' | '0':通常、'1':削除 |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
