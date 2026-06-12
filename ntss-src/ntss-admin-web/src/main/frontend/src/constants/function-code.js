// --------------------------------------
// 機能コード
// --------------------------------------
// 稼働ビューア
export const FUNC_OPERATION_VIEWER = '001';
// 生体モニタ
export const FUNC_MONITORING = '002';
// デバイスエッジ稼働監視
export const FUNC_DEVICE_EDGE_OPERATION = '003';
// 患者統合経過ビューア
export const FUNC_PAT_VIEWER = '004';
// マスタメンテナンス
export const FUNC_MASTER_MAINTENANCE = '005';
// 治療記録
export const FUNC_TREATMENT_RECORD = '006';
// 患者情報
export const FUNC_PAT_INFO = '007';
// マルチ患者一覧
export const FUNC_MULTI_PAT_LIST = '008';
// スケジュール表
export const FUNC_SCHEDULE_LIST = '009';
// 装置設定(患者情報)
export const FUNC_PAT_DEVICE_SET = '010';
// 治療状況リスト
export const FUNC_STATUS_LIST_MAIN = '011';
// 治療状況マップ
export const FUNC_STATUS_MAP = '012';
// 体重計・条件送信
export const FUNC_SEND_CONDITION = '013';
// 体重計測定記録
export const FUNC_MEASURE_HISTORY = '014';
// チェックリスト
export const FUNC_CHECK_LIST = '015';
// 観察記録
export const FUNC_OBSERVE_RECORD = '016';
// 患者新規登録
export const FUNC_PAT_INFO_CREATE = '017';
// 検査結果
export const FUNC_EXAM_RECORD = '018';


// 掲示板一覧情報
export const FUNC_BBS_INFO = '020';
// 検査依頼
export const FUNC_EXAM_REQUEST = '021';
//放射線検査依頼
export const FUNC_RAD_REQUEST = '022';
// 患者グループ
export const FUNC_PAT_GROUP = "023"
// 患者カレンダ
export const FUNC_PAT_CALENDAR = '024';
// 帳票
export const FUNC_REPORT_MENU = '019';
// 在宅透析施設用
export const FUNC_FACILITY_HOME_DIALYSIS = '025';
// 在宅透析患者用
export const FUNC_PAT_HOME_DIALYSIS = '026';
// 患者イベント
export const FUNC_PAT_EVENT = '027';
// 定期点検
export const FUNC_PERIODIC_INSPECTION = '033';
// 日常点検
export const FUNC_DAILY_CHECK = '034';

// 指示受け・指示承認
export const FUNC_INDICATION = "028";
// 患者イベント - Clone
export const FUNC_PAT_INTRO_LETTER = '030';
// 処方箋
export const FUNC_PRESCRIPTION = '029';
// ログ参照画面
export const FUNC_VIEW_LOG = '035';
// 水質調査
export const FUNC_WATER_QUALITY_SURVEY = "032";
// 外部連携稼働ビューア
export const FUNC_EXTERNAL_COOP = "031";

// 患者情報共有
export const FUNC_SHARING_PATIENT_INFORMATION = "036";
// 施設カレンダー
export const FUNC_FACILITY_CALENDAR = '037';
// 申込一覧
export const FUNC_APPLICATION_LIST = '038';
// P-Ca9分割グラフ
export const FUNC_SPLIT_GRAPH = "039";
// #11987 2025.12.22 add メニューバー設定にスケールベッドを追加 TDC伊東 start
// スケールベッド
export const FUNC_SCALE_BED = "040";
// #11987 2025.12.22 add メニューバー設定にスケールベッドを追加 TDC伊東 end
// add #10371 BVMS/加算情報の権限がないメッセージが表示され遷移できない 20241012 ztc start
// 拡張機能: 穿刺返血大画面表示
export const FUNC_STATUS_LIST_LARGEDISP = "01103";
// 拡張機能: BVMS
export const FUNC_TREATMENT_RECORD_lIST_BVMS = "00614";
// 拡張機能: 加算情報
export const FUNC_TREATMENT_RECORD_LIST_ADDITIONINFO = "00615";
// add #10371 BVMS/加算情報の権限がないメッセージが表示され遷移できない 20241012 ztc end

// --------------------------------------
// 機能詳細コード

