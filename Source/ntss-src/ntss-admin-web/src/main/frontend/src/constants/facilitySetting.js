/* facilitySetting */
// --------------------------------------
// 施設設定番号(FacilitySettingNo)
// --------------------------------------

// タイムアウト時間(分)
export const TIME_OUT_MINUTES = "1003";

// 透析困難リセット機能
export const DIALYSIS_DIFFICULTY_RESET = "1004";

// カード作成機能
export const DISP_CREATE_CARD = "1005";

// 検査予定変更機能
export const EXAM_SCHEDULE_CHANGE = "1007";

// 放射線検査予定変更機能
export const RAD_SCHEDULE_CHANGE = "1008";

// 検査結果取込 項目コード出力先設定
export const EXAM_RESULT_CAPTURE_ITEM_CD = "1009";

// 検査依頼変更締切り日数
export const EXAM_DEADLINE_DATE_COUNT = "1011";

// 検査依頼変更締切り時間
export const EXAM_DEADLINE_TIME_COUNT = "1012";

// 放射線検査依頼変更締切り日数
export const RAD_DEADLINE_DATE_COUNT = "1013";

// 放射線検査依頼変更締切り時間
export const RAD_DEADLINE_TIME_COUNT = "1014";

// 検査依頼変更締切り有無
export const EXAM_DEADLINE = "1015";

// 放射線検査依頼変更締切り有無
export const RAD_DEADLINE = "1016";

// 患者性別無し時機能
export const PAT_SEX_NON = "1017";

// 指示変更カテゴリID
export const CHANGE_IND_CATEGORY = "1021";

// 受付・承認単位
export const INDICATION_RECEIVE_APPROVE_UNIT = "1023";

// デフォルト選択医師設定
export const DEFAULT_SEL_DOCTOR = "1025";

// デフォルト手技設定
export const DEFAULT_PROCEDURE = "1028";

// デフォルト投与タイミング設定
export const DEFAULT_MEDICATE_TIMING = "1029";

// パスワードポリシー適用レベル
export const PASSWORD_POLICY = "1036";

// パスワード文字数
export const NUM_OF_PASSWORD = "1037";

// 指示受け１表示設定
export const INDICATION_RECEIVE_1 = "1042";

// 指示受け２表示設定
export const INDICATION_RECEIVE_2 = "1043";

// 指示承認１表示設定
export const INDICATION_APPROVE_1 = "1044";

// 指示承認２表示設定
export const INDICATION_APPROVE_2 = "1045";

// 同時サインイン設定
export const SYNC_SIGN_IN = "1048";

// 指示承認設定
export const INSTRUCTION_APPROVAL_SETTING = "1050";

// パスワード有効期間
export const PASSWORD_VALIDITY_PERIOD = "1059";

// 権限変更時サインアウト設定
export const PERMISSION_CHANGE_SIGNOUT = "1064";

// 担当者1未登録チェック
export const DISP_CHARGE1_NOTSET = "1066";

// 担当者2未登録チェック
export const DISP_CHARGE2_NOTSET = "1067";

// #10290 2024.03.08 add 施設設定により前体重許容範囲チェックを実施可否を決定する TDC米沢 start
// 前体重許容範囲チェック実施有無
export const IS_BEFORE_WEIGHT_TOLERANCE_RANGE_CHECK = "1068";
// #10290 2024.03.08 add 施設設定により前体重許容範囲チェックを実施可否を決定する TDC米沢 end

// 愁訴処置の投与薬剤情報表示有無
export const COMPLAINT_MEDICINE_INFO = "1070";

// 治療状況マップ＞治療状況のインジケータ表示設定
export const STATUS_MAP_TREATMENT_INDICATOR = "1071";

// 治療状況マップ＞スケジュールのインジケータ表示設定
export const STATUS_MAP_SCHEDULE_INDICATOR = "1072";

// add #12462 患者情報共有 ligh start
// 患者情報共有
export const SHR_PAT_INFO = "4001";
// add #12462 患者情報共有 ligh end


// URLサインイン設定
export const URL_SIGNIN = "2001";

// URLサインイン秘密鍵
export const URL_SIGNIN_SECRETKEY = "2002";

//低パスワードレベル
export const pwdLvLow = /^(?=.*[0-9])(?=.*[a-zA-Z]).{0,16}$/;

//パスワードレベル標準
export const pwdLvNormal =
  /^((?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])|(?=.*[a-z])(?=.*[A-Z])(?=.*\W)|(?=.*[a-z])(?=.*[0-9])(?=.*\W)|(?=.*[A-Z])(?=.*[0-9])(?=.*\W)).{0,16}$/;

//高いパスワードレベル
export const pwdLvHigh = /^(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*\W).{0,16}$/;

