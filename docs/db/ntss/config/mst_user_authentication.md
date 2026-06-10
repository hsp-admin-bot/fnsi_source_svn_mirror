# mst_user_authentication

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `@mst_user_authentication`
- Category: config/reference

## Content

| col1 | col2 | col3 |
| --- | --- | --- |
| パスワード履歴 |  |  |
| 暗号化したパスワードを配列形式で格納 |  |  |
| 先頭から末尾に向かって新しい世代になる。最大9世代まで。 |  |  |
| [{ |  |  |
| password | String | 暗号化したパスワード履歴（n世代前、n≦9） |
| }, |  |  |
| … | … | … |
| { |  |  |
| password | String | 暗号化したパスワード履歴（2世代前） |
| },{ |  |  |
| password | String | 暗号化したパスワード履歴（1世代前） |
| }] |  |  |
