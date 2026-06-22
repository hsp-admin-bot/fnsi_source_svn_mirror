// examRequestConstantsと同じ定義内容のものは流用する
export {
  // カレンダー表示用のフラグ
  /** 中止(緑×マーク、透析予約がないときは赤×マーク) */
  CANCEL,
  /** 指示有(緑〇マーク、透析予約がないときは赤〇マーク) */
  SAVED,
  /** 追加(緑〇マーク) */
  ADD,
  /** 追加(透析予約がない日付)(赤〇マーク) */
  ADD_WARNING,

  /** 過去日の場合のテーブルヘッダーのバックグラウンド色コード */
  BACKGROUND_HEADER_PAST_DAY,
  /** 当日の場合のテーブルヘッダーのバックグラウンド色コード */
  BACKGROUND_HEADER_TODAY,
  /** 過去日の場合のテーブルカラムのバックグラウンド色コード */
  BACKGROUND_COLUMN_PAST_DAY,
  /** 患者名行のバックグラウンド色コード */
  BACKGROUND_ROW_PATNAME,
  /** 透析予約がある場合の文字色 */
  FONTCOLOR_HAS_SCHEDULE,
  /** 透析予約がない場合の文字色 */
  FONTCOLOR_HAS_NOT_SCHEDULE,
  /** 放射線検査依頼があるレコードを白背景で塗りつぶす */
  FILLCOLOR_DEFAULT,
  /** 透析予約がある場合のレコードを、締め切り日を過ぎている、又は結果ありの場合に塗りつぶす */
  FILLCOLOR_HAS_SCHEDULE,
  /** 透析予約がない場合のレコードを、締め切り日を過ぎている、又は結果ありの場合に塗りつぶす */
  FILLCOLOR_HAS_NOT_SCHEDULE,

  /** 指定日1回分 */
  SELECT_DATE_ONCE,
  /** 月1:第1週 */
  FIRST_WEEK,
  /** 月1:第2週 */
  SECOND_WEEK,
  /** 月1:第3週 */
  THIRD_WEEK,
  /** 月1:第4週 */
  FOURTH_WEEK,
  /** 月2:第1週、第3週 */
  FIRST_WEEK_AND_THIRD_WEEK,
  /** 月2:第2週、第4週 */
  SECOND_WEEK_AND_FOURTH_WEEK,
  /** 年間複数日 */
  MULTI_DAYS_OF_YEAR,
  /** 隔週 */
  EVERY_OTHER_WEEK,

  /** 検査間隔の値 */
  IntervalValues,

  /** 検査間隔リスト */
  INTERVAL_LIST,

  /** 検査間隔の選択肢 (定義はDB設計書 pat_rad_pattern.rad_pattern の備考に記載) */
  SetIntervalList,
  /** 曜日の選択肢 */
  IndWeeks,
} from "@/constants/examRequestConstants";
