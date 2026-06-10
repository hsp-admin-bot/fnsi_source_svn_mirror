# mnt_water_survey

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `@mnt_water_survey`
- Category: config/reference

## Content

| col1 | col2 | col3 | col4 | col5 | col6 | col7 | col8 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| [ |  |  |  |  |  |  |  |
|  | { |  |  |  |  | null | キーなし |
|  |  | point_cd | Number | 水質調査箇所マスタのCD |  | × | × |
|  |  | plan | Number | 予定有無 | 予定あり：1<br>予定なし：0 | × | × |
|  |  | time | Text | 採取時刻 | HHMM | 〇 | × |
|  |  | picker | Number | 採取者 | 内部利用者ID | 〇 | × |
|  |  | inspector | Number | 検査者 | 内部利用者ID | 〇 | × |
|  |  | value | Text | 結果値 | 指数変換なしで登録する。 | 〇 | × |
|  |  | text | Text | 結果文字列番号 | 水質検査種別マスタの結果文字列番号 | 〇 | × |
|  |  | unit | Text | 単位 | 結果登録時点の単位をハードコピー | 〇 | × |
|  |  | memo | Text | メモ |  | 〇 | × |
|  | },… |  |  |  |  |  |  |
| ] |  |  |  |  |  |  |  |
