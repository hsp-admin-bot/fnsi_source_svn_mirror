# mst_pat_list_layout

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mst_pat_list_layout`
- Logical name: マルチ患者レイアウトマスタ
- Physical name: `mst_pat_list_layout`
- Prefix group: `master`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `pat_list_layout_cd`
- Column count: 10
- NOT NULL columns: 1

## Related Config / Notes

- [../config/sheet_2.md](../config/sheet_2.md)

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | マルチ患者レイアウトコード | pat_list_layout_cd | bigserial |  | 1 |  |  |
|  | 施設コード | facility_cd | character varying | 6 |  |  |  |
|  | マルチ患者レイアウト名 | pat_list_layout_name | character varying |  |  |  |  |
|  | 表示項目 | disp_item_info | jsonb |  |  |  | ■Json構造<br>[<br>　｛ <br>     category: カテゴリ名,<br>     items: [ 表示項目キー名 ] <br>   ｝, ・・・<br>]<br>選択可能な表示項目は「@マルチ患者レイアウトマスタ」を参照<br>※Jsonには表示対象のカテゴリ情報群のみ格納する。<br>※表示対象のカテゴリにおいて、itemsには表示対象の項目キー名を配列で格納する。 |
|  | 職種 | occupations | jsonb |  |  |  | ここで設定した職種に該当するログイン者が選択可能<br><br>■Json構造<br>[ <br>  職種コード<br> ]<br><br>※「-1」は、利用者マスタ上で「未登録（null）」のものを抽出するために利用しています。 |
|  | 表示フラグ | is_disp | character varying | 1 |  | '1' | '0'：非表示、'1'：表示 |
|  | 削除フラグ | is_del | character varying | 1 |  | '0' | '0':通常、'1':削除 |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
|  | テンプレートコード | template_cd | integer |  |  |  |  |
