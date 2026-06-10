# mst_com_fixed_phrase

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `@mst_com_fixed_phrase`
- Category: config/reference

## Content

| col1 | col2 |
| --- | --- |
|  | 定型文設定 |
|  | 利用者が保持 |
| 主キー | 定型文コード |
|  | 利用者ID |
|  | 定型文 |
|  | 表示フラグ |
|  | 削除フラグ |
|  | 登録日時 |
|  | 更新日時 |
|  | 個人設定で登録(ユーザーフロートから個人設定を表示) |
|  | 個人設定画面の左側にタブが表示され、そこに「定型文」というタブを表示する |
|  | ※表示順について、mst_selectorに格納するかどうか |
|  | →現状、mst_selectorの主キーが「マスタ名」「施設コード」になる予定だが、 |
|  | ※利用者マスタにカラム追加して定型文を持つ？ |
|  | →医療情報DBの方(mst_user) |
|  | →定型文設定のテーブルが不要になる |
|  | →並び順もmst_selectorに登録する必要がない |