// add FNSI-体重測定・条件送信 「クール設定／ベッド設定」ボタンは条件により非活性 鄭博尹 start
// 体重計モード・スケジュール変更設定
export const WEIGHMODE_SCHEDULE_SETTING = "3000";
// add FNSI-体重測定・条件送信 「クール設定／ベッド設定」ボタンは条件により非活性 鄭博尹 end

// add FNSI-治療状況自動更新間隔 付 start
// 治療状況自動更新間隔変更設定
export const STATUS_AUTO_SETTING = "3001";
// add FNSI-治療状況自動更新間隔 付 end

// add FNSI-患者経過総合ビューア 426 姜 start
// 患者イベント変更設定
export const FACILITY_NO_SETTING = "3005";
// add FNSI-患者経過総合ビューア 426 姜 end

// add FNSI-分類不一致判断の追加 徐 start
export const CHK_INDCONDINFO_FLG = "3009";
export const CHK_MSGDEL_FLG = "3018";
export const CHK_MSGOVERDUE_FLG = "3019";
// add FNSI-分類不一致判断の追加 徐 end

// add 装置設定デフォルトマスタ DP=Qd+Qs(補液速度加算)、表示非表示設定 start
// DP=Qd+Qs(補液速度加算)表示切替え
export const REPLENISHER_QDQS_SETTING = "3010";
// add 装置設定デフォルトマスタ DP=Qd+Qs(補液速度加算)、表示非表示設定 end

//補液計算-補液比率有効化設定
export const REPLENISHER_CALCULATION_SETTING = "3113";

//補液計算-濾過率から算出有効化設定
export const REPLENISHER_FILTRATION_SETTING = "3114";

// add FNSI-FutreNetWeb+SI課題管理No.4705 李 start
// 抗凝固剤設定のデフォルト指定
export const ANTICOAGULANT_DEFAULT_SETTING = "3115";

// 抗凝固剤設定の自動計算指定
export const ANTICOAGULANT_AUTO_SETTING = "3116";
// add FNSI-FutreNetWeb+SI課題管理No.4705 李 end

// 体重計モード測定記録ボタン表示/非表示を設定
export const WEIGHT_MODE_MEASURE_HISTORY_BUTTON_DISPLAY = "3139";

// --------------------------------------
// 初期値
// --------------------------------------
// 透析困難リセット機能
export const DEFAULT_DIALYSIS_DIFFICULTY_RESET = 0;

// 112_検査結果_前回定義期間
export const LAST_DEFINED_PERIOD = "3012";

// 治療経過表
export const TREATMENT_PROGRESS_CHART = "3117";

// 治療経過表（手書き）
export const TREATMENT_PROGRESS_CHART_HANDWRITING = "3118";

// 日常点検記録簿
export const DAILY_INSPECTION_RECORD_BOOK = "3119";

// 定期点検（記録簿・交換部品記録簿）
export const PERIODIC_INSPECTION_RECORD_BOOK = "3120";

// 検査結果画面表示順
export const EXAM_RESULT_DISP_ORDER = "3122";

// 測定患者選択画面の車いすマスタ編集
export const MST_WEIGHT_EDIT_WITH_PAT_SELECTION = "3123";

// 治療状況マップ画面の自動更新サインアウト
export const STATUS_MAP_FORCE_SIGNOUT = "3124";

// 治療状況リスト大画面の自動更新サインアウト
export const STATUS_LARGE_FORCE_SIGNOUT = "3125";

// 治療状況リスト画面の自動更新サインアウト
export const STATUS_LIST_FORCE_SIGNOUT = "3126";

// チェックリスト画面の自動更新サインアウト
export const CHECK_LIST_FORCE_SIGNOUT = "3127";

// 遠隔監視画面の自動更新サインアウト
export const OPERATION_VIEWER_FORCE_SIGNOUT = "3128";

// 治療状況（大画面表示）自動更新間隔変更設定
export const STATUS_LARGE_AUTO_SETTING = "3129";

// 遠隔監視自動更新間隔変更設定
export const OPERATION_VIEWER_AUTO_SETTING = "3130";

// シェーマのグリッド設定
export const GRID_SIZE_INFO = "3132";

// 機能別患者リスト表示設定
export const FACILITY_PAT_SEARCH_DISP_SETTING = "3140";

// サインインIF表示設定
export const IS_SIGNIN_DISP = "3144";

// スケールベッド更新間隔
export const SCALE_BED_AUTO_SETTING = "3145";

// --------------------------------------
// ON/OFFトグル項目の設定値
// --------------------------------------
// OFF
export const TOGGLE_VALUE_OFF = 0;
// ON
export const TOGGLE_VALUE_ON = 1;
