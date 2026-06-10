# mst_report

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `@mst_report`
- Category: config/reference

## Content

| col1 | col2 | col3 | col4 | col5 |
| --- | --- | --- | --- | --- |
| extraction_condition のJSON構造 |  |  |  |  |
|  | [ |  |  |  |
|  | "patId" | ※任意 |  |  |
|  | , "ordNo" | ※任意 |  |  |
|  | ,  … |  |  |  |
|  | ] |  |  |  |
|  | 帳票生成に必要な情報を取得するための抽出条件項目を配列で指定する。 |  |  |  |
|  | ※現時点で想定できる抽出条件項目を設定している。 |  |  |  |
|  | ※今後、抽出条件項目が増えた場合、このJSONに追加する。 |  |  |  |
| additional_info のJSON構造 |  |  |  |  |
|  | { | 型 | 説明 | 備考 |
|  | "col_count" | Number | ラベル列数 | ラベル帳票用 |
|  | "row_count" | Number | ラベル行数 | ラベル帳票用 |
|  | "print_direct" | Number | 繰り返し方向<br>N型:0, Z型:1 | ラベル帳票用 |
|  | } |  |  |  |
| report_setting のJSON構造 |  |  |  |  |
|  | { | 型 | 説明 | 備考 |
|  | "sortList": [ | Object配列 | 「並び替え」の設定内容を保持するJSONオブジェクト配列<br>第1ソート、第2ソート、第3ソートの順番に格納 |  |
|  | { |  |  |  |
|  | "key": | String | ソートキー<br>未指定：null |  |
|  | "sort": | Number | ソート順<br>0 : 昇順, 1 : 降順 | 0, 1のいずれかが設定されるため、未選択は発生しない |
|  | }, |  |  |  |
|  | ,,, |  |  |  |
|  | ], |  |  |  |
|  | "dataCond": { | Object | 「データ抽出条件」の設定内容を保持するJSONオブジェクト |  |
|  | "dateType": | Number | 「透析日/検査日」<br>0 : 透析日、 1 : 検査日 | 0, 1のいずれかが設定されるため、未選択は発生しない |
|  | "periodType": | Number | 「期間指定/1日指定/検査日数指定フラグ」<br>0: 期間指定、1: 1日指定、2: 検査日数指定 | 0, 1, 2のいずれかが設定されるため、未選択は発生しない |
|  | "fromDate": | String | 期間指定開始日 | フォーカスアウト時に操作日が設定されるため、未設定は発生しない |
|  | "toDate": | String | 期間指定終了日 | フォーカスアウト時に操作日が設定されるため、未設定は発生しない |
|  | "specifyDate": | String | 1日指定日 | フォーカスアウト時に操作日が設定されるため、未設定は発生しない |
|  | "inspectionDate": | String | 検査日数指定日 | フォーカスアウト時に操作日が設定されるため、未設定は発生しない |
|  | "beforeAfter": | Number | 検査日数指定前後<br>0: 前、1: 後 | 0, 1のいずれかが設定されるため、未選択は発生しない |
|  | "numDay": | Number | 検査日数指定日数<br>（未指定の場合、null） |  |
|  | "regOrderClass": | Array<String> | 検査区分<br>1: 透析前、2: 透析後、0: その他<br>（未指定の場合、null） |  |
|  | } |  |  |  |
|  | "equipment": { | Object | 「医療材料」の設定内容を保持するJSONオブジェクト |  |
|  | "checkedList": | Array<String> | ・未指定：null<br>・すべて未選択：[]<br>・すべて選択：["all"]<br>・上記以外：コード値の配列 | ※未指定<br>デフォルトのままで、条件の変更が行われていない状態 |
|  | }, |  |  |  |
|  | "medicine": { | Object | 「薬剤」の設定内容を保持するJSONオブジェクト |  |
|  | "checkedList": | Array<String> | ・未指定：null<br>・すべて未選択：[]<br>・すべて選択：["all"]<br>・上記以外：コード値の配列 | ※未指定<br>デフォルトのままで、条件の変更が行われていない状態 |
|  | }, |  |  |  |
|  | "inspect": | Number | 検査<br>0 : 未チェック, 1 : チェック済 |  |
|  | } |  |  |  |
