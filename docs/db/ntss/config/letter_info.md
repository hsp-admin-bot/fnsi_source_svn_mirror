# letter_info

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `@letter_info`
- Category: config/reference

## Content

| col1 | col2 | col3 | col4 | col5 |
| --- | --- | --- | --- | --- |
| 紹介状情報 |  |  |  |  |
| { |  |  |  |  |
|  | report_cd | Number | 帳票Cd |  |
|  | to_facility_cd | String | 転入出先 |  |
|  | letter_category | Number | 区分 |  |
|  | letter_issue_date | String | 発行日 |  |
|  | letter_data |  |  |  |
|  |  | { |  |  |
|  |  |  | id:value | 帳票レイアウトアプリに生成されたIDとユーザ入力済みValue |
|  |  |  | …. |  |
|  |  | } |  |  |
| } |  |  |  |  |
