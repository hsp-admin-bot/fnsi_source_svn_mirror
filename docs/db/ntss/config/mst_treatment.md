# mst_treatment

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `@mst_treatment`
- Category: config/reference

## Content

| col1 | col2 | col3 | col4 |
| --- | --- | --- | --- |
| ■治療条件設定（treatment_condition_setting） |  |  |  |
|  | キー | 型 | 値 |
|  | category_no | Number | 固定（1～7）<br><br>1：基本条件<br>2：体重<br>3：透析液<br>4：補液<br>5：抗凝固剤<br>6：IP設定<br>7：穿刺針 |
|  | items | Array | 透析条件項目 |
|  | ctl_no | String | 項目番号(※治療条件項目番号) |
|  | is_use | String | '0':未使用、'1'：使用 |
|  | 以下、jsonb文字列（例） |  |  |
