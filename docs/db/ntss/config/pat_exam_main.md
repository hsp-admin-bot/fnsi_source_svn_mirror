# pat_exam_main

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `@pat_exam_main`
- Category: config/reference

## Content

| col1 | col2 | col3 |
| --- | --- | --- |
| 検査依頼セット情報 |  |  |
| [{ |  |  |
| no | Number | 登録番号 |
| set_cd | Number | 検査セットコード |
| set_name | String | 検査セット名称 |
| }..] |  |  |
| 検査依頼情報 |  |  |
| [{ |  |  |
| no | Number | 検査依頼セット情報の登録番号 |
| item_cd | Number | 検査項目コード（検査依頼セットを分解したもの） |
| item_name | String | 検査項目名称（検査依頼セットを分解したもの） |
| }..] |  |  |
| ラベル情報 |  |  |
| [{ |  |  |
| spitz_cd | Number | 採血管コード |
| }..] |  |  |
| 検査結果情報 |  |  |
| [{ |  |  |
| disp_order | Number | 表示順 |
| item_cd | Number | 検査項目コード |
| result | String | 結果値 |
| hl | String | 結果判定（HとかLとか） |
| com_cd | String | 結果コメントコード |
| freememo | String | 結果フリーコメント |
| result_date | Date | 結果値受信日時 |
| item_name | String | 検査時検査項目名 |
| type | Number | 検査時データ形式 |
| unit | String | 検査時単位 |
| upper | Number | 検査時正常値上限 |
| lower | Number | 検査時正常値下限 |
| exam_class | String | 検査使用区分 |
| jlac10_cd | String | JLAC10コード |
| }..] |  |  |
