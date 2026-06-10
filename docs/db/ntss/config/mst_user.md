# mst_user

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `@mst_user`
- Category: config/reference

## Content

| col1 | col2 | col3 | col4 | col5 | col6 |
| --- | --- | --- | --- | --- | --- |
| ■JSON情報 |  |  |  |  |  |
|  | カラム名 | 名称 |  | 値 | 説明 |
|  | user_settings | ユーザー設定 | {<br>  is_disp_menu: numeric,<br>  font_size: numeric,<br>  theme: numeric,<br>  use_functions: [string, …],<br>  initial_function: string,<br>  authorized_functions: [string, …],<br>  authorized_authorities: [string, …],<br>  ind_rst_pattern: numeric,<br>  personal_settings: [<br>    {<br>      tab_define_cd: number // mst_personal_tab_define.tab_define_cd,<br>      values: [{<br>         setting_identifier: string,<br>         value: any<br>      }]<br>    }<br> ],<br> is_split_frame: numeric<br>} |  | メニュー表示フラグ：<br>　0:非表示<br>　1:表示 |
|  |  |  |  |  | フォントサイズ：<br>  0:小<br>  1:中<br>  2:大<br>  3:特大 |
|  |  |  |  |  | テーマ：<br>  0:白<br>  1:黒 |
|  |  |  |  |  | 使用機能コード：<br>  使用する機能コードを表示する順番に配列で指定 |
|  |  |  |  |  | 初期表示機能コード：<br>  ログイン後最初に表示する機能コードを指定 |
|  |  |  |  |  | 使用可能機能コード：<br>　使用可能な機能コードを配列で指定 |
|  |  |  |  |  | 許可権限コード：<br>　許可する権限コードを配列で指定<br>　指定する権限コードはシート：@権限コードを参照<br>凡例：<br>{<br>    "theme": 0,<br>    "font_size": 0,<br>    "is_disp_menu": 1,<br>    "use_functions": [<br>        "001",<br>        "003",<br>        "006"<br>    ],<br>    "ind_rst_pattern": null,<br>    "initial_function": "001",<br>    "authorized_functions": [],<br>    "authorized_authorities": [<br>        "031",<br>        "032",<br>        "033"<br>    ]<br>} |
|  |  |  |  |  | 予実リスト表示形式：<br>　1：カテゴリ、予実・日付<br>　2：カテゴリ、日付、予実<br>　3：カテゴリ、予実、日付<br>　4：日付、予実・カテゴリ<br>　5：日付、カテゴリ、予実<br>　6：日付、予実、カテゴリ |
|  |  |  |  |  | 個人設定内容：個人設定画面で設定した値を格納<br>　tab_define_cd : (integer)タブ定義コード<br>  values: 設定項目とその設定値を配列で指定<br>  setting_identifier: (string) // 設定項目ID<br>  value: (any) // 設定値 |
|  |  |  |  |  | 画面フレーム分割：<br>　0:しない<br>　1:する |
| ■user_settings ->> default_settingの詳細 |  |  |  |  |  |
|  | キー | 名称 | 項目キー名 | 項目名称 | 説明 |
|  | patient-search | 患者検索 | sortConditions | ソート条件 | 対象ソート条件リスト<br>上から第1、第2、第3条件<br>{<br>	"key": null,<br>	"isAsc": 1<br>},<br>{<br>	"key": null,<br>	"isAsc": 1<br>},<br>{<br>	"key": null,<br>	"isAsc": 1<br>}<br><br>key:対象条件<br>isAsc:1:昇順 2:降順 |
|  |  |  | bedCdListString | ベッドグループ | 検索対象ベッドグループコード |
|  |  |  | selectedPatGroups | 患者グループ | 検索対象患者グループコードリスト |
|  |  |  | queryPatGroupsMethod | 患者グループチェックボックス | 1:含む　2:一致する |
|  | indication-result | 予実リスト | filter | フィルター | 1:カテゴリ、予実・日付<br>2:カテゴリ、日付、予実<br>3:カテゴリ、予実、日付<br>4:日付、予実・カテゴリ<br>5:日付、カテゴリ、予実<br>6:日付、予実、カテゴリ |
|  |  |  | treatDateTo | 終了日 | 20:本日<br>21:今週終了日<br>22:1週間後<br>23:2週間後<br>24:1ヶ月後<br>25:3ヶ月後 |
|  |  |  | treatDateFrom | 開始日 | 20:本日<br>8:今週開始日<br>7:1週間前<br>6:2週間前<br>5:1ヶ月前<br>4:3ヶ月前 |
|  |  |  | pastIndication | 過去予定 | true:表示　false:非表示 |
|  |  |  | selectExpressCondList | 表示条件 | 001:予定<br>002:実績<br>003:患者イベント<br>004:検査予定<br>005:検査結果<br>006:一般撮影予定<br>007:処方 |
|  | pat-info | 患者情報・新規患者登録 | implantCard | インプラント | true:表示　false:非表示 |
|  |  |  | patMemoCard | 患者メモ | true:表示　false:非表示 |
|  |  |  | patGroupCard | 患者グループ | true:表示　false:非表示 |
|  |  |  | visitHstCard | 入外転入出 | true:表示　false:非表示 |
|  |  |  | basicInfoCard | 本人情報 | true:表示　false:非表示 |
|  |  |  | infectionCard | 感染症 | true:表示　false:非表示 |
|  |  |  | medicalHstCard | 既往歴 | true:表示　false:非表示 |
|  |  |  | chargeStaffCard | 担当情報 | true:表示　false:非表示 |
|  |  |  | otherContactCard | 連絡先 | true:表示　false:非表示 |
|  |  |  | physicalInfoCard | 身体情報 | true:表示　false:非表示 |
|  |  |  | tabooAllergyCard | 禁忌アレルギー | true:表示　false:非表示 |
|  |  |  | insuranceInfoCard | 保険情報 | true:表示　false:非表示 |
|  |  |  | remoteMonitorCard | 遠隔 | true:表示　false:非表示 |
|  |  |  | vendorContactCard | 業者連絡先 | true:表示　false:非表示 |
|  |  |  | additionSettingCard | 加算・管理料 | true:表示　false:非表示 |
|  |  |  | medicalCareInfoCard | 診療 | true:表示　false:非表示 |
|  |  |  | difficultySeverityTransportCard | 困難・搬送 | true:表示　false:非表示 |
|  | pat-viewer | 患者経過総合ビューア | isExtendedView | 拡張表示 | true:表示　false:非表示 |
|  |  |  | selectedPeriod | 期間 | 1:3日分<br>2:7日分<br>3:14日分<br>4:12週<br>5:6ヶ月　<br>6:1年<br>7:3年 |
|  |  |  | isTreatmentOnly | 治療日のみ表示 | true:表示　false:非表示 |
|  |  |  | selectedShowIndRst | 指示/実績の表示 | 1:指示のみ　2:実績優先　3:実績指示併記 |
|  |  |  | setSelectedLayoutCd | レイアウト | 対象レイアウトコード |
|  | pat-calendar | 患者カレンダー | expandFlg | 展開する | true:展開する　false:展開しない |
|  |  |  | selectedLayoutCd | レイアウト | 対象レイアウトコード |
|  | indication | 指示受け・指示承認 | check1 | 指示受け1 | 1:すべて　2:未　3:済 |
|  |  |  | check2 | 指示受け2 | 1:すべて　2:未　3:済 |
|  |  |  | kurCds | 治療単位のクール | 対象クールコードリスト |
|  |  |  | userId | 指示単位指示者 | 対象指示者 |
|  |  |  | approver1 | 指示承認1 | 1:すべて　2:未　3:済 |
|  |  |  | approver2 | 指示承認2 | 1:すべて　2:未　3:済 |
|  |  |  | indKurCds | 指示単位のクール | 対象クールコードリスト |
|  |  |  | bedGroupCd | 治療単位のベッドグループ | 対象ベッドグループコード |
|  |  |  | treatmentCd | 治療方法 | 対象治療方法 |
|  |  |  | instructorId | 治療単位指示者 | 対象指示者 |
|  |  |  | indBedGroupCd | 指示単位のベッドグループ | 対象ベッドグループコード |
|  |  |  | indicationList | 対象指示 | クール<br>治療開始時刻<br>ベッド<br>治療時間<br>VA<br>目標体重<br>除水量制限<br>ダイアライザ<br>吸着カラム<br>1次膜<br>2次膜<br>穿刺針(A針)<br>穿刺針(V針)<br>穿刺針(SN)<br>シングルニードル使用<br>血液回路<br>血液量<br>透析液<br>透析液流量<br>透析液使用数<br>透析液温度<br>補液<br>補液量<br>補液選択<br>補液使用数<br>補液温度<br>補液速度<br>抗凝固剤<br>抗凝固剤ワンショット量<br>抗凝固剤持続速度<br>抗凝固剤持続総量<br>IP使用選択<br>IPスタート<br>IPワンショット量<br>IP速度<br>IP速度最大値<br>IPワンショットスタート<br>IPワンショット量<br>IP電源自動切り<br>IP電源自動切り時間<br>IP電源OKモニタ切り<br>IP電源OKモニタ切り時間<br>投与薬剤<br>医療材料<br>指示コメント<br>治療予定<br>治療方法 |
|  |  |  | checker1HasNotReceived | 未指示受け1のみ表示 | true:表示　false:非表示 |
|  |  |  | checker2HasNotReceived | 未指示受け2のみ表示 | true:表示　false:非表示 |
|  |  |  | treatmentScheduledDate | 治療予定日 | "":未指定<br>20:本日 |
|  |  |  | approver1HasNotApproved | 未指示承認1のみ表示 | true:表示　false:非表示 |
|  |  |  | approver2HasNotApproved | 未指示承認2のみ表示 | true:表示　false:非表示 |
|  | schedule-list | スケジュール表 | bedGroupCd | ベッドグループ | 対象ベッドグループコード |
|  |  |  | isCheckedName | 姓のみ表示 | true:表示　false:非表示 |
|  |  |  | isCheckedPlan | 他の予定有◆表示 | true:表示　false:非表示 |
|  |  |  | dispWeekDuration | 表示期間 | 1:1週　2:2週　3:3週 |
|  |  |  | isCheckedHoliday | 休日表示 | true:表示　false:非表示 |
|  |  |  | isCheckedUnmatch | 不一致！表示 | true:表示　false:非表示 |
|  |  |  | isShowUsageGuide | 凡例の表示 | true:表示　false:非表示 |
|  |  |  | selectedKurIndexList | クール | 対象クールコードリスト |
|  |  |  | isCheckedPlanMainteWater | 定期点検・水質検査予定■表示 | true:表示　false:非表示 |
|  | measure-history | 体重計測定記録 | kurCd | クール | 対象クールコード |
|  |  |  | freeWord | フリーワード | 対象フリーワード |
|  |  |  | bedGroupCd | ベッドグループ | 対象ベッドグループコード |
|  |  |  | weightScaleStatus | 条件送信結果 | -1:すべて<br>0:測定済み<br>1:条件送信指示中<br>2:待機<br>3:条件送信成功<br>4:条件送信失敗 |
|  | status-list | 治療状況リスト | dispDab | 供給装置表示 | true:表示　false:非表示 |
|  |  |  | dispDad | 溶解装置表示 | true:表示　false:非表示 |
|  |  |  | dispDro | RO装置表示 | true:表示　false:非表示 |
|  |  |  | dispMode | 治療状況/装置一覧切替 | 1:治療状況　2:装置一覧 |
|  |  |  | bedGroupCd | ベッドグループ | 対象ベッドグループコード |
|  |  |  | kurGroupList | クール | 対象クールコードリスト |
|  |  |  | notUsageGuide | 凡例を表示しない | true:表示しない　false:する |
|  |  |  | deviceNextIndex | 装置一覧次患者表示 | 0:表示しない　1:現クール 2:次クール |
|  |  |  | colItemGroupIndex | 表示項目 | 対象レイアウトコード |
|  |  |  | nextPatGroupIndex | 治療状況次患者表示 | 0:表示しない　1:現クール 2:次クール |
|  | status-map | 治療状況マップ | dispMode | 治療状況/スケジュール切替 | 1:治療状況　2:スケジュール |
|  |  |  | kurIndex | クール | 対象クールコード |
|  |  |  | bedGroupCd | ベッドグループ | 対象ベッドグループコード |
|  |  |  | bedLayoutIndex | ベッドレイアウト | 対象ベッドレイアウトコード |
|  |  |  | nextPatGroupIndex | 次患者表示 | 0:表示しない　1:現クール 2:次クール |
|  |  |  | statusLayoutIndex | 表示項目 | 対象の治療状況レイアウトマスタコード |
|  | check-list | チェックリスト | kurCd | クール | 対象クールコード |
|  |  |  | dispMode | 治療中/指定日切替 | 1:治療中　2:指定日 |
|  |  |  | bedGroupCd | ベッドグループ | 対象ベッドグループコード |
|  |  |  | isAutoReload | 画面自動更新 | true:更新　false:更新しない |
|  |  |  | viewTreatDate | 治療日列表示 | true:表示　false:非表示 |
|  |  |  | isShowUsageGuide | 凡例の表示 | true:表示　false:非表示 |
|  |  |  | nextPatGroupIndex | 次患者 | 0:表示しない　1:現クール 2:次クール |
|  | pat-event | 患者イベント | endDate | 終了日 | 20:本日<br>21:今週終了日<br>22:1週間後<br>23:2週間後<br>24:1ヶ月後<br>25:3ヶ月後<br>26:6ヶ月後<br>27:1年後 |
|  |  |  | startDate | 開始日 | 20:本日<br>8:今週開始日<br>7:1週間前<br>6:2週間前<br>5:1ヶ月前<br>4:3ヶ月前<br>3:6ヶ月前<br>2:1年前 |
|  |  |  | relationCategoryCd | カテゴリ | 対象カテゴリコード |
|  | observe-record | 観察記録 | endDate | 終了日 | 20:本日<br>21:今週終了日<br>22:1週間後<br>23:2週間後<br>24:1ヶ月後<br>25:3ヶ月後<br>26:6ヶ月後<br>27:1年後 |
|  |  |  | startDate | 開始日 | 20:本日<br>8:今週開始日<br>7:1週間前<br>6:2週間前<br>5:1ヶ月前<br>4:3ヶ月前<br>3:6ヶ月前<br>2:1年前 |
|  |  |  | dispIsEdit | 自分が最終更新 | true:表示　false:非表示 |
|  |  |  | dispIsDraft | 自分が新規作成 | true:表示　false:非表示 |
|  |  |  | obsKindList | カテゴリ | 対象カテゴリコード |
|  | pat-intro-letter | 紹介状 | endDate | 終了日 | 20:本日<br>21:今週終了日<br>22:1週間後<br>23:2週間後<br>24:1ヶ月後<br>25:3ヶ月後<br>26:6ヶ月後<br>27:1年後 |
|  |  |  | startDate | 開始日 | 20:本日<br>8:今週開始日<br>7:1週間前<br>6:2週間前<br>5:1ヶ月前<br>4:3ヶ月前<br>3:6ヶ月前<br>2:1年前 |
|  |  |  | relationCategoryCd | カテゴリ | 対象カテゴリコード |
|  | pat-prescription-list | 処方一覧 | viewPatId | 患者ID列表示 | true:表示　false:非表示 |
|  |  |  | viewDateInfo | 指定日情報列表示 | true:表示　false:非表示 |
|  |  |  | searchDate | 指定日 | 20:本日<br>28:翌日<br>32:明後日<br>33:翌週月曜日<br>22:1週間後<br>24:1ヶ月後 |
|  |  |  | viewPreOut | 過去処方表示_院外 | true:表示　false:非表示 |
|  |  |  | viewPreIn | 過去処方表示_院内 | true:表示　false:非表示 |
|  | pat-prescription | 処方 | endDate | 交付日終了 | 20:本日<br>21:今週終了日<br>22:1週間後<br>23:2週間後<br>24:1ヶ月後<br>25:3ヶ月後<br>26:6ヶ月後<br>27:1年後 |
|  |  |  | checkHos | 処方区分 | 1:全て　2:院外　3:院内 |
|  |  |  | checkIss | 交付状況 | 1:全て　2:未　3:済 |
|  |  |  | startDate | 交付日開始 | 20:本日<br>8:今週開始日<br>7:1週間前<br>6:2週間前<br>5:1ヶ月前<br>4:3ヶ月前<br>3:6ヶ月前<br>2:1年前 |
|  | bbs-info | 掲示板 | kur | クール | 対象クール |
|  |  |  | bedGroupCd | ベッドグループ | 対象ベッドグループコード |
|  |  |  | dialysisDate | 治療日 | "":未指定<br>20:本日 |
|  |  |  | noticeEndDate | 掲載終了日 | 掲載日が1⇒""<br>掲載日が2⇒20<br>掲載日が3⇒28<br>掲載日が4⇒21<br>掲載日が5⇒22 |
|  |  |  | noticeDateType | 掲載日 | 1:未指定<br>2:本日のみ<br>3:本日+翌日<br>4:今週(本日週)<br>5:本日+前後1週間 |
|  |  |  | showOnlyUnread | 未読のみ | true:未読のみ表示　false:すべて表示 |
|  |  |  | noticeStartDate | 掲載開始日 | 掲載日が1⇒""<br>掲載日が2or3⇒20<br>掲載日が4⇒8<br>掲載日が5⇒7 |
|  |  |  | categoryKindList | カテゴリ | 対象カテゴリコードリスト |
|  | facility-calendar | 施設カレンダー | layoutCd | レイアウト | 対象レイアウトコード |
|  |  |  | viewMode | 表示モード | 1:日　2:週　3:月 |
|  |  |  | viewTotal | 集計件数表示 | true:表示　false:非表示 |
|  | exam-request | 検査依頼一覧 | endDate | 表示期間・終了日 | 25:3ヶ月後<br>26:6ヶ月後<br>27:1年後 |
|  |  |  | startDate | 表示期間・開始日 | 20:本日 |
|  |  |  | periodType | 期間/一日切替 | 1:期間　2:一日 |
|  |  |  | examTypeList | 検査区分 | 1:透析前　2:透析後　3:その他 |
|  |  |  | scheduledDate | 検査予定日 | 20:本日<br>28:翌日<br>32:明後日<br>33:翌週月曜日 |
|  |  |  | isShowHospPatId | 患者ID列表示 | true:表示　false:非表示 |
|  |  |  | showScheduledOnly | 予定あり患者のみ表示 | true:表示　false:非表示 |
|  |  |  | isShowDetailsDisplay | 詳細・簡易 | 1:詳細　2:簡易 |
|  |  |  | isShowBloodGlucoseExam | 血糖検査列表示 | true:表示　false:非表示 |
|  | rad-request | 一般撮影検査依頼一覧 | endDate | 表示期間・終了日 | 25:3ヶ月後<br>26:6ヶ月後<br>27:1年後 |
|  |  |  | startDate | 表示期間・開始日 | 20:本日 |
|  |  |  | isShowHospPatId | 患者ID列表示 | true:表示　false:非表示 |
|  |  |  | isShowDetailsDisplay | 詳細・簡易 | 1:詳細　2:簡易 |
|  | exam-record | 検査結果 | outRange | 異常値のみ表示 | true:異常値のみ表示　false:すべて表示 |
|  |  |  | examSetCd | 検査セット | 対象検査セットコード |
|  |  |  | viewPatId | 患者ID列表示 | true:表示　false:非表示 |
|  |  |  | examDateEd | 検査日終了 | 20:本日<br>24:1ヶ月後<br>25:3ヶ月後<br>26:6ヶ月後<br>27:1年後<br>29:3年後 |
|  |  |  | examDateSt | 検査日開始 | 20:本日<br>5:1ヶ月前<br>4:3ヶ月前<br>3:6ヶ月前<br>2:1年前<br>1:3年前 |
|  |  |  | normalRange | 正常範囲列表示 | true:表示　false:非表示 |
|  |  |  | unitDisplay | 単位列表示 | true:表示　false:非表示 |
|  |  |  | viewExamDate | 検査日列表示 | true:表示　false:非表示 |
|  |  |  | viewDayType | 表示条件 | 1:最新結果日、2:最新結果日 |
|  | multi-pat-list | データリスト | startDate | 期間 | 対象期間 |
|  |  |  | selectedLayout | レイアウト | 対象レイアウトコード |
|  | daily-check | 日常点検 | isNon | 未実施 | true:表示　false:非表示 |
|  |  |  | isFail | 点検途中 | true:表示　false:非表示 |
|  |  |  | isPass | 全件合格 | true:表示　false:非表示 |
|  |  |  | keyWord | フリーワード | 対象フリーワード |
|  |  |  | isUnpass | 不合格 | true:表示　false:非表示 |
|  |  |  | bedGroupCd | ベッドグループ | 対象ベッドグループコード |
|  |  |  | machineTypeList | 型式 | 対象型式コードリスト |
|  | periodic-inspection | 定期点検 | toDate | 終了日 | 20:本日<br>26:6ヶ月後<br>27:1年後<br>29:3年後<br>30:5年後<br>31:10年後 |
|  |  |  | fromDate | 開始日 | 20:本日<br>3:6ヶ月前<br>2:1年前<br>1:3年前<br>9:5年前<br>10:10年前 |
|  |  |  | bedGroupCd | ベッドグループ | 対象ベッドグループコード |
|  |  |  | machineTypeList | 型式 | 対象型式コードリスト |
|  | water-quality-survey | 水質管理 | toDate | 終了日 | 20:本日<br>21:今週終了日<br>22:1週間後<br>23:2週間後<br>24:1ヶ月後<br>25:3ヶ月後<br>26:6ヶ月後<br>27:1年後 |
|  |  |  | fromDate | 開始日 | 20:本日<br>8:今週開始日<br>7:1週間前<br>6:2週間前<br>5:1ヶ月前<br>4:3ヶ月前<br>3:6ヶ月前<br>2:1年前<br>1:3年前 |
|  |  |  | bedGroupCd | ベッドグループ | 対象ベッドグループコード |
|  |  |  | surveyTypeCd | 検査種別 | 対象検査種別コードリスト |
|  |  |  | isDispSurveyType | 調査種別列表示 | true:表示　false:非表示 |
|  |  |  | isDispMachineName | 装置名列表示 | true:表示　false:非表示 |
