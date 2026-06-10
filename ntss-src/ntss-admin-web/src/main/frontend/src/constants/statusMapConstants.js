/* 治療状況マップ */
// --------------------------------------
// 装置の工程
// --------------------------------------
export const PROCESS_STATE = {
    // プリセット(01)
    PRESET: "01",
    // 洗浄(02)
    SENJYOU: "02",
    // 酸洗(03)
    SANSEN: "03",
    // 消毒(04)
    SYOUDOKU: "04",
    // 滞留(05)
    TAIRYUU: "05",
    // 液置換(06)
    EKITIKAN: "06",
    // 準備改修(07)
    JUNBIKAISYUU: "07",
    // ガスパージ(08)
    GASS_PURGE: "08",
    // 排液(09)
    HAIEKI: "09",
    // 停止(10)
    TEISI: "10",
    // 運転(11)
    UNTEN: "11",
    // 異常(99)
    IJYOU: "99"
};

// --------------------------------------
// 工程マーカーの色指定
// --------------------------------------
export const MARKER_COLOR = {
    // 白
    MARKER_WHITE: "#FFFF",
    // 水色
    MARKER_BLUE: "#5EFF",
    // 緑
    MARKER_GREEN: "#0F0F",
    // グレー
    MARKER_GRAY: "#AAAF"
};

// --------------------------------------
// 通信不良有無
// --------------------------------------
// 通信不良あり
export const COMM_ERROR = 1;

// --------------------------------------
// 治療状況
// --------------------------------------
export const DIALISYS_STATE = {
    // 条件送信前(0)
    BEFORE_SEND_CONDITION: "0",
    // 条件送信済(1)
    AFTER_SEND_CONDITION: "1",
    // 条件送信確認済み(2)
    CONFIRMED_SEND_CONDITION: "2",
    // 治療中(3)
    DURING_TREATMENT: "3",
    // 排液済(4)
    AFTER_DRAINAGE: "4",
    // 後体重測定済み(実績未確定)(5)
    AFTER_WEIGHT_MEASURING: "5",
    // 後体重確認済み(過去実績)(6)
    CONFIRMED_WEIGHT_MEASURING: "6"
};

/**
 * 装置エントリー状態
 */
export const MACHINE_ENTRY_STATE = {
  // 未エントリー(空きベッド)
  NON_PATIENT: -1,
  // 治療済み
  FINISH_PATIENT: 0,
  // 次患者
  NEXT_PATIENT: 1,
  // 現患者
  NOW_PATIENT: 2
};

/**
 * 警報報知 区別
 */
export const ALERT_TYPES = {
  WARN: "warn",
  INFO: "info",
  NONE: ""
};

/**
 * 施設設定マスタNo.140 治療状況マップ＞治療状況のインジケータ表示設定の項目対応Map
 */
export const INDICATOR_VALUE_TREATMENT_MAP = {
  koutei: "0",
  keihou: "1",
  indChange: "2"
};

/**
 * 施設設定マスタNo.141 治療状況マップ＞スケジュールのインジケータ表示設定の項目対応Map
 */
export const INDICATOR_VALUE_SCHEDULE_MAP = {
  koutei: "0",
  inOut: "1",
  infection: "2",
  va: "3",
  treatment: "4",
  patEvent: "5",
  examRequest: "6",
  radRequest: "7"
};