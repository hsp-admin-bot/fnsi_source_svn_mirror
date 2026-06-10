# mst_pat_event_sub_category

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `@mst_pat_event_sub_category`
- Category: config/reference

## Content

| 項目一覧 | col2 | mst_pat_calendar_layout.disp_item_info に登録する構造 | col4 | col5 | col6 |
| --- | --- | --- | --- | --- | --- |
|  |  |  | ※itemNo Number |  |  |
|  |  |  | ※itemName String |  |  |
| itemNo | 項目名 |  |  |  |  |
| 1 | 透析レポート |  |  | { |  |
| 2 | 単患者帳票 |  |  |  | itemNo: 8, |
| 3 | 複数患者帳票 |  |  |  | itemName: "ラベル", |
| 4 | 準備リスト |  |  |  | reportCd:"" |
| 5 | 配布リスト(ベッド) |  |  | }, { |  |
| 6 | 配布リスト(物品) |  |  |  | times: 1, |
| 7 | 装置帳票 |  |  |  | itemName: "透析レポート", |
| 8 | ラベル |  |  |  | reportCd:"" |
| 9 | 紹介状 |  |  | }, { |  |
|  |  |  |  |  | itemNo: 2, |
|  |  |  |  |  | itemName: "単患者帳票", |
|  |  |  |  |  | reportCd:"" |
|  |  |  |  | }, { |  |
|  |  |  |  |  | itemNo: 3, |
|  |  |  |  |  | itemName: "複数患者帳票", |
|  |  |  |  |  | reportCd:"" |
|  |  |  |  | }, { |  |
|  |  |  |  |  | itemNo: 4, |
|  |  |  |  |  | itemName: "準備リスト", |
|  |  |  |  |  | reportCd:"" |
|  |  |  |  | }, { |  |
|  |  |  |  |  | itemNo: 5, |
|  |  |  |  |  | itemName: "配布リスト(ベッド)", |
|  |  |  |  |  | reportCd:"" |
|  |  |  |  | }, { |  |
|  |  |  |  |  | itemNo: 6, |
|  |  |  |  |  | itemName: "配布リスト(物品)", |
|  |  |  |  |  | reportCd:"" |
|  |  |  |  | }, { |  |
|  |  |  |  |  | itemNo: 7, |
|  |  |  |  |  | itemName: "装置帳票", |
|  |  |  |  |  | reportCd:"" |
|  |  |  |  | }, { |  |
|  |  |  |  |  | itemNo: 9, |
|  |  |  |  |  | itemName: "紹介状", |
|  |  |  |  |  | reportCd:"" |
|  |  |  |  | } |  |
|  |  |  |  | }, { |  |
|  |  |  |  |  | itemNo: 10, |
|  |  |  |  |  | itemName: "集計帳票", |
|  |  |  |  |  | reportCd:"" |
|  |  |  |  | } |  |