// --------------------------------------
// 施設一覧
export const FUNC_DETAIL_FACILITIES_LIST = FUNC_OPERATION_VIEWER + '01';
// 装置一覧
export const FUNC_DETAIL_MACHINES_LIST = FUNC_OPERATION_VIEWER + '02';
// 装置記録
export const FUNC_DETAIL_MOTION_RECORD_LIST = FUNC_OPERATION_VIEWER + '03';
// 装置記録詳細
export const FUNC_DETAIL_MOTION_RECORD_DETAIL = FUNC_OPERATION_VIEWER + '04';

// --------------------------------------
// 機能名（日本語）
// --------------------------------------
// 稼働ビューア
export const FUNC_OPERATION_VIEWER_JPN_NAME = '遠隔監視';
// 稼働ビューア
export const FUNC_OPERATION_VIEWER_WITH_FACILITY_JPN_NAME = '遠隔監視施設一覧';
// 生体モニタ
export const FUNC_MONITORING_JPN_NAME = '生体モニタリング';
// 生体モニタ詳細
export const FUNC_MONITORING_DETAIL_JPN_NAME = '生体モニタリング詳細';
// デバイスエッジ稼働監視
export const FUNC_DEVICE_EDGE_OPERATION_JPN_NAME = 'デバイスエッジ遠隔監視';
// デバイスエッジ稼働監視管理
export const FUNC_DEVICE_EDGE_MANAGE_JPN_NAME = 'デバイスエッジ遠隔保守';
// 患者統合経過ビューア
export const FUNC_PAT_VIEWER_JPN_NAME = '患者経過総合ビューア';
// アカウント編集画面
export const FUNC_ACCOUNT_EDIT_JPN_NAME = 'アカウント編集';
// 初回ログイン時アカウント登録画面
export const FUNC_PROVISIONAL_ACCOUNT_EDIT_JPN_NAME = '初回ログイン時アカウント登録';
// 担当施設設定
export const FUNC_CHARGE_FACILITY_JPN_NAME = '担当施設設定';
// 装置記録
export const FUNC_MOTION_RECORD_JPN_NAME = '装置記録';
// 装置記録詳細
export const FUNC_MOTION_RECORD_DETAIL_JPN_NAME = '装置記録詳細';
// マスタメンテナンス
export const FUNC_MASTER_MAINTENANCE_JPN_NAME = 'マスタ一覧';
// マスタ編集
export const FUNC_MASTER_MAINTENANCE_RECORD_JPN_NAME = 'マスタ編集';
// ベッドレイアウトマスタ編集
export const FUNC_MASTER_MAINTENANCE_BED_LAYOUT_JPN_NAME = 'ベッドレイアウト編集';
// 治療記録
export const FUNC_TREATMENT_RECORD_JPN_NAME = '治療記録';
// 実績情報
export const FUNC_TREATMENT_RECORD_RESULT_JPN_NAME = '実績情報';
// バイタル
export const FUNC_TREATMENT_RECORD_VITAL_JPN_NAME = 'バイタル';
// モニタ
export const FUNC_TREATMENT_RECORD_MONITOR_JPN_NAME = 'モニタ';
// 愁訴処置
export const FUNC_TREATMENT_RECORD_COMPLAINT_JPN_NAME = '愁訴処置';
// 体重
export const FUNC_TREATMENT_RECORD_WEIGHT_JPN_NAME = '体重';
// 治療条件
export const FUNC_TREATMENT_RECORD_CONDITION_JPN_NAME = '治療条件';
// 投与薬剤
export const FUNC_TREATMENT_RECORD_MEDICINE_JPN_NAME = '投与薬剤';
// 医療材料
export const FUNC_TREATMENT_RECORD_EQUIPMENT_JPN_NAME = '医療材料';
// 指示コメント
export const FUNC_TREATMENT_RECORD_ADDITION_JPN_NAME = '指示コメント';
// 装置設定
export const FUNC_TREATMENT_RECORD_SETTING_JPN_NAME = '装置設定';
// 回診記録
export const FUNC_TREATMENT_RECORD_ROUND_JPN_NAME = '回診記録';
// 観察記録
export const FUNC_TREATMENT_RECORD_OBSERVATION_JPN_NAME = '観察記録';
// BVMS
export const FUNC_TREATMENT_RECORD_BVMS_JPN_NAME = 'BVMS';
// 加算情報
export const FUNC_TREATMENT_RECORD_ADDITION_INFO_JPN_NAME = '加算・管理料';
// 測定患者選択
export const FUNC_WEIGHT_MODE_JPN_NAME = '測定患者選択';
// 体重測定
export const FUNC_SEND_CONDITION_JPN_NAME = '体重測定';
// 体重計モード車いすマスタ編集
export const FUNC_WEIGHT_MODE_WHEEL_CHAIR_JPN_NAME = '車いすマスタ';
// 体重測定記録
export const FUNC_MEASURE_HISTORY_JPN_NAME = '体重計測定記録';
// チェックリスト
export const FUNC_CHECK_LIST_JPN_NAME = 'チェックリスト';
// 観察記録
export const FUNC_OBSERVE_RECORD_JPN_NAME = '観察記録';
// 観察記録詳細
export const FUNC_OBSERVE_RECORD_DETAIL_JPN_NAME = '観察記録詳細';
// 治療状況マップ
export const FUNC_STATUS_MAP_BED_LAYOUT_JPN_NAME = '治療状況ベッドレイアウト';
// 治療状況マップ
export const FUNC_STATUS_MAP_JPN_NAME = '治療状況マップ';

