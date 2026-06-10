# mst_pat_calendar_layout

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `@mst_pat_calendar_layout`
- Category: config/reference

## Content

| 項目一覧 | col2 | col3 | col4 | col5 | col6 | col7 | col8 | col9 | col10 | mst_pat_calendar_layout.disp_item_info に登録する構造 | col12 | col13 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
|  |  |  |  |  |  |  |  |  |  |  | ※categoryNo、subCategoryNo、itemNoはすべて Number |  |
| ■表示項目 |  |  |  |  |  |  |  |  |  |  |  |  |
| categoryNo | 大項目名 | subCategoryNo | 中項目名 | dispGroup | dataKey | itemKey | itemNo | 小項目 | 指示 or 実績<br>※空欄は両方 |  |  |  |
| 1 | 患者情報 | 1 | 患者情報 | pat_info | infect_info | - | 1 | 感染症 |  | [ |  | ※Jsonには表示対象のカテゴリ情報群のみ格納する。親表示なしで子のみ表示が区別できるようにisDispプロパティを保持する。 |
|  |  |  |  |  | implant_info |  | 2 | インプラント |  | { |  | 患者カレンダー上の表示順は、Json構造に登録されている配列順となる。 |
|  |  |  |  |  | medical_hst_info |  | 3 | 既往歴 |  | "isDisp": true, |  |  |
|  |  |  |  |  | in_out_visit_history_info |  | 4 | 入外・転入出 |  | "categoryNo": 1, |  | dispGroup: カレンダー項目親子の表示単位 |
|  |  | 2 | 身体情報 | physical_info | physical_info | height | 1 | 身長 |  | "categoryItem": [ |  | dataKey: 患者カレンダー表示データをオブジェクトから取得するためキー名 |
|  |  |  |  |  |  | order_class | 2 | 検査タイミング |  | { |  | itemKey: DBデータのJsonキー、または、カラム名 |
|  |  |  |  |  |  | ctr_weight | 3 | 検査時体重 |  | "isDisp": true, |  |  |
|  |  |  |  |  |  | breast_dia | 4 | 心横径 |  | "dispGroup": "pat_info", |  |  |
|  |  |  |  |  |  | chest_dia | 5 | 胸郭横径 |  | "subCategoryNo": 1, |  |  |
|  |  |  |  |  |  | ctr | 6 | CTR |  | "subCategoryItem": [ |  |  |
|  |  |  |  |  |  | dw | 7 | DW |  | { |  |  |
|  |  |  |  |  |  | target_weight | 8 | 目標体重変更有無 |  | "isDisp": true, |  |  |
|  |  |  |  |  |  | pre_scale_upper | 9 | 前体重許容上限 |  | "itemNo": 1, |  |  |
|  |  |  |  |  |  | pre_scale_lower | 10 | 前体重許容下限 |  | "dataKey": "infect_info", |  |  |
| 2 | 治療情報 | 1 | 治療予定<br><br>※itemNo<br>　-1～38：治療条件項目<br>　100番台：患者カレンダーのみ使用 | treat_plan | treat_info | treatmentName | 100 | 治療方法 |  | "itemName": "感染症" |  |  |
|  |  |  |  |  |  | kurName | 101 | クール |  | }, |  |  |
|  |  |  |  |  |  | startDate | 102 | 治療開始時刻 |  | { |  |  |
|  |  |  |  |  |  | rstEndDate | 103 | 治療終了時刻 | 実績　rstCd: 1 | "isDisp": true, |  |  |
|  |  |  |  |  |  | bedName | 104 | ベッド |  | "itemNo": 2, |  |  |
|  |  |  |  |  |  | - | 1 | 治療時間 |  | "dataKey": "implant_info", |  |  |
|  |  |  |  |  |  |  | 2 | VA |  | "itemName": "インプラント" |  |  |
|  |  |  |  |  |  |  | -1 | DW |  | }, |  |  |
|  |  |  |  |  |  |  | 3 | 目標体重 |  | { |  |  |
|  |  |  |  |  |  |  | 4 | 除水量制限 |  | "isDisp": true, |  |  |
|  |  |  |  |  |  |  | 5 | ダイアライザ |  | "itemNo": 3, |  |  |
|  |  |  |  |  |  |  | 6 | 吸着カラム |  | "dataKey": "medical_hst_info", |  |  |
|  |  |  |  |  |  |  | 7 | 1次膜 |  | "itemName": "既往歴" |  |  |
|  |  |  |  |  |  |  | 8 | 2次膜 |  | }, |  |  |
|  |  |  |  |  |  |  | 105 | 穿刺針 |  | { |  |  |
|  |  |  |  |  |  |  | 12 | シングルニードル使用 |  | "isDisp": true, |  |  |
|  |  |  |  |  |  |  | 13 | 血液回路 |  | "itemNo": 4, |  |  |
|  |  |  |  |  |  |  | 14 | 血流量 |  | "dataKey": "in_out_visit_history_info", |  |  |
|  |  |  |  |  |  |  | 15 | 透析液 |  | "itemName": "入外・転入出" |  |  |
|  |  |  |  |  |  |  | 16 | 透析液流量 |  | } |  |  |
|  |  |  |  |  |  |  | 17 | 透析液使用数 |  | ], |  |  |
|  |  |  |  |  |  |  | 18 | 透析液温度 |  | "subCategoryName": "患者情報" |  |  |
|  |  |  |  |  |  |  | 19 | 補液 |  | }, |  |  |
|  |  |  |  |  |  |  | 20 | 補液量 |  | { |  |  |
|  |  |  |  |  |  |  | 21 | 補液選択 |  | "isDisp": true, |  |  |
|  |  |  |  |  |  |  | 22 | 補液使用数 |  | "dataKey": "physical_info", |  |  |
|  |  |  |  |  |  |  | 23 | 補液温度 |  | "dispGroup": "physical_info", |  |  |
|  |  |  |  |  |  |  | 24 | 補液速度 |  | "subCategoryNo": 2, |  |  |
|  |  |  |  |  |  |  | 25 | 抗凝固剤 |  | "subCategoryItem": [ |  |  |
|  |  |  |  |  |  |  | 26 | 抗凝固剤ワンショット量 |  | { |  |  |
|  |  |  |  |  |  |  | 27 | 抗凝固剤持続速度 |  | "isDisp": true, |  |  |
|  |  |  |  |  |  |  | 28 | 抗凝固剤持続総量 |  | "itemNo": 1, |  |  |
|  |  |  |  |  |  |  | 106 | 抗凝固剤総量 |  | "itemKey": "height", |  |  |
|  |  |  |  |  |  |  | 29 | IP使用選択 |  | "itemName": "身長" |  |  |
|  |  |  |  |  |  |  | 30 | IPスタート |  | }, |  |  |
|  |  |  |  |  |  |  | 32 | IP速度 |  | { |  |  |
|  |  |  |  |  |  |  | 33 | IP速度最大値 |  | "isDisp": true, |  |  |
|  |  |  |  |  |  |  | 34 | IPワンショットスタート |  | "itemNo": 2, |  |  |
|  |  |  |  |  |  |  | 31 | IPワンショット量 |  | "itemKey": "order_class", |  |  |
|  |  |  |  |  |  |  | 35 | IP電源自動切り |  | "itemName": "検査タイミング" |  |  |
|  |  |  |  |  |  |  | 36 | IP電源自動切り時間 |  | }, |  |  |
|  |  |  |  |  |  |  | 37 | IP電源OKモニタ切り |  | { |  |  |
|  |  |  |  |  |  |  | 38 | IP電源OKモニタ切り時間 |  | "isDisp": true, |  |  |
|  |  | 2 | 投与薬剤 |  |  | - | - | - |  | "itemNo": 3, |  |  |
|  |  | 3 | 医療材料 |  |  | - | - | - |  | "itemKey": "ctr_weight", |  |  |
|  |  | 4 | 指示コメント |  |  | - | - | - |  | "itemName": "検査時体重" |  |  |
|  |  | 5 | 実績情報　※カレンダーは親表示なし |  |  | rstInOutClass | 1 | 入外区分 | 実績　rstCd: 2 | }, |  |  |
|  |  |  |  |  |  | rstDialysisCnt | 2 | 透析回数 | 実績　rstCd: 3 | { |  |  |
|  |  |  |  |  |  | rstDialysisTime | 3 | 治療時間(実績) | 実績　rstCd: 4 | "isDisp": true, |  |  |
|  |  |  |  |  |  | rstWardName | 4 | 病棟 | 実績　rstCd: 5 | "itemNo": 4, |  |  |
|  |  |  |  |  |  | rstCourseName | 5 | 診療科 | 実績　rstCd: 6 | "itemKey": "breast_dia", |  |  |
|  |  |  |  |  |  | rstPunctureUserInfo:1 | 6 | 穿刺者1 | 実績　rstCd: 7 | "itemName": "心横径" |  |  |
|  |  |  |  |  |  | rstPunctureUserInfo:2 | 7 | 穿刺者2 | 実績　rstCd: 8 | }, |  |  |
|  |  |  |  |  |  | rstReturnUserInfo:1 | 8 | 返血者1 | 実績　rstCd: 9 | { |  |  |
|  |  |  |  |  |  | rstReturnUserInfo:2 | 9 | 返血者2 | 実績　rstCd: 10 | "isDisp": true, |  |  |
|  |  |  |  |  |  | rstChargeUserInfo:1 | 10 | 担当者1 | 実績　rstCd: 11 | "itemNo": 5, |  |  |
|  |  |  |  |  |  | rstChargeUserInfo:2 | 11 | 担当者2 | 実績　rstCd: 12 | "itemKey": "chest_dia", |  |  |
|  |  |  |  |  |  | rstWeightInfo:weight_before | 12 | 前体重 | 実績　rstCd: 13 | "itemName": "胸郭横径" |  |  |
|  |  |  |  |  |  | rstWeightInfo:weight_after | 13 | 後体重 | 実績　rstCd: 14 | }, |  |  |
|  |  |  |  |  |  | rstWeightInfo:ctr | 14 | CTR | 実績　rstCd: 15 | { |  |  |
|  |  |  |  |  |  | rstWeightInfo:ctr_measure_date | 15 | CTR測定日 | 実績　rstCd: 16 | "isDisp": true, |  |  |
|  |  |  |  |  |  | rstWeightInfo:water_removal_target | 16 | 目標除水量 | 実績　rstCd: 17 | "itemNo": 6, |  |  |
|  |  |  |  |  |  | rstWeightInfo:water_removal_rst | 17 | 実績除水量 | 実績　rstCd: 18 | "itemKey": "ctr", |  |  |
|  |  |  |  |  |  | rstWeightInfo:add_water_total | 18 | 実績補液量 | 実績　rstCd: 19 | "itemName": "CTR" |  |  |
|  |  |  |  |  |  | rstWeightInfo:ihdf_pll | 19 | I-HDF引き残し | 実績　rstCd: 20 | }, |  |  |
|  |  |  |  |  |  | rstWeightInfo:kt_v_measure | 20 | Kt/V測定値 | 実績　rstCd: 21 | { |  |  |
|  |  |  |  |  |  | rstWeightInfo:urr | 21 | URR | 実績　rstCd: 22 | "isDisp": true, |  |  |
|  |  |  |  |  | 有効値（チェックボックスON）を表示 | rstWeightInfo:recrcl_rt:rate | 22 | 再循環率 | 実績　rstCd: 23 | "itemNo": 7, |  |  |
|  |  |  |  |  | 有効値（チェックボックスON）を表示 | rstWeightInfo:recrcl_rt:bld_vl | 23 | 再循環率測定時血流量 | 実績　rstCd: 24 | "itemKey": "dw", |  |  |
|  |  |  |  |  | 有効値（チェックボックスON）を表示 | rstWeightInfo:recrcl_rt:datetime | 24 | 再循環率測定日時 | 実績　rstCd: 25 | "itemName": "DW" |  |  |
|  |  |  |  |  |  | rstWeightInfo:sttc_vns_prssr | 25 | 静的静脈圧 | 実績　rstCd: 26 | }, |  |  |
|  |  |  |  |  |  | rstWeightInfo:iap_rt | 26 | IAP Ratio | 実績　rstCd: 27 | { |  |  |
|  |  |  |  |  | mni_monitor<br>data_typeが5 | - | 27 | 透析前血圧 | 実績　rstCd: 28 | "isDisp": true, |  |  |
|  |  |  |  |  | mni_monitor<br>data_typeが6 | - | 28 | 透析後血圧 | 実績　rstCd: 29 | "itemNo": 8, |  |  |
|  |  |  |  |  | mni_monitor<br>data_typeが2, 4, 5, 6のitemNoが94の最新 | - | 29 | 体温 | 実績　rstCd: 30 | "itemKey": "target_weight", |  |  |
|  |  | 11 | バイタル・モニタグラフ①-1　入室～退室 |  | vital_monitor_flg_1 | - | ※1 | ユーザが表示したい項目を選択（最大5項目まで） | 実績 | "itemName": "目標体重変更有無" |  |  |
|  |  |  |  |  |  |  |  | ※1 モニターデータのJSONキーを設定 |  | }, |  |  |
|  |  |  |  |  |  |  |  | 「@mni_monitor」シートを参照 |  | { |  |  |
|  |  |  |  |  |  |  |  |  |  | "isDisp": true, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemNo": 9, |  |  |
|  |  | 12 | バイタル・モニタグラフ①-2　入室～退室 |  | vital_monitor_flg_1 | - | ※1 | ユーザが表示したい項目を選択（最大5項目まで） | 実績 | "itemKey": "pre_scale_upper", |  |  |
|  |  |  |  |  |  |  |  | ※1 モニターデータのJSONキーを設定 |  | "itemName": "前体重許容上限" |  |  |
|  |  |  |  |  |  |  |  | 「@mni_monitor」シートを参照 |  | }, |  |  |
|  |  |  |  |  |  |  |  |  |  | { |  |  |
|  |  |  |  |  |  |  |  |  |  | "isDisp": true, |  |  |
|  |  | 13 | バイタル・モニタグラフ①-3　入室～退室 |  | vital_monitor_flg_1 | - | ※1 | ユーザが表示したい項目を選択（最大5項目まで） | 実績 | "itemNo": 10, |  |  |
|  |  |  |  |  |  |  |  | ※1 モニターデータのJSONキーを設定 |  | "itemKey": "pre_scale_lower", |  |  |
|  |  |  |  |  |  |  |  | 「@mni_monitor」シートを参照 |  | "itemName": "前体重許容下限" |  |  |
|  |  |  |  |  |  |  |  |  |  | } |  |  |
|  |  |  |  |  |  |  |  |  |  | ], |  |  |
|  |  | 21 | バイタル・モニタグラフ②-1　入室～退室 |  | vital_monitor_flg_2 | - | ※1 | ユーザが表示したい項目を選択（最大5項目まで） | 実績 | "subCategoryName": "身体情報" |  |  |
|  |  |  |  |  |  |  |  | ※1 モニターデータのJSONキーを設定 |  | } |  |  |
|  |  |  |  |  |  |  |  | 「@mni_monitor」シートを参照 |  | ], |  |  |
|  |  |  |  |  |  |  |  |  |  | "categoryName": "患者情報" |  |  |
|  |  |  |  |  |  |  |  |  |  | }, |  |  |
|  |  | 22 | バイタル・モニタグラフ②-2　入室～退室 |  | vital_monitor_flg_2 | - | ※1 | ユーザが表示したい項目を選択（最大5項目まで） | 実績 | { |  |  |
|  |  |  |  |  |  |  |  | ※1 モニターデータのJSONキーを設定 |  | "isDisp": true, |  |  |
|  |  |  |  |  |  |  |  | 「@mni_monitor」シートを参照 |  | "dataKey": "treat_info", |  |  |
|  |  |  |  |  |  |  |  |  |  | "dispGroup": "treat_plan", |  |  |
|  |  |  |  |  |  |  |  |  |  | "categoryNo": 2, |  |  |
|  |  | 23 | バイタル・モニタグラフ②-3　入室～退室 |  | vital_monitor_flg_2 | - | ※1 | ユーザが表示したい項目を選択（最大5項目まで） | 実績 | "categoryItem": [ |  |  |
|  |  |  |  |  |  |  |  | ※1 モニターデータのJSONキーを設定 |  | { |  |  |
|  |  |  |  |  |  |  |  | 「@mni_monitor」シートを参照 |  | "isDisp": true, |  |  |
|  |  |  |  |  |  |  |  |  |  | "subCategoryNo": 1, |  |  |
|  |  |  |  |  |  |  |  |  |  | "subCategoryItem": [ |  |  |
|  |  | 31 | バイタル・モニタグラフ③-1　入室～退室 |  | vital_monitor_flg_3 | - | ※1 | ユーザが表示したい項目を選択（最大5項目まで） | 実績 | { |  |  |
|  |  |  |  |  |  |  |  | ※1 モニターデータのJSONキーを設定 |  | "isDisp": true, |  |  |
|  |  |  |  |  |  |  |  | 「@mni_monitor」シートを参照 |  | "itemNo": 100, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemKey": "treatmentName", |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemName": "治療方法" |  |  |
|  |  | 32 | バイタル・モニタグラフ③-2　入室～退室 |  | vital_monitor_flg_3 | - | ※1 | ユーザが表示したい項目を選択（最大5項目まで） | 実績 | }, |  |  |
|  |  |  |  |  |  |  |  | ※1 モニターデータのJSONキーを設定 |  | { |  |  |
|  |  |  |  |  |  |  |  | 「@mni_monitor」シートを参照 |  | "isDisp": true, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemNo": 101, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemKey": "kurName", |  |  |
|  |  | 33 | バイタル・モニタグラフ③-3　入室～退室 |  | vital_monitor_flg_3 | - | ※1 | ユーザが表示したい項目を選択（最大5項目まで） | 実績 | "itemName": "クール" |  |  |
|  |  |  |  |  |  |  |  | ※1 モニターデータのJSONキーを設定 |  | }, |  |  |
|  |  |  |  |  |  |  |  | 「@mni_monitor」シートを参照 |  | { |  |  |
|  |  |  |  |  |  |  |  |  |  | "isDisp": true, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemNo": 102, |  |  |
|  |  | 41 | バイタル・モニタグラフ④-1　入室～退室 |  | vital_monitor_flg_4 | - | ※1 | ユーザが表示したい項目を選択（最大5項目まで） | 実績 | "itemKey": "startDate", |  |  |
|  |  |  |  |  |  |  |  | ※1 モニターデータのJSONキーを設定 |  | "itemName": "治療開始時刻" |  |  |
|  |  |  |  |  |  |  |  | 「@mni_monitor」シートを参照 |  | }, |  |  |
|  |  |  |  |  |  |  |  |  |  | { |  |  |
|  |  |  |  |  |  |  |  |  |  | "rstCd": 1, |  |  |
|  |  | 42 | バイタル・モニタグラフ④-2　入室～退室 |  | vital_monitor_flg_4 | - | ※1 | ユーザが表示したい項目を選択（最大5項目まで） | 実績 | "isDisp": true, |  |  |
|  |  |  |  |  |  |  |  | ※1 モニターデータのJSONキーを設定 |  | "itemNo": 103, |  |  |
|  |  |  |  |  |  |  |  | 「@mni_monitor」シートを参照 |  | "itemKey": "rstEndDate", |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemName": "治療終了時刻" |  |  |
|  |  |  |  |  |  |  |  |  |  | }, |  |  |
|  |  | 43 | バイタル・モニタグラフ④-3　入室～退室 |  | vital_monitor_flg_4 | - | ※1 | ユーザが表示したい項目を選択（最大5項目まで） | 実績 | { |  |  |
|  |  |  |  |  |  |  |  | ※1 モニターデータのJSONキーを設定 |  | "isDisp": true, |  |  |
|  |  |  |  |  |  |  |  | 「@mni_monitor」シートを参照 |  | "itemNo": 104, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemKey": "bedName", |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemName": "ベッド" |  |  |
| 3 | 検査 | 1 | 検査結果 | exam_result | exam_result | - | - | - |  | }, |  |  |
|  |  | 2 | 検査予定 | exam_request | exam_request | - | 1 | 検査セット名 |  | { |  |  |
| 4 | 一般撮影検査 | 1 | 一般撮影検査予定 | rad_request | rad_request | - | - | - |  | "isDisp": true, |  |  |
| 5 | 患者イベント | 1 | 患者イベント | pat_event | pat_event | - | ※2 | ※2<br>ユーザが表示したい項目を選択（無制限）<br>サブカテゴリのみ選択可能<br>患者イベントカテゴリマスタ + 患者イベントサブカテゴリマスタ<br>患者イベントカテゴリマスタのisPatEventSub=0<br>患者イベントサブカテゴリマスタのisPatEventSub=1 |  | "itemNo": 1, |  |  |
| 6 | 処方 | 1 | 処方 | prescription | prescription | - | - | - |  | "itemName": "治療時間" |  |  |
| 7 | 施設イベント | 1 | 施設イベント | bbs_info | bbs_info | - | ※3 | ※3<br>ユーザが表示したい項目を選択（無制限）<br>施設イベントカテゴリマスタ |  | }, |  |  |
|  |  |  |  |  |  |  |  |  |  | { |  |  |
|  |  |  |  |  |  |  |  |  |  | "isDisp": true, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemNo": 2, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemName": "VA" |  |  |
|  |  |  |  |  |  |  |  |  |  | }, |  |  |
|  |  |  |  |  |  |  |  |  |  | { |  |  |
|  |  |  |  |  |  |  |  |  |  | "isDisp": true, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemNo": -1, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemName": "DW" |  |  |
|  |  |  |  |  |  |  |  |  |  | }, |  |  |
|  |  |  |  |  |  |  |  |  |  | { |  |  |
|  |  |  |  |  |  |  |  |  |  | "isDisp": true, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemNo": 3, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemName": "目標体重" |  |  |
|  |  |  |  |  |  |  |  |  |  | }, |  |  |
|  |  |  |  |  |  |  |  |  |  | { |  |  |
|  |  |  |  |  |  |  |  |  |  | "isDisp": true, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemNo": 4, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemName": "除水量制限" |  |  |
|  |  |  |  |  |  |  |  |  |  | }, |  |  |
|  |  |  |  |  |  |  |  |  |  | { |  |  |
|  |  |  |  |  |  |  |  |  |  | "isDisp": true, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemNo": 5, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemName": "ダイアライザ" |  |  |
|  |  |  |  |  |  |  |  |  |  | }, |  |  |
|  |  |  |  |  |  |  |  |  |  | { |  |  |
|  |  |  |  |  |  |  |  |  |  | "isDisp": true, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemNo": 6, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemName": "吸着カラム" |  |  |
|  |  |  |  |  |  |  |  |  |  | }, |  |  |
|  |  |  |  |  |  |  |  |  |  | { |  |  |
|  |  |  |  |  |  |  |  |  |  | "isDisp": true, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemNo": 7, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemName": "1次膜" |  |  |
|  |  |  |  |  |  |  |  |  |  | }, |  |  |
|  |  |  |  |  |  |  |  |  |  | { |  |  |
|  |  |  |  |  |  |  |  |  |  | "isDisp": true, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemNo": 8, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemName": "2次膜" |  |  |
|  |  |  |  |  |  |  |  |  |  | }, |  |  |
|  |  |  |  |  |  |  |  |  |  | { |  |  |
|  |  |  |  |  |  |  |  |  |  | "isDisp": true, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemNo": 105, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemName": "穿刺針" |  |  |
|  |  |  |  |  |  |  |  |  |  | }, |  |  |
|  |  |  |  |  |  |  |  |  |  | { |  |  |
|  |  |  |  |  |  |  |  |  |  | "isDisp": true, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemNo": 12, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemName": "シングルニードル使用" |  |  |
|  |  |  |  |  |  |  |  |  |  | }, |  |  |
|  |  |  |  |  |  |  |  |  |  | { |  |  |
|  |  |  |  |  |  |  |  |  |  | "isDisp": true, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemNo": 13, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemName": "血液回路" |  |  |
|  |  |  |  |  |  |  |  |  |  | }, |  |  |
|  |  |  |  |  |  |  |  |  |  | { |  |  |
|  |  |  |  |  |  |  |  |  |  | "isDisp": true, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemNo": 14, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemName": "血流量" |  |  |
|  |  |  |  |  |  |  |  |  |  | }, |  |  |
|  |  |  |  |  |  |  |  |  |  | { |  |  |
|  |  |  |  |  |  |  |  |  |  | "isDisp": true, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemNo": 15, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemName": "透析液" |  |  |
|  |  |  |  |  |  |  |  |  |  | }, |  |  |
|  |  |  |  |  |  |  |  |  |  | { |  |  |
|  |  |  |  |  |  |  |  |  |  | "isDisp": true, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemNo": 16, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemName": "透析液流量" |  |  |
|  |  |  |  |  |  |  |  |  |  | }, |  |  |
|  |  |  |  |  |  |  |  |  |  | { |  |  |
|  |  |  |  |  |  |  |  |  |  | "isDisp": true, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemNo": 17, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemName": "透析液使用数" |  |  |
|  |  |  |  |  |  |  |  |  |  | }, |  |  |
|  |  |  |  |  |  |  |  |  |  | { |  |  |
|  |  |  |  |  |  |  |  |  |  | "isDisp": true, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemNo": 18, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemName": "透析液温度" |  |  |
|  |  |  |  |  |  |  |  |  |  | }, |  |  |
|  |  |  |  |  |  |  |  |  |  | { |  |  |
|  |  |  |  |  |  |  |  |  |  | "isDisp": true, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemNo": 19, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemName": "補液" |  |  |
|  |  |  |  |  |  |  |  |  |  | }, |  |  |
|  |  |  |  |  |  |  |  |  |  | { |  |  |
|  |  |  |  |  |  |  |  |  |  | "isDisp": true, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemNo": 20, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemName": "補液量" |  |  |
|  |  |  |  |  |  |  |  |  |  | }, |  |  |
|  |  |  |  |  |  |  |  |  |  | { |  |  |
|  |  |  |  |  |  |  |  |  |  | "isDisp": true, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemNo": 21, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemName": "補液選択" |  |  |
|  |  |  |  |  |  |  |  |  |  | }, |  |  |
|  |  |  |  |  |  |  |  |  |  | { |  |  |
|  |  |  |  |  |  |  |  |  |  | "isDisp": true, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemNo": 22, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemName": "補液使用数" |  |  |
|  |  |  |  |  |  |  |  |  |  | }, |  |  |
|  |  |  |  |  |  |  |  |  |  | { |  |  |
|  |  |  |  |  |  |  |  |  |  | "isDisp": true, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemNo": 23, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemName": "補液温度" |  |  |
|  |  |  |  |  |  |  |  |  |  | }, |  |  |
|  |  |  |  |  |  |  |  |  |  | { |  |  |
|  |  |  |  |  |  |  |  |  |  | "isDisp": true, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemNo": 24, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemName": "補液速度" |  |  |
|  |  |  |  |  |  |  |  |  |  | }, |  |  |
|  |  |  |  |  |  |  |  |  |  | { |  |  |
|  |  |  |  |  |  |  |  |  |  | "isDisp": true, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemNo": 25, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemName": "抗凝固剤" |  |  |
|  |  |  |  |  |  |  |  |  |  | }, |  |  |
|  |  |  |  |  |  |  |  |  |  | { |  |  |
|  |  |  |  |  |  |  |  |  |  | "isDisp": true, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemNo": 26, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemName": "抗凝固剤ワンショット量" |  |  |
|  |  |  |  |  |  |  |  |  |  | }, |  |  |
|  |  |  |  |  |  |  |  |  |  | { |  |  |
|  |  |  |  |  |  |  |  |  |  | "isDisp": true, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemNo": 27, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemName": "抗凝固剤持続速度" |  |  |
|  |  |  |  |  |  |  |  |  |  | }, |  |  |
|  |  |  |  |  |  |  |  |  |  | { |  |  |
|  |  |  |  |  |  |  |  |  |  | "isDisp": true, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemNo": 28, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemName": "抗凝固剤持続総量" |  |  |
|  |  |  |  |  |  |  |  |  |  | }, |  |  |
|  |  |  |  |  |  |  |  |  |  | { |  |  |
|  |  |  |  |  |  |  |  |  |  | "isDisp": true, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemNo": 106, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemName": "抗凝固剤総量" |  |  |
|  |  |  |  |  |  |  |  |  |  | }, |  |  |
|  |  |  |  |  |  |  |  |  |  | { |  |  |
|  |  |  |  |  |  |  |  |  |  | "isDisp": true, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemNo": 29, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemName": "IP使用選択" |  |  |
|  |  |  |  |  |  |  |  |  |  | }, |  |  |
|  |  |  |  |  |  |  |  |  |  | { |  |  |
|  |  |  |  |  |  |  |  |  |  | "isDisp": true, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemNo": 30, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemName": "IPスタート" |  |  |
|  |  |  |  |  |  |  |  |  |  | }, |  |  |
|  |  |  |  |  |  |  |  |  |  | { |  |  |
|  |  |  |  |  |  |  |  |  |  | "isDisp": true, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemNo": 32, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemName": "IP速度" |  |  |
|  |  |  |  |  |  |  |  |  |  | }, |  |  |
|  |  |  |  |  |  |  |  |  |  | { |  |  |
|  |  |  |  |  |  |  |  |  |  | "isDisp": true, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemNo": 33, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemName": "IP速度最大値" |  |  |
|  |  |  |  |  |  |  |  |  |  | }, |  |  |
|  |  |  |  |  |  |  |  |  |  | { |  |  |
|  |  |  |  |  |  |  |  |  |  | "isDisp": true, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemNo": 34, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemName": "IPワンショットスタート" |  |  |
|  |  |  |  |  |  |  |  |  |  | }, |  |  |
|  |  |  |  |  |  |  |  |  |  | { |  |  |
|  |  |  |  |  |  |  |  |  |  | "isDisp": true, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemNo": 31, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemName": "IPワンショット量" |  |  |
|  |  |  |  |  |  |  |  |  |  | }, |  |  |
|  |  |  |  |  |  |  |  |  |  | { |  |  |
|  |  |  |  |  |  |  |  |  |  | "isDisp": true, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemNo": 35, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemName": "IP電源自動切り" |  |  |
|  |  |  |  |  |  |  |  |  |  | }, |  |  |
|  |  |  |  |  |  |  |  |  |  | { |  |  |
|  |  |  |  |  |  |  |  |  |  | "isDisp": true, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemNo": 36, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemName": "IP電源自動切り時間" |  |  |
|  |  |  |  |  |  |  |  |  |  | }, |  |  |
|  |  |  |  |  |  |  |  |  |  | { |  |  |
|  |  |  |  |  |  |  |  |  |  | "isDisp": true, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemNo": 37, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemName": "IP電源OKモニタ切り" |  |  |
|  |  |  |  |  |  |  |  |  |  | }, |  |  |
|  |  |  |  |  |  |  |  |  |  | { |  |  |
|  |  |  |  |  |  |  |  |  |  | "isDisp": true, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemNo": 38, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemName": "IP電源OKモニタ切り時間" |  |  |
|  |  |  |  |  |  |  |  |  |  | } |  |  |
|  |  |  |  |  |  |  |  |  |  | ], |  |  |
|  |  |  |  |  |  |  |  |  |  | "subCategoryName": "治療予定" |  |  |
|  |  |  |  |  |  |  |  |  |  | }, |  |  |
|  |  |  |  |  |  |  |  |  |  | { |  |  |
|  |  |  |  |  |  |  |  |  |  | "isDisp": true, |  |  |
|  |  |  |  |  |  |  |  |  |  | "subCategoryNo": 2, |  |  |
|  |  |  |  |  |  |  |  |  |  | "subCategoryItem": [], |  |  |
|  |  |  |  |  |  |  |  |  |  | "subCategoryName": "投与薬剤" |  |  |
|  |  |  |  |  |  |  |  |  |  | }, |  |  |
|  |  |  |  |  |  |  |  |  |  | { |  |  |
|  |  |  |  |  |  |  |  |  |  | "isDisp": true, |  |  |
|  |  |  |  |  |  |  |  |  |  | "subCategoryNo": 3, |  |  |
|  |  |  |  |  |  |  |  |  |  | "subCategoryItem": [], |  |  |
|  |  |  |  |  |  |  |  |  |  | "subCategoryName": "医療材料" |  |  |
|  |  |  |  |  |  |  |  |  |  | }, |  |  |
|  |  |  |  |  |  |  |  |  |  | { |  |  |
|  |  |  |  |  |  |  |  |  |  | "isDisp": true, |  |  |
|  |  |  |  |  |  |  |  |  |  | "subCategoryNo": 4, |  |  |
|  |  |  |  |  |  |  |  |  |  | "subCategoryItem": [], |  |  |
|  |  |  |  |  |  |  |  |  |  | "subCategoryName": "指示コメント" |  |  |
|  |  |  |  |  |  |  |  |  |  | }, |  |  |
|  |  |  |  |  |  |  |  |  |  | { |  |  |
|  |  |  |  |  |  |  |  |  |  | "isDisp": true, |  |  |
|  |  |  |  |  |  |  |  |  |  | "subCategoryNo": 5, |  |  |
|  |  |  |  |  |  |  |  |  |  | "subCategoryItem": [ |  |  |
|  |  |  |  |  |  |  |  |  |  | { |  |  |
|  |  |  |  |  |  |  |  |  |  | "rstCd": 3, |  |  |
|  |  |  |  |  |  |  |  |  |  | "isDisp": true, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemNo": 2, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemKey": "rstDialysisCnt", |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemName": "透析回数" |  |  |
|  |  |  |  |  |  |  |  |  |  | }, |  |  |
|  |  |  |  |  |  |  |  |  |  | { |  |  |
|  |  |  |  |  |  |  |  |  |  | "rstCd": 2, |  |  |
|  |  |  |  |  |  |  |  |  |  | "isDisp": true, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemNo": 1, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemKey": "rstInOutClass", |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemName": "入外区分" |  |  |
|  |  |  |  |  |  |  |  |  |  | }, |  |  |
|  |  |  |  |  |  |  |  |  |  | { |  |  |
|  |  |  |  |  |  |  |  |  |  | "rstCd": 4, |  |  |
|  |  |  |  |  |  |  |  |  |  | "isDisp": true, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemNo": 3, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemKey": "rstDialysisTime", |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemName": "治療時間(実績)" |  |  |
|  |  |  |  |  |  |  |  |  |  | }, |  |  |
|  |  |  |  |  |  |  |  |  |  | { |  |  |
|  |  |  |  |  |  |  |  |  |  | "rstCd": 5, |  |  |
|  |  |  |  |  |  |  |  |  |  | "isDisp": true, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemNo": 4, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemKey": "rstWardName", |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemName": "病棟" |  |  |
|  |  |  |  |  |  |  |  |  |  | }, |  |  |
|  |  |  |  |  |  |  |  |  |  | { |  |  |
|  |  |  |  |  |  |  |  |  |  | "rstCd": 6, |  |  |
|  |  |  |  |  |  |  |  |  |  | "isDisp": true, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemNo": 5, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemKey": "rstCourseName", |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemName": "診療科" |  |  |
|  |  |  |  |  |  |  |  |  |  | }, |  |  |
|  |  |  |  |  |  |  |  |  |  | { |  |  |
|  |  |  |  |  |  |  |  |  |  | "rstCd": 7, |  |  |
|  |  |  |  |  |  |  |  |  |  | "isDisp": true, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemNo": 6, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemKey": "rstPunctureUserInfo:1", |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemName": "穿刺者1" |  |  |
|  |  |  |  |  |  |  |  |  |  | }, |  |  |
|  |  |  |  |  |  |  |  |  |  | { |  |  |
|  |  |  |  |  |  |  |  |  |  | "rstCd": 8, |  |  |
|  |  |  |  |  |  |  |  |  |  | "isDisp": true, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemNo": 7, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemKey": "rstPunctureUserInfo:2", |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemName": "穿刺者2" |  |  |
|  |  |  |  |  |  |  |  |  |  | }, |  |  |
|  |  |  |  |  |  |  |  |  |  | { |  |  |
|  |  |  |  |  |  |  |  |  |  | "rstCd": 9, |  |  |
|  |  |  |  |  |  |  |  |  |  | "isDisp": true, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemNo": 8, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemKey": "rstReturnUserInfo:1", |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemName": "返血者1" |  |  |
|  |  |  |  |  |  |  |  |  |  | }, |  |  |
|  |  |  |  |  |  |  |  |  |  | { |  |  |
|  |  |  |  |  |  |  |  |  |  | "rstCd": 10, |  |  |
|  |  |  |  |  |  |  |  |  |  | "isDisp": true, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemNo": 9, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemKey": "rstReturnUserInfo:2", |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemName": "返血者2" |  |  |
|  |  |  |  |  |  |  |  |  |  | }, |  |  |
|  |  |  |  |  |  |  |  |  |  | { |  |  |
|  |  |  |  |  |  |  |  |  |  | "rstCd": 11, |  |  |
|  |  |  |  |  |  |  |  |  |  | "isDisp": true, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemNo": 10, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemKey": "rstChargeUserInfo:1", |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemName": "担当者1" |  |  |
|  |  |  |  |  |  |  |  |  |  | }, |  |  |
|  |  |  |  |  |  |  |  |  |  | { |  |  |
|  |  |  |  |  |  |  |  |  |  | "rstCd": 12, |  |  |
|  |  |  |  |  |  |  |  |  |  | "isDisp": true, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemNo": 11, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemKey": "rstChargeUserInfo:2", |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemName": "担当者2" |  |  |
|  |  |  |  |  |  |  |  |  |  | }, |  |  |
|  |  |  |  |  |  |  |  |  |  | { |  |  |
|  |  |  |  |  |  |  |  |  |  | "rstCd": 13, |  |  |
|  |  |  |  |  |  |  |  |  |  | "isDisp": true, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemNo": 12, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemKey": "rstWeightInfo:weight_before", |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemName": "前体重" |  |  |
|  |  |  |  |  |  |  |  |  |  | }, |  |  |
|  |  |  |  |  |  |  |  |  |  | { |  |  |
|  |  |  |  |  |  |  |  |  |  | "rstCd": 14, |  |  |
|  |  |  |  |  |  |  |  |  |  | "isDisp": true, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemNo": 13, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemKey": "rstWeightInfo:weight_after", |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemName": "後体重" |  |  |
|  |  |  |  |  |  |  |  |  |  | }, |  |  |
|  |  |  |  |  |  |  |  |  |  | { |  |  |
|  |  |  |  |  |  |  |  |  |  | "rstCd": 15, |  |  |
|  |  |  |  |  |  |  |  |  |  | "isDisp": true, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemNo": 14, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemKey": "rstWeightInfo:ctr", |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemName": "CTR" |  |  |
|  |  |  |  |  |  |  |  |  |  | }, |  |  |
|  |  |  |  |  |  |  |  |  |  | { |  |  |
|  |  |  |  |  |  |  |  |  |  | "rstCd": 16, |  |  |
|  |  |  |  |  |  |  |  |  |  | "isDisp": true, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemNo": 15, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemKey": "rstWeightInfo:ctr_measure_date", |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemName": "CTR測定日" |  |  |
|  |  |  |  |  |  |  |  |  |  | }, |  |  |
|  |  |  |  |  |  |  |  |  |  | { |  |  |
|  |  |  |  |  |  |  |  |  |  | "rstCd": 17, |  |  |
|  |  |  |  |  |  |  |  |  |  | "isDisp": true, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemNo": 16, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemKey": "rstWeightInfo:water_removal_target", |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemName": "目標除水量" |  |  |
|  |  |  |  |  |  |  |  |  |  | }, |  |  |
|  |  |  |  |  |  |  |  |  |  | { |  |  |
|  |  |  |  |  |  |  |  |  |  | "rstCd": 18, |  |  |
|  |  |  |  |  |  |  |  |  |  | "isDisp": true, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemNo": 17, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemKey": "rstWeightInfo:water_removal_rst", |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemName": "実績除水量" |  |  |
|  |  |  |  |  |  |  |  |  |  | }, |  |  |
|  |  |  |  |  |  |  |  |  |  | { |  |  |
|  |  |  |  |  |  |  |  |  |  | "rstCd": 19, |  |  |
|  |  |  |  |  |  |  |  |  |  | "isDisp": true, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemNo": 18, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemKey": "rstWeightInfo:add_water_total", |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemName": "実績補液量" |  |  |
|  |  |  |  |  |  |  |  |  |  | }, |  |  |
|  |  |  |  |  |  |  |  |  |  | { |  |  |
|  |  |  |  |  |  |  |  |  |  | "rstCd": 20, |  |  |
|  |  |  |  |  |  |  |  |  |  | "isDisp": true, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemNo": 19, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemKey": "rstWeightInfo:ihdf_pll", |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemName": "I-HDF引き残" |  |  |
|  |  |  |  |  |  |  |  |  |  | }, |  |  |
|  |  |  |  |  |  |  |  |  |  | { |  |  |
|  |  |  |  |  |  |  |  |  |  | "rstCd": 21, |  |  |
|  |  |  |  |  |  |  |  |  |  | "isDisp": true, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemNo": 20, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemKey": "rstWeightInfo:kt_v_measure", |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemName": "Kt/V測定値" |  |  |
|  |  |  |  |  |  |  |  |  |  | }, |  |  |
|  |  |  |  |  |  |  |  |  |  | { |  |  |
|  |  |  |  |  |  |  |  |  |  | "rstCd": 22, |  |  |
|  |  |  |  |  |  |  |  |  |  | "isDisp": true, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemNo": 21, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemKey": "rstWeightInfo:urr", |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemName": "URR" |  |  |
|  |  |  |  |  |  |  |  |  |  | }, |  |  |
|  |  |  |  |  |  |  |  |  |  | { |  |  |
|  |  |  |  |  |  |  |  |  |  | "rstCd": 23, |  |  |
|  |  |  |  |  |  |  |  |  |  | "isDisp": true, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemNo": 22, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemKey": "rstWeightInfo:recrcl_rt:rate", |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemName": "再循環率" |  |  |
|  |  |  |  |  |  |  |  |  |  | }, |  |  |
|  |  |  |  |  |  |  |  |  |  | { |  |  |
|  |  |  |  |  |  |  |  |  |  | "rstCd": 24, |  |  |
|  |  |  |  |  |  |  |  |  |  | "isDisp": true, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemNo": 23, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemKey": "rstWeightInfo:recrcl_rt:bld_vl", |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemName": "再循環率測定時血流量" |  |  |
|  |  |  |  |  |  |  |  |  |  | }, |  |  |
|  |  |  |  |  |  |  |  |  |  | { |  |  |
|  |  |  |  |  |  |  |  |  |  | "rstCd": 25, |  |  |
|  |  |  |  |  |  |  |  |  |  | "isDisp": true, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemNo": 24, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemKey": "rstWeightInfo:recrcl_rt:datetime", |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemName": "再循環率測定日時" |  |  |
|  |  |  |  |  |  |  |  |  |  | }, |  |  |
|  |  |  |  |  |  |  |  |  |  | { |  |  |
|  |  |  |  |  |  |  |  |  |  | "rstCd": 26, |  |  |
|  |  |  |  |  |  |  |  |  |  | "isDisp": true, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemNo": 25, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemKey": "rstWeightInfo:sttc_vns_prssr", |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemName": "静的静脈圧" |  |  |
|  |  |  |  |  |  |  |  |  |  | }, |  |  |
|  |  |  |  |  |  |  |  |  |  | { |  |  |
|  |  |  |  |  |  |  |  |  |  | "rstCd": 27, |  |  |
|  |  |  |  |  |  |  |  |  |  | "isDisp": true, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemNo": 26, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemKey": "rstWeightInfo:iap_rt", |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemName": "IAP Ratio" |  |  |
|  |  |  |  |  |  |  |  |  |  | }, |  |  |
|  |  |  |  |  |  |  |  |  |  | { |  |  |
|  |  |  |  |  |  |  |  |  |  | "rstCd": 28, |  |  |
|  |  |  |  |  |  |  |  |  |  | "isDisp": true, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemNo": 27, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemKey": "preBp", |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemName": "透析前血圧" |  |  |
|  |  |  |  |  |  |  |  |  |  | }, |  |  |
|  |  |  |  |  |  |  |  |  |  | { |  |  |
|  |  |  |  |  |  |  |  |  |  | "rstCd": 29, |  |  |
|  |  |  |  |  |  |  |  |  |  | "isDisp": true, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemNo": 28, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemKey": "postBp", |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemName": "透析後血圧" |  |  |
|  |  |  |  |  |  |  |  |  |  | }, |  |  |
|  |  |  |  |  |  |  |  |  |  | { |  |  |
|  |  |  |  |  |  |  |  |  |  | "rstCd": 30, |  |  |
|  |  |  |  |  |  |  |  |  |  | "isDisp": true, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemNo": 29, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemKey": "temperature", |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemName": "体温" |  |  |
|  |  |  |  |  |  |  |  |  |  | } |  |  |
|  |  |  |  |  |  |  |  |  |  | ], |  |  |
|  |  |  |  |  |  |  |  |  |  | "subCategoryName": "実績情報" |  |  |
|  |  |  |  |  |  |  |  |  |  | }, |  |  |
|  |  |  |  |  |  |  |  |  |  | { |  |  |
|  |  |  |  |  |  |  |  |  |  | "isDisp": true, |  |  |
|  |  |  |  |  |  |  |  |  |  | "dataKey": "vital_monitor_flg_1", |  |  |
|  |  |  |  |  |  |  |  |  |  | "graphMax": "100.00", |  |  |
|  |  |  |  |  |  |  |  |  |  | "graphMin": "0.00", |  |  |
|  |  |  |  |  |  |  |  |  |  | "subCategoryNo": 11, |  |  |
|  |  |  |  |  |  |  |  |  |  | "subCategoryItem": [ |  |  |
|  |  |  |  |  |  |  |  |  |  | { |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemNo": -2, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemName": "SpO2", |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemColor": "#966d42", |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemPoint": "circle-b", |  |  |
|  |  |  |  |  |  |  |  |  |  | "tableType": 1, |  |  |
|  |  |  |  |  |  |  |  |  |  | "vitalMonitorClass": "1" |  |  |
|  |  |  |  |  |  |  |  |  |  | } |  |  |
|  |  |  |  |  |  |  |  |  |  | ], |  |  |
|  |  |  |  |  |  |  |  |  |  | "subCategoryName": "バイタル・モニタグラフ①-1　入室～退室" |  |  |
|  |  |  |  |  |  |  |  |  |  | }, |  |  |
|  |  |  |  |  |  |  |  |  |  | { |  |  |
|  |  |  |  |  |  |  |  |  |  | "isDisp": true, |  |  |
|  |  |  |  |  |  |  |  |  |  | "dataKey": "vital_monitor_flg_1", |  |  |
|  |  |  |  |  |  |  |  |  |  | "subCategoryNo": 12, |  |  |
|  |  |  |  |  |  |  |  |  |  | "subCategoryItem": [], |  |  |
|  |  |  |  |  |  |  |  |  |  | "subCategoryName": "バイタル・モニタグラフ①-2　入室～退室" |  |  |
|  |  |  |  |  |  |  |  |  |  | }, |  |  |
|  |  |  |  |  |  |  |  |  |  | { |  |  |
|  |  |  |  |  |  |  |  |  |  | "isDisp": true, |  |  |
|  |  |  |  |  |  |  |  |  |  | "dataKey": "vital_monitor_flg_1", |  |  |
|  |  |  |  |  |  |  |  |  |  | "subCategoryNo": 13, |  |  |
|  |  |  |  |  |  |  |  |  |  | "subCategoryItem": [], |  |  |
|  |  |  |  |  |  |  |  |  |  | "subCategoryName": "バイタル・モニタグラフ①-3　入室～退室" |  |  |
|  |  |  |  |  |  |  |  |  |  | }, |  |  |
|  |  |  |  |  |  |  |  |  |  | { |  |  |
|  |  |  |  |  |  |  |  |  |  | "isDisp": true, |  |  |
|  |  |  |  |  |  |  |  |  |  | "dataKey": "vital_monitor_flg_2", |  |  |
|  |  |  |  |  |  |  |  |  |  | "subCategoryNo": 21, |  |  |
|  |  |  |  |  |  |  |  |  |  | "subCategoryItem": [], |  |  |
|  |  |  |  |  |  |  |  |  |  | "subCategoryName": "バイタル・モニタグラフ②-1　入室～退室" |  |  |
|  |  |  |  |  |  |  |  |  |  | }, |  |  |
|  |  |  |  |  |  |  |  |  |  | { |  |  |
|  |  |  |  |  |  |  |  |  |  | "isDisp": true, |  |  |
|  |  |  |  |  |  |  |  |  |  | "dataKey": "vital_monitor_flg_2", |  |  |
|  |  |  |  |  |  |  |  |  |  | "graphMax": "200.00", |  |  |
|  |  |  |  |  |  |  |  |  |  | "graphMin": "0.00", |  |  |
|  |  |  |  |  |  |  |  |  |  | "subCategoryNo": 22, |  |  |
|  |  |  |  |  |  |  |  |  |  | "subCategoryItem": [ |  |  |
|  |  |  |  |  |  |  |  |  |  | { |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemNo": -1, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemName": "血糖値", |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemColor": "#25bd94", |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemPoint": "circle", |  |  |
|  |  |  |  |  |  |  |  |  |  | "tableType": 1, |  |  |
|  |  |  |  |  |  |  |  |  |  | "vitalMonitorClass": "1" |  |  |
|  |  |  |  |  |  |  |  |  |  | } |  |  |
|  |  |  |  |  |  |  |  |  |  | ], |  |  |
|  |  |  |  |  |  |  |  |  |  | "subCategoryName": "バイタル・モニタグラフ②-2　入室～退室" |  |  |
|  |  |  |  |  |  |  |  |  |  | }, |  |  |
|  |  |  |  |  |  |  |  |  |  | { |  |  |
|  |  |  |  |  |  |  |  |  |  | "isDisp": true, |  |  |
|  |  |  |  |  |  |  |  |  |  | "dataKey": "vital_monitor_flg_2", |  |  |
|  |  |  |  |  |  |  |  |  |  | "subCategoryNo": 23, |  |  |
|  |  |  |  |  |  |  |  |  |  | "subCategoryItem": [], |  |  |
|  |  |  |  |  |  |  |  |  |  | "subCategoryName": "バイタル・モニタグラフ②-3　入室～退室" |  |  |
|  |  |  |  |  |  |  |  |  |  | }, |  |  |
|  |  |  |  |  |  |  |  |  |  | { |  |  |
|  |  |  |  |  |  |  |  |  |  | "isDisp": true, |  |  |
|  |  |  |  |  |  |  |  |  |  | "dataKey": "vital_monitor_flg_3", |  |  |
|  |  |  |  |  |  |  |  |  |  | "subCategoryNo": 31, |  |  |
|  |  |  |  |  |  |  |  |  |  | "subCategoryItem": [], |  |  |
|  |  |  |  |  |  |  |  |  |  | "subCategoryName": "バイタル・モニタグラフ③-1　入室～退室" |  |  |
|  |  |  |  |  |  |  |  |  |  | }, |  |  |
|  |  |  |  |  |  |  |  |  |  | { |  |  |
|  |  |  |  |  |  |  |  |  |  | "isDisp": true, |  |  |
|  |  |  |  |  |  |  |  |  |  | "dataKey": "vital_monitor_flg_3", |  |  |
|  |  |  |  |  |  |  |  |  |  | "subCategoryNo": 32, |  |  |
|  |  |  |  |  |  |  |  |  |  | "subCategoryItem": [], |  |  |
|  |  |  |  |  |  |  |  |  |  | "subCategoryName": "バイタル・モニタグラフ③-2　入室～退室" |  |  |
|  |  |  |  |  |  |  |  |  |  | }, |  |  |
|  |  |  |  |  |  |  |  |  |  | { |  |  |
|  |  |  |  |  |  |  |  |  |  | "isDisp": true, |  |  |
|  |  |  |  |  |  |  |  |  |  | "dataKey": "vital_monitor_flg_3", |  |  |
|  |  |  |  |  |  |  |  |  |  | "graphMax": "100.00", |  |  |
|  |  |  |  |  |  |  |  |  |  | "graphMin": "0.00", |  |  |
|  |  |  |  |  |  |  |  |  |  | "subCategoryNo": 33, |  |  |
|  |  |  |  |  |  |  |  |  |  | "subCategoryItem": [ |  |  |
|  |  |  |  |  |  |  |  |  |  | { |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemNo": 8, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemName": "血流量", |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemColor": "#f60a70", |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemPoint": "square-b", |  |  |
|  |  |  |  |  |  |  |  |  |  | "tableType": 1, |  |  |
|  |  |  |  |  |  |  |  |  |  | "vitalMonitorClass": "2" |  |  |
|  |  |  |  |  |  |  |  |  |  | } |  |  |
|  |  |  |  |  |  |  |  |  |  | ], |  |  |
|  |  |  |  |  |  |  |  |  |  | "subCategoryName": "バイタル・モニタグラフ③-3　入室～退室" |  |  |
|  |  |  |  |  |  |  |  |  |  | }, |  |  |
|  |  |  |  |  |  |  |  |  |  | { |  |  |
|  |  |  |  |  |  |  |  |  |  | "isDisp": true, |  |  |
|  |  |  |  |  |  |  |  |  |  | "dataKey": "vital_monitor_flg_4", |  |  |
|  |  |  |  |  |  |  |  |  |  | "subCategoryNo": 41, |  |  |
|  |  |  |  |  |  |  |  |  |  | "subCategoryItem": [], |  |  |
|  |  |  |  |  |  |  |  |  |  | "subCategoryName": "バイタル・モニタグラフ④-1　入室～退室" |  |  |
|  |  |  |  |  |  |  |  |  |  | }, |  |  |
|  |  |  |  |  |  |  |  |  |  | { |  |  |
|  |  |  |  |  |  |  |  |  |  | "isDisp": true, |  |  |
|  |  |  |  |  |  |  |  |  |  | "dataKey": "vital_monitor_flg_4", |  |  |
|  |  |  |  |  |  |  |  |  |  | "subCategoryNo": 42, |  |  |
|  |  |  |  |  |  |  |  |  |  | "subCategoryItem": [], |  |  |
|  |  |  |  |  |  |  |  |  |  | "subCategoryName": "バイタル・モニタグラフ④-2　入室～退室" |  |  |
|  |  |  |  |  |  |  |  |  |  | }, |  |  |
|  |  |  |  |  |  |  |  |  |  | { |  |  |
|  |  |  |  |  |  |  |  |  |  | "isDisp": true, |  |  |
|  |  |  |  |  |  |  |  |  |  | "dataKey": "vital_monitor_flg_4", |  |  |
|  |  |  |  |  |  |  |  |  |  | "subCategoryNo": 43, |  |  |
|  |  |  |  |  |  |  |  |  |  | "subCategoryItem": [], |  |  |
|  |  |  |  |  |  |  |  |  |  | "subCategoryName": "バイタル・モニタグラフ④-3　入室～退室" |  |  |
|  |  |  |  |  |  |  |  |  |  | } |  |  |
|  |  |  |  |  |  |  |  |  |  | ], |  |  |
|  |  |  |  |  |  |  |  |  |  | "categoryName": "治療情報" |  |  |
|  |  |  |  |  |  |  |  |  |  | }, |  |  |
|  |  |  |  |  |  |  |  |  |  | { |  |  |
|  |  |  |  |  |  |  |  |  |  | "isDisp": true, |  |  |
|  |  |  |  |  |  |  |  |  |  | "categoryNo": 3, |  |  |
|  |  |  |  |  |  |  |  |  |  | "categoryItem": [ |  |  |
|  |  |  |  |  |  |  |  |  |  | { |  |  |
|  |  |  |  |  |  |  |  |  |  | "isDisp": true, |  |  |
|  |  |  |  |  |  |  |  |  |  | "dataKey": "exam_result", |  |  |
|  |  |  |  |  |  |  |  |  |  | "dispGroup": "exam_result", |  |  |
|  |  |  |  |  |  |  |  |  |  | "subCategoryNo": 1, |  |  |
|  |  |  |  |  |  |  |  |  |  | "subCategoryItem": [], |  |  |
|  |  |  |  |  |  |  |  |  |  | "subCategoryName": "検査結果" |  |  |
|  |  |  |  |  |  |  |  |  |  | }, |  |  |
|  |  |  |  |  |  |  |  |  |  | { |  |  |
|  |  |  |  |  |  |  |  |  |  | "isDisp": true, |  |  |
|  |  |  |  |  |  |  |  |  |  | "dataKey": "exam_request", |  |  |
|  |  |  |  |  |  |  |  |  |  | "dispGroup": "exam_request", |  |  |
|  |  |  |  |  |  |  |  |  |  | "subCategoryNo": 2, |  |  |
|  |  |  |  |  |  |  |  |  |  | "subCategoryItem": [ |  |  |
|  |  |  |  |  |  |  |  |  |  | { |  |  |
|  |  |  |  |  |  |  |  |  |  | "isDisp": true, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemNo": 1, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemName": "検査セット名" |  |  |
|  |  |  |  |  |  |  |  |  |  | } |  |  |
|  |  |  |  |  |  |  |  |  |  | ], |  |  |
|  |  |  |  |  |  |  |  |  |  | "subCategoryName": "検査予定" |  |  |
|  |  |  |  |  |  |  |  |  |  | } |  |  |
|  |  |  |  |  |  |  |  |  |  | ], |  |  |
|  |  |  |  |  |  |  |  |  |  | "categoryName": "検査" |  |  |
|  |  |  |  |  |  |  |  |  |  | }, |  |  |
|  |  |  |  |  |  |  |  |  |  | { |  |  |
|  |  |  |  |  |  |  |  |  |  | "isDisp": true, |  |  |
|  |  |  |  |  |  |  |  |  |  | "categoryNo": 4, |  |  |
|  |  |  |  |  |  |  |  |  |  | "categoryItem": [ |  |  |
|  |  |  |  |  |  |  |  |  |  | { |  |  |
|  |  |  |  |  |  |  |  |  |  | "isDisp": true, |  |  |
|  |  |  |  |  |  |  |  |  |  | "dataKey": "rad_request", |  |  |
|  |  |  |  |  |  |  |  |  |  | "dispGroup": "rad_request", |  |  |
|  |  |  |  |  |  |  |  |  |  | "subCategoryNo": 1, |  |  |
|  |  |  |  |  |  |  |  |  |  | "subCategoryItem": [], |  |  |
|  |  |  |  |  |  |  |  |  |  | "subCategoryName": "一般撮影検査予定" |  |  |
|  |  |  |  |  |  |  |  |  |  | } |  |  |
|  |  |  |  |  |  |  |  |  |  | ], |  |  |
|  |  |  |  |  |  |  |  |  |  | "categoryName": "一般撮影検査" |  |  |
|  |  |  |  |  |  |  |  |  |  | }, |  |  |
|  |  |  |  |  |  |  |  |  |  | { |  |  |
|  |  |  |  |  |  |  |  |  |  | "isDisp": true, |  |  |
|  |  |  |  |  |  |  |  |  |  | "categoryNo": 5, |  |  |
|  |  |  |  |  |  |  |  |  |  | "categoryItem": [ |  |  |
|  |  |  |  |  |  |  |  |  |  | { |  |  |
|  |  |  |  |  |  |  |  |  |  | "isDisp": true, |  |  |
|  |  |  |  |  |  |  |  |  |  | "dataKey": "pat_event", |  |  |
|  |  |  |  |  |  |  |  |  |  | "dispGroup": "pat_event", |  |  |
|  |  |  |  |  |  |  |  |  |  | "subCategoryNo": 1, |  |  |
|  |  |  |  |  |  |  |  |  |  | "subCategoryItem": [ |  |  |
|  |  |  |  |  |  |  |  |  |  | { |  |  |
|  |  |  |  |  |  |  |  |  |  | "isDisp": true, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemNo": 2, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemName": "VA管理サブ１", |  |  |
|  |  |  |  |  |  |  |  |  |  | "isPatEventSub": 1 |  |  |
|  |  |  |  |  |  |  |  |  |  | } |  |  |
|  |  |  |  |  |  |  |  |  |  | ], |  |  |
|  |  |  |  |  |  |  |  |  |  | "subCategoryName": "患者イベント" |  |  |
|  |  |  |  |  |  |  |  |  |  | } |  |  |
|  |  |  |  |  |  |  |  |  |  | ], |  |  |
|  |  |  |  |  |  |  |  |  |  | "categoryName": "患者イベント" |  |  |
|  |  |  |  |  |  |  |  |  |  | }, |  |  |
|  |  |  |  |  |  |  |  |  |  | { |  |  |
|  |  |  |  |  |  |  |  |  |  | "isDisp": true, |  |  |
|  |  |  |  |  |  |  |  |  |  | "categoryNo": 6, |  |  |
|  |  |  |  |  |  |  |  |  |  | "categoryItem": [ |  |  |
|  |  |  |  |  |  |  |  |  |  | { |  |  |
|  |  |  |  |  |  |  |  |  |  | "isDisp": true, |  |  |
|  |  |  |  |  |  |  |  |  |  | "dataKey": "prescription", |  |  |
|  |  |  |  |  |  |  |  |  |  | "dispGroup": "prescription", |  |  |
|  |  |  |  |  |  |  |  |  |  | "subCategoryNo": 1, |  |  |
|  |  |  |  |  |  |  |  |  |  | "subCategoryItem": [], |  |  |
|  |  |  |  |  |  |  |  |  |  | "subCategoryName": "処方" |  |  |
|  |  |  |  |  |  |  |  |  |  | } |  |  |
|  |  |  |  |  |  |  |  |  |  | ], |  |  |
|  |  |  |  |  |  |  |  |  |  | "categoryName": "処方" |  |  |
|  |  |  |  |  |  |  |  |  |  | }, |  |  |
|  |  |  |  |  |  |  |  |  |  | { |  |  |
|  |  |  |  |  |  |  |  |  |  | "isDisp": true, |  |  |
|  |  |  |  |  |  |  |  |  |  | "categoryNo": 7, |  |  |
|  |  |  |  |  |  |  |  |  |  | "categoryItem": [ |  |  |
|  |  |  |  |  |  |  |  |  |  | { |  |  |
|  |  |  |  |  |  |  |  |  |  | "isDisp": true, |  |  |
|  |  |  |  |  |  |  |  |  |  | "dataKey": "bbs_info", |  |  |
|  |  |  |  |  |  |  |  |  |  | "dispGroup": "bbs_info", |  |  |
|  |  |  |  |  |  |  |  |  |  | "subCategoryNo": 1, |  |  |
|  |  |  |  |  |  |  |  |  |  | "subCategoryItem": [ |  |  |
|  |  |  |  |  |  |  |  |  |  | { |  |  |
|  |  |  |  |  |  |  |  |  |  | "isDisp": true, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemNo": 12, |  |  |
|  |  |  |  |  |  |  |  |  |  | "itemName": "その他" |  |  |
|  |  |  |  |  |  |  |  |  |  | } |  |  |
|  |  |  |  |  |  |  |  |  |  | ], |  |  |
|  |  |  |  |  |  |  |  |  |  | "subCategoryName": "施設イベント" |  |  |
|  |  |  |  |  |  |  |  |  |  | } |  |  |
|  |  |  |  |  |  |  |  |  |  | ], |  |  |
|  |  |  |  |  |  |  |  |  |  | "categoryName": "施設イベント" |  |  |
|  |  |  |  |  |  |  |  |  |  | } |  |  |
|  |  |  |  |  |  |  |  |  |  | ] |  |  |
