# 【未反映】マルチ患者一覧レイアウトマスタ

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `@【未反映】マルチ患者一覧レイアウトマスタ`
- Category: config/reference

## Content

| col1 | col2 | col3 | col4 | col5 |
| --- | --- | --- | --- | --- |
|  | mst_pat_list_layout |  |  |  |
| 主キー | マルチ患者一覧レイアウトコード | pat_list_layout_cd | serial |  |
|  | 施設コード |  |  |  |
|  | マルチ患者一覧レイアウト名 |  |  |  |
|  | 表示項目 |  | jsonb | item_cd |
|  | 職種 |  | jsonb | ここで設定した職種に該当しているログイン者が選択可能 |
|  | 表示フラグ |  |  |  |
|  | 削除フラグ |  |  |  |
|  | 登録日時 |  |  |  |
|  | 更新日時 |  |  |  |