// 治療状況リスト：治療状況
export const FUNC_STATUS_LIST_MAIN_JPN_NAME = '治療状況リスト';
// mod FNSI-文字変更 徐 start
// 治療状況リスト：警報履歴
export const FUNC_STATUS_LIST_ALARM_JPN_NAME = '警報・報知一覧';
// mod FNSI-文字変更 徐 end
// 治療状況リスト：大画面表示
export const FUNC_STATUS_LIST_LARGEDISP_JPN_NAME = '大画面表示';
// 治療状況リスト：透析液調製装置トレンドグラフ
export const FUNC_TREND_GRAPH_JPN_NAME = '透析液調製装置トレンドグラフ';
// 患者情報
export const FUNC_PAT_INFO_JPN_NAME = '患者情報';
// データリスト
export const FUNC_MULTI_PAT_LIST_JPN_NAME = 'データリスト';
// スケジュール表
export const FUNC_SCHEDULE_LIST_JPN_NAME = 'スケジュール表';
// 装置設定(患者情報)
export const FUNC_PAT_DEVICE_SET_JPN_NAME = '装置設定';
// 患者新規登録
export const FUNC_PAT_INFO_CREATE_JPN_NAME = '新規患者登録';
// 検査結果
export const FUNC_EXAM_RECORD_JPN_NAME = '検査結果一覧';
// 検査結果
export const FUNC_EXAM_RECORD_DETAIL_JPN_NAME = '検査結果';
// 検査結果
export const FUNC_CACHE_TEST_JPN_NAME = 'テストページ';
// 検査依頼一覧
//mod #6447-改修内容「タイトル「検査予定一覧」→「検査依頼一覧」」 Thach start
//mod FNSI-改修内容「タイトル「検査依頼一覧」→「検査予定一覧」」 江 start
//export const FUNC_EXAM_REQUEST_JPN_NAME = '検査依頼一覧';
//export const FUNC_EXAM_REQUEST_JPN_NAME = '検査予定一覧';
export const FUNC_EXAM_REQUEST_JPN_NAME = '検査依頼一覧';
//mod FNSI-改修内容「タイトル「検査依頼一覧」→「検査予定一覧」」 江 end
//mod #6447-改修内容「タイトル「検査予定一覧」→「検査依頼一覧」」 Thach end
// 検査依頼
export const FUNC_EXAM_REQUEST_DETAIL_JPN_NAME = '検査依頼';
// 一般撮影検査依頼一覧
export const FUNC_RAD_REQUEST_JPN_NAME = '一般撮影検査依頼一覧';
// 一般撮影検査依頼
export const FUNC_RAD_REQUEST_DETAIL_JPN_NAME = '一般撮影検査依頼';

// 在宅透析患者用 お知らせ画面
export const FUNC_PAT_HOME_DIALYSIS_JPN_NAME = '透析を始める';
// 在宅透析患者用 前体重入力
export const FUNC_PAT_HOME_DIALYSIS_WEIGHT_BEFORE_JPN_NAME = '前体重の入力';
// 在宅透析患者用 透析状況確認
export const FUNC_PAT_HOME_DIALYSIS_STATUS_JPN_NAME = '透析記録';
// 在宅透析患者用 後体重入力
export const FUNC_PAT_HOME_DIALYSIS_WEIGHT_AFTER_JPN_NAME = '後体重の入力';
// 在宅透析指示
export const FUNC_FACILITY_HOME_DIALYSIS_JPN_NAME = '在宅透析指示';

