# mnt_mainte_main(廃棄)

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `@mnt_mainte_main(廃棄)`
- Category: config/reference

## Content

| col1 | col2 | col3 | col4 | col5 | col6 |
| --- | --- | --- | --- | --- | --- |
| 内容（detail) |  |  |  |  |  |
| [ |  |  |  |  |  |
| { |  |  | 日常点検 | 定期点検 |  |
| tableIndex | number |  | 0:日常点検記録簿 | 1:定期点検記録簿,<br>2: 定期交換部品記録簿 |  |
| : |  |  |  |  |  |
| [ |  |  |  |  |  |
| { |  |  |  |  |  |
| cate_no | number | カテゴリ並び順 | 〇 |  |  |
| cate_cd | number | mst_mainte_category.mainte_category_cd | 〇 |  |  |
| cate_edi | number | mst_mainte_category.edition_no | 〇 |  |  |
| detail_no | number | 項目並び順 | 〇 |  |  |
| detail_cd | number | mst_mainte_detail.mainte_cd | 〇 |  |  |
| detail_edi | number | mst_mainte_detail.edition | 〇 |  |  |
| judge | string | 判定 | 〇 |  |  |
| comment | string | コメント<br>定期点検の時：　<br>1:定期点検予定登録の時点で、mst_mainte_detail.int_textに対する値を登録する；<br>2: 定期点検結果登録の時点で、画面側へ改修したコメントを更新する。 | 〇 | 〇 |  |
| sub_cmt | string | 補足コメント | 〇 | 〇 | 画面はテキストエリア。改行反映。文章全体を表示するように。 |
| user_id | number | ログイン者ID | 〇 |  |  |
| date | string | 更新日時 | 〇 |  |  |
| tableIndex | number | 日常点検の時：　空白<br>定期点検の時：　1:定期点検記録簿, 2: 定期交換部品記録簿 |  |  |  |
| }, |  |  |  |  |  |
| … |  |  |  |  |  |
| ] |  |  |  |  |  |
