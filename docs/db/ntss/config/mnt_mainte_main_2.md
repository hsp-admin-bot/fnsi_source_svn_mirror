# mnt_mainte_main

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `@mnt_mainte_main`
- Category: config/reference

## Content

| col1 | col2 | col3 | col4 | col5 | col6 | col7 | col8 | col9 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 内容（detail) |  |  |  |  |  |  |  |  |
| [ |  |  | 日常点検記録簿 |  | 定期点検記録簿 |  | 定期交換部品記録簿 |  |
| { |  |  | 使用状況 | 備考 | 使用状況 | 備考 | 使用状況 | 備考 |
| cate_no | string | カテゴリ並び順 | 〇 | カテゴリ並び順⑥ | × |  | × |  |
| cate_cd | number | mst_mainte_category.mainte_category_cd | 〇 | 点検カテゴリコード⑦ | 〇 | 点検カテゴリコード④ | 〇 | 点検カテゴリコード④ |
| cate_edi | number | mst_mainte_category.edition_no | 〇 | 点検カテゴリの版数⑧ | 〇 | 点検カテゴリの版数⑤ | 〇 | 点検カテゴリの版数⑤ |
| detail_no | number | 項目並び順 | 〇 | 項目並び順⑨ | × |  | × |  |
| detail_cd | number | mst_mainte_detail.mainte_detail_cd | 〇 | 点検詳細品目コード⑩ | 〇 | 点検詳細品目コード⑥ | 〇 | 点検詳細品目コード⑥ |
| detail_edi | number | mst_mainte_detail.edition_no | 〇 | 点検詳細の版数⑪ | × |  | × |  |
| judge | string | 判定 | 〇 | 合・途中の点検結果⑤    入力無し⇒’’<br>1.合格、2.不合格、3.点検途中、’’.（空表示） | 〇 | 定期点検記録①    入力無し⇒’’<br>1.レ、2.O、3.✕、4.A、5.T、6.C | 〇 | 確認①    <br>１: 交換済み、’’: 未交換 |
| comment | string | コメント | 〇 | 検査コメント①　　入力無し⇒’’ | 〇 | コメント②　　入力無し⇒’’ | 〇 | コメント②　　入力無し⇒’’ |
| sub_cmt | string | 補足コメント | 〇 | 合・途中のコメント②　　入力無し⇒NULL | × |  | × |  |
| user_id | number | ログイン者ID | 〇 | 点検者④　　入力無し⇒NULL | 〇 | 点検者③　　入力無し⇒NULL | 〇 | 点検者③　　入力無し⇒NULL |
| date | string | 更新日時 | 〇 | 実施日時③　　入力無し⇒’’ | 〇 | 更新日時 | 〇 | 更新日時 |
| edition | number | mst_mainte_detail.edition_no | × |  | 〇 | 点検詳細の版数⑦ | 〇 | 点検詳細の版数⑦ |
| tableIndex | number | 日常点検の時：　空白<br>定期点検の時：　1:定期点検記録簿, 2: 定期交換部品記録簿 | × |  | 〇 | 1 | 〇 | 2 |
| }, |  |  |  |  |  |  |  |  |
| … |  |  |  |  |  |  |  |  |
| ] |  |  |  |  |  |  |  |  |
| 日常点検記録簿 |  |  |  |  | 定期点検記録簿・定期交換部品記録簿 |  |  |  |
