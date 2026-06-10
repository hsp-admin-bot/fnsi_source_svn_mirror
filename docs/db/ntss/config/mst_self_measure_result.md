# mst_self_measure_result

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `@mst_self_measure_result`
- Category: config/reference

## Content

| col1 | col2 | col3 |
| --- | --- | --- |
| 対象機種情報 |  |  |
| [{ |  |  |
| type_cd | String | 型式マスタ.型式コード |
| ver_low | String | 範囲バージョン下限 |
| ver_up | String | 範囲バージョン上限 |
| }..] |  |  |
| 自己診断情報 |  |  |
| [{ |  |  |
| key | String | 自己診断結果アドレス |
| judge | String | 判定('0'：判定しない、'1'：判定する) |
| failure_low | String | 不合格下限 |
| caution_low | String | 注意点下限 |
| caution_up | String | 注意点上限 |
| failure_up | String | 不合格上限 |
| }..] |  |  |
