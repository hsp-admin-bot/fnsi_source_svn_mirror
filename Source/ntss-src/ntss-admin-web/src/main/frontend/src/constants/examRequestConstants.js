// カレンダー表示用のフラグ
/** 中止(緑×マーク、透析予約がないときは赤×マーク) */
export const CANCEL = 0;
/** 指示有(緑〇マーク、透析予約がないときは赤〇マーク) */
export const SAVED = 1;
/** 追加(緑〇マーク) */
export const ADD = 2;
/** 追加(透析予約がない日付)(赤〇マーク) */
export const ADD_WARNING = 3;

/** 過去日の場合のテーブルヘッダーのバックグラウンド色コード */
export const BACKGROUND_HEADER_PAST_DAY = "#808080";
/** 当日の場合のテーブルヘッダーのバックグラウンド色コード */
export const BACKGROUND_HEADER_TODAY = "#2ca06f";
/** 過去日の場合のテーブルカラムのバックグラウンド色コード */
export const BACKGROUND_COLUMN_PAST_DAY = "#ededed";
/** 患者名行のバックグラウンド色コード */
export const BACKGROUND_ROW_PATNAME = "#777777";
/** 透析予約がある場合の文字色 */
export const FONTCOLOR_HAS_SCHEDULE = "#42CB92";
/** 透析予約がない場合の文字色 */
export const FONTCOLOR_HAS_NOT_SCHEDULE = "#ff6666";
/** 検査依頼があるレコードを白背景で塗りつぶす */
export const FILLCOLOR_DEFAULT = "#fafafa";
/** 透析予約がある場合のレコードを、締め切り日を過ぎている、又は結果ありの場合に塗りつぶす */
export const FILLCOLOR_HAS_SCHEDULE = "#2ca06f";
/** 透析予約がない場合のレコードを、締め切り日を過ぎている、又は結果ありの場合に塗りつぶす */
export const FILLCOLOR_HAS_NOT_SCHEDULE = "#ff85ac";

/** 指定日1回分 */
export const SELECT_DATE_ONCE = 1;
/** 月1:第1週 */
export const FIRST_WEEK = 2;
/** 月1:第2週 */
export const SECOND_WEEK = 3;
/** 月1:第3週 */
export const THIRD_WEEK = 4;
/** 月1:第4週 */
export const FOURTH_WEEK = 5;
/** 月2:第1週、第3週 */
export const FIRST_WEEK_AND_THIRD_WEEK = 6;
/** 月2:第2週、第4週 */
export const SECOND_WEEK_AND_FOURTH_WEEK = 7;
/** 年間複数日 */
export const MULTI_DAYS_OF_YEAR = 8;
/** 隔週 */
export const EVERY_OTHER_WEEK = 9;

/** 検査間隔の値 */
export const IntervalValues = Object.freeze({
  /** 指定日1回分 */
  SelectDateOnce: SELECT_DATE_ONCE,
  /** 月1:第1週 */
  FirstWeek: FIRST_WEEK,
  /** 月1:第2週 */
  SecondWeek: SECOND_WEEK,
  /** 月1:第3週 */
  ThirdWeek: THIRD_WEEK,
  /** 月1:第4週 */
  FourthWeek: FOURTH_WEEK,
  /** 月2:第1週、第3週 */
  FirstAndThirdWeek: FIRST_WEEK_AND_THIRD_WEEK,
  /** 月2:第2週、第4週 */
  SecondAndFourthWeek: SECOND_WEEK_AND_FOURTH_WEEK,
  /** 年間複数日 */
  MultiDaysOfYear: MULTI_DAYS_OF_YEAR,
  /** 隔週 */
  EveryOtherWeek: EVERY_OTHER_WEEK,
});

/** 検査間隔リスト */
export const INTERVAL_LIST = Object.freeze([
  {
    value: SELECT_DATE_ONCE,
    name: "指定日1回分"
  },
  {
    value: FIRST_WEEK,
    name: "月1:第1週"
  },
  {
    value: SECOND_WEEK,
    name: "月1:第2週"
  },
  {
    value: THIRD_WEEK,
    name: "月1:第3週"
  },
  {
    value: FOURTH_WEEK,
    name: "月1:第4週"
  },
  {
    value: FIRST_WEEK_AND_THIRD_WEEK,
    name: "月2:第1週、第3週"
  },
  {
    value: SECOND_WEEK_AND_FOURTH_WEEK,
    name: "月2:第2週、第4週"
  },
  {
    value: MULTI_DAYS_OF_YEAR,
    name: "年間複数日"
  },
  {
    value: EVERY_OTHER_WEEK,
    name: "隔週"
  },
]);

/** 検査間隔の選択肢 (定義はDB設計書 pat_exam_pattern.exam_pattern の備考に記載) */
export const SetIntervalList = Object.freeze([
  { value: SELECT_DATE_ONCE, name: "指定日1回分" },
  { value: FIRST_WEEK, name: "月1：第1週" },
  { value: SECOND_WEEK, name: "月1：第2週" },
  { value: THIRD_WEEK, name: "月1：第3週" },
  { value: FOURTH_WEEK, name: "月1：第4週" },
  { value: FIRST_WEEK_AND_THIRD_WEEK, name: "月2：第1週、第3週" },
  { value: SECOND_WEEK_AND_FOURTH_WEEK, name: "月2：第2週、第4週" },
  { value: MULTI_DAYS_OF_YEAR, name: "年間複数日" },
  { value: EVERY_OTHER_WEEK, name: "隔週" },
]);
/** 曜日の選択肢 */
export const IndWeeks = Object.freeze([
  { value: 1, text: "月" },
  { value: 2, text: "火" },
  { value: 3, text: "水" },
  { value: 4, text: "木" },
  { value: 5, text: "金" },
  { value: 6, text: "土" },
  { value: 7, text: "日" },
]);

/** 検査区分の省略表示文字列 */
export const RegOrderClassShortText = Object.freeze({
  "1": "(前)",
  "2": "(後)",
  "0": "(他)",
});

/** 検査区分の表示文字列セット */
export const RegOrderClassTextSet = Object.freeze([
  {value: "1", text: "透析前", shortText: "(前)"},
  {value: "2", text: "透析後", shortText: "(後)"},
  {value: "0", text: "その他", shortText: "(他)"},
]);
