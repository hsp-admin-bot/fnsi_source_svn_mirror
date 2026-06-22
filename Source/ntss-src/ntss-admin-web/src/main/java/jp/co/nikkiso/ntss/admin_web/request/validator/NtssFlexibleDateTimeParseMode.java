package jp.co.nikkiso.ntss.admin_web.request.validator;

/**
 * {@link NtssFlexibleDateTime} で許容する解釈範囲.
 */
public enum NtssFlexibleDateTimeParseMode {

  /** 日付のみ（時刻なし） */
  DATE_ONLY,

  /** 日付＋時刻 */
  DATE_TIME,

  /** 日付のみおよび日時の両方を許容 */
  ANY
}
