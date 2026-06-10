# advanced_settings

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `@advanced_settings`
- Category: config/reference

## Content

| col1 | col2 | col3 | col4 | col5 |
| --- | --- | --- | --- | --- |
| 拡張設定 |  |  |  |  |
| { |  |  |  |  |
|  | isShowInsurance | Number | 保険情報の表示・非表示 | １：表示、０:非表示 |
|  | isBvUfc | boolean |  | true:表示対象、false:非表示 |
|  | isDialysisAmountProgram | boolean |  | true:表示対象、false:非表示 |
|  | enableHemoDialysis | boolean |  | true:在宅透析施設、false:在宅透析しない |
| } |  |  |  |  |
| 【拡張設定】 |  |  |  |  |
| { |  |  |  |  |
| "func_advcds": [ |  | Array | 有効な拡張機能の配列 |  |
| { |  |  |  |  |
| "func_advcd": |  | string | 拡張機能コード | 拡張機能コード一覧 |
| }, |  |  |  |  |
| ... |  |  |  |  |
| ] |  |  |  |  |
| } |  |  |  |  |
