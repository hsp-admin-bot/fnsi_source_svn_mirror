# mst_mainte_layout

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `@mst_mainte_layout`
- Category: config/reference

## Content

| col1 |
| --- |
| 適用型式情報(type_info) |
| [{ |
| mst_machine_type.machine_type_cd (Number),<br>… |
| }] |
| 定期点検記録簿（detail_info_1) |
| [ |
| { |
| mst_mainte_category.category_cd (Number) |
| "cd":点検カテゴリコード,                        "isDisp": true |
| }, |
| …. |
| ] |
| 定期交換部品記録簿（detail_info_2) |
| [ |
| { |
| mst_mainte_category.category_cd (Number) |
| "cd":点検カテゴリコード,                          "isDisp": true |
| }, |
| …. |
| ] |