// 掲示板一覧情報
export const FUNC_BBS_INFO_JPN_NAME = '掲示板';
// 掲示板詳細情報
export const FUNC_BBS_DETAILED_INFO_JPN_NAME = '施設イベント詳細';
// 患者カレンダー
export const FUNC_PAT_CALENDAR_JPN_NAME = '患者カレンダー';
export const FUNC_PAT_GROUP_JPN_NAME = "患者グループ";
export const FUNC_PAT_GROUP_EDIT_JPN_NAME = "患者グループ編集";
// 患者イベント
export const FUNC_PAT_EVENT_JPN_NAME = '患者イベント';
// 処方一覧
export const FUNC_PRESCRIPTION_LIST_JPN_NAME = '処方一覧';
export const FUNC_PRESCRIPTION_DETAIL_JPN_NAME = '処方';
// 紹介状
export const FUNC_PAT_INTRO_LETTER_JPN_NAME = '紹介状';

// 患者情報共有
export const FUNC_PAT_INFO_SHARING_JPN_NAME = "患者情報共有";
export const FUNC_PAT_INFO_SHARING_DETAIL_JPN_NAME = "患者情報共有詳細";

// 帳票
export const FUNC_REPORT_MENU_JPN_NAME = "帳票";
// 指示受け・指示承認
export const FUNC_INDICATION_JPN_NAME = "指示受け・指示承認";
export const FUNC_INDICATION_RECEIVE_JPN_NAME = "指示受け";
export const FUNC_INDICATION_APPROVE_JPN_NAME = "指示承認";
// 施設カレンダー
export const FUNC_FACILITY_CALENDAR_JPN_NAME = '施設カレンダー';
// 施設イベント詳細
export const FUNC_FACILITY_CALENDAR_CREATE_JPN_NAME = '施設イベント詳細';
// 施設イベント詳細
export const FUNC_FACILITY_CALENDAR_DETAIL_JPN_NAME = '施設イベント詳細';
export const FUNC_VIEW_LOG_JPN_NAME = 'ログ参照';
// 定期点検
export const FUNC_PERIODIC_INSPECTION_JPN_NAME = "定期点検";
// 日常点検
export const FUNC_DAILY_CHECK_JPN_NAME = "日常点検";
// 水質調査
export const FUNC_WATER_QUALITY_SURVEY_JPN_NAME = "水質管理";
// 患者情報共有
export const FUNC_SHARING_PATIENT_INFORMATION_JPN_NAME = "患者情報共有";
export const FUNC_SHARING_PATIENT_INFORMATION_DETAIL_JPN_NAME = "患者情報共有詳細";
export const FUNC_SHARING_PATIENT_INFORMATION_ACCEPTANCE_LIST_JPN_NAME = "受理一覧";

// 外部連携稼働ビューア
export const FUNC_EXTERNAL_COOP_JPN_NAME = "連携稼働ビューア";
// 利用申込
export const FUNC_USAGE_SUBSCRIPTION_JPN_NAME = "利用申込";
// 申込一覧
export const FUNC_APPLICATION_LIST_JPN_NAME = "申込一覧";
// 処方箋
// mod FNSI-改修内容 処方個別画面に処方一覧画面のリンクを追加する dou start
// export const FUNC_PRESCRIPTION_JPN_NAME = '処方箋';
export const FUNC_PRESCRIPTION_JPN_NAME = '処方一覧';
// mod FNSI-改修内容 処方個別画面に処方一覧画面のリンクを追加する dou end
// --------------------------------------
// 遷移権限に表示する権限リストの定義
// --------------------------------------
// P-Ca9分割グラフ
export const FUNC_SPLIT_GRAPH_JPN_NAME = "P-Ca9分割グラフ";
// #11987 2025.12.22 add メニューバー設定にスケールベッドを追加 TDC伊東 start
// スケールベッド
export const FUNC_SCALE_BED_JPN_NAME = "スケールベッド";
// #11987 2025.12.22 add メニューバー設定にスケールベッドを追加 TDC伊東 end
// add #10371 BVMS/加算情報の権限がないメッセージが表示され遷移できない 20241012 ztc start
// 拡張機能: BVMS
export const FUNC_TREATMENT_RECORD_lIST_BVMS_JPN_NAME = "BVMS";
// 拡張機能: 加算情報
export const FUNC_TREATMENT_RECORD_LIST_ADDITIONINFO_JPN_NAME = "加算情報";
// add #10371 BVMS/加算情報の権限がないメッセージが表示され遷移できない 20241012 ztc end

