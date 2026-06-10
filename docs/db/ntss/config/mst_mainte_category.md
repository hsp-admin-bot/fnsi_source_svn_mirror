# mst_mainte_category

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `@mst_mainte_category`
- Category: config/reference

## Content

| col1 | col2 | col3 | col4 | col5 |
| --- | --- | --- | --- | --- |
| 詳細（detail）：日常点検（旧仕様）と定期点検の場合 |  |  |  |  |
| [ |  |  |  |  |
|  | {"cd": 点検詳細品目コード, |  |  |  |
|  | "isDisp": "1" |  |  |  |
|  | "mainteClass": "用途" |  |  |  |
|  | } |  |  |  |
| …. |  |  |  |  |
| ] |  |  |  |  |
| 詳細（detail）：日常点検（新仕様）の場合 |  |  |  |  |
| { |  |  |  |  |
|  | type_info: string[], |  |  | 対象型式リスト（mst_machine_type.machine_type_cd の配列） |
|  |  |  |  | ※nullもしくは空配列の場合はすべての型式を対象とする |
|  | detail_list: [ |  |  | 点検項目リスト（旧仕様のdetailと同じ形式） |
|  |  | { |  |  |
|  |  |  | cd: number, | 点検詳細品目コード（mst_mainte_detail.mainte_detail_cd） |
|  |  |  | isDisp: string, | 選択フラグ（'1'：選択 '0'：非選択） |
|  |  |  | mainteClass: string, | 用途（mst_mainte_detail.mainte_class） |
|  |  | }, |  |  |
|  |  | …, |  |  |
|  | ], |  |  |  |
| } |  |  |  |  |
| ※日常点検（旧仕様）の既存レコードは、その detail の内容が |  |  |  |  |
|  | 新仕様における detail.detail_list に、 |  |  |  |
|  | detail.type_info に空配列（＝すべての型式が対象となる）が入っているものとして扱う。 |  |  |  |
|  | また点検項目グループマスタメンテで日常点検（旧仕様）の既存レコードを更新した際には新仕様の形式にする。 |  |  |  |