export const transAuthorityList = [
  // 稼働ビューア
  {
    code: FUNC_OPERATION_VIEWER,
    label: FUNC_OPERATION_VIEWER_JPN_NAME,
  },
  // 生体モニタリング
  {
    code: FUNC_MONITORING,
    label: FUNC_MONITORING_JPN_NAME,
  },
  // デバイスエッジ稼働監視
  {
    code: FUNC_DEVICE_EDGE_OPERATION,
    label: FUNC_DEVICE_EDGE_OPERATION_JPN_NAME,
  },
  // 患者経過総合ビューア
  {
    code: FUNC_PAT_VIEWER,
    label: FUNC_PAT_VIEWER_JPN_NAME,
  },
  // マスタメンテナンス
  {
    code: FUNC_MASTER_MAINTENANCE,
    label: FUNC_MASTER_MAINTENANCE_JPN_NAME,
  },
  // 治療記録
  {
    code: FUNC_TREATMENT_RECORD,
    label: FUNC_TREATMENT_RECORD_JPN_NAME,
  },
  // 患者情報
  {
    code: FUNC_PAT_INFO,
    label: FUNC_PAT_INFO_JPN_NAME,
  },
  // マルチ患者一覧
  {
    code: FUNC_MULTI_PAT_LIST,
    label: FUNC_MULTI_PAT_LIST_JPN_NAME,
  },
  // スケジュール表
  {
    code: FUNC_SCHEDULE_LIST,
    label: FUNC_SCHEDULE_LIST_JPN_NAME,
  },
  // 装置設定(患者情報)
  {
    code: FUNC_PAT_DEVICE_SET,
    label: FUNC_PAT_DEVICE_SET_JPN_NAME,
  },
  // 治療状況リスト
  {
    code: FUNC_STATUS_LIST_MAIN,
    label: FUNC_STATUS_LIST_MAIN_JPN_NAME,
  },
  // 治療状況マップ
  {
    code: FUNC_STATUS_MAP,
    label: FUNC_STATUS_MAP_JPN_NAME,
  },
  // 体重計・条件送信
  {
    code: FUNC_SEND_CONDITION,
    label: FUNC_SEND_CONDITION_JPN_NAME,
  },
  // 体重計測定記録
  {
    code: FUNC_MEASURE_HISTORY,
    label: FUNC_MEASURE_HISTORY_JPN_NAME,
  },
  // チェックリスト
  {
    code: FUNC_CHECK_LIST,
    label: FUNC_CHECK_LIST_JPN_NAME,
  },
  // 観察記録
  {
    code: FUNC_OBSERVE_RECORD,
    label: FUNC_OBSERVE_RECORD_JPN_NAME,
  },
  // 患者新規登録
  {
    code: FUNC_PAT_INFO_CREATE,
    label: FUNC_PAT_INFO_CREATE_JPN_NAME,
  },
  // 検査結果
  {
    code: FUNC_EXAM_RECORD,
    label: FUNC_EXAM_RECORD_JPN_NAME,
  },
  // 帳票
  {
    code: FUNC_REPORT_MENU,
    label: FUNC_REPORT_MENU_JPN_NAME,
  },
  // 掲示板一覧情報
  {
    code: FUNC_BBS_INFO,
    label: FUNC_BBS_INFO_JPN_NAME,
  },
  // 検査依頼
  {
    code: FUNC_EXAM_REQUEST,
    label: FUNC_EXAM_REQUEST_JPN_NAME,
  },
  // 一般撮影検査依頼一覧
  {
    code: FUNC_RAD_REQUEST,
    label: FUNC_RAD_REQUEST_JPN_NAME,
  },
  // 患者グループ
  {
    code: FUNC_PAT_GROUP,
    label: FUNC_PAT_GROUP_JPN_NAME
  },
  // 患者カレンダー
  {
    code: FUNC_PAT_CALENDAR,
    label: FUNC_PAT_CALENDAR_JPN_NAME
  },
  // 在宅透析
  {
    code: FUNC_FACILITY_HOME_DIALYSIS,
    label: FUNC_FACILITY_HOME_DIALYSIS_JPN_NAME
  },
  // 在宅透析患者用
  {
    code: FUNC_PAT_HOME_DIALYSIS,
    label: FUNC_PAT_HOME_DIALYSIS_JPN_NAME
  },
  // 患者イベント
  {
    code: FUNC_PAT_EVENT,
    label: FUNC_PAT_EVENT_JPN_NAME
  },
  // 指示受け・指示承認
  {
    code: FUNC_INDICATION,
    label: FUNC_INDICATION_JPN_NAME
  },
  // 処方箋
  {
    code: FUNC_PRESCRIPTION,
    label: FUNC_PRESCRIPTION_JPN_NAME
  },
  // 紹介状
  {
    code: FUNC_PAT_INTRO_LETTER,
    label: FUNC_PAT_INTRO_LETTER_JPN_NAME
  },
  // 外部連携稼働ビューア
  {
    code: FUNC_EXTERNAL_COOP,
    label: FUNC_EXTERNAL_COOP_JPN_NAME
  },
  // 水質調査
  {
    code: FUNC_WATER_QUALITY_SURVEY,
    label: FUNC_WATER_QUALITY_SURVEY_JPN_NAME
  },
  // 定期点検
  {
    code: FUNC_PERIODIC_INSPECTION,
    label: FUNC_PERIODIC_INSPECTION_JPN_NAME
  },
  // 非常点検
  {
    code: FUNC_DAILY_CHECK,
    label: FUNC_DAILY_CHECK_JPN_NAME
  },
  //　ログ参照
  {
    code: FUNC_VIEW_LOG,
    label: FUNC_VIEW_LOG_JPN_NAME
  },
  //患者情報共有
  {
    code: FUNC_SHARING_PATIENT_INFORMATION,
    label: FUNC_SHARING_PATIENT_INFORMATION_JPN_NAME
  },
  // 基本カレンダー
  {
    code: FUNC_FACILITY_CALENDAR,
    label: FUNC_FACILITY_CALENDAR_JPN_NAME
  },
  // 申込一覧
  {
    code: FUNC_APPLICATION_LIST,
    label: FUNC_APPLICATION_LIST_JPN_NAME
  },
  // P-Ca9分割グラフ
  {
    code: FUNC_SPLIT_GRAPH,
    label: FUNC_SPLIT_GRAPH_JPN_NAME
  },
  // #11987 2025.12.22 add メニューバー設定にスケールベッドを追加 TDC伊東 start
  // スケールベッド
  {
    code: FUNC_SCALE_BED,
    label: FUNC_SCALE_BED_JPN_NAME
  },
  // #11987 2025.12.22 add メニューバー設定にスケールベッドを追加 TDC伊東 end
  // add #10371 BVMS/加算情報の権限がないメッセージが表示され遷移できない 20241012 ztc start
  // 拡張機能: 穿刺返血大画面表示
  {
    code: FUNC_STATUS_LIST_LARGEDISP,
    label: FUNC_STATUS_LIST_LARGEDISP_JPN_NAME
  },
  // 拡張機能: BVMS
  {
    code: FUNC_TREATMENT_RECORD_lIST_BVMS,
    label: FUNC_TREATMENT_RECORD_lIST_BVMS_JPN_NAME
  },
  // 拡張機能: 加算情報
  {
    code: FUNC_TREATMENT_RECORD_LIST_ADDITIONINFO,
    label: FUNC_TREATMENT_RECORD_LIST_ADDITIONINFO_JPN_NAME
  },
  // add #10371 BVMS/加算情報の権限がないメッセージが表示され遷移できない 20241012 ztc end
];

/* add by chamaojia 2023-08-21 [9272] Map定数の追加  --start */
// 患者が選択され、メニュー切り替え機能の詳細ページにジャンプする必要があります
export const existsDetailPageRouter = new Map([
    // 検査結果
    [FUNC_EXAM_RECORD, "exam-record-detail"]
]);
/* add by chamaojia 2023-08-21 [9272] Map定数の追加  --end */
