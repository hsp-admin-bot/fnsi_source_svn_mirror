package jp.co.nikkiso.ntss.admin_web.service.utils;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.time.Clock;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.Date;
import java.util.TimeZone;

/**
 * 日時操作のユーティリティクラス.
 */
public class DateTimeUtils {

  /* del by chamaojia 2026-05-06 [10959] システム内でstatic変数を使っている箇所の洗い出し --start */
  // /**
  //  * Clock.
  //  */
  // private static Clock clock = Clock.systemUTC();
  /* del by chamaojia 2026-05-06 [10959] システム内でstatic変数を使っている箇所の洗い出し --end */

  /**
   * YYYYMMDDのフォーマット.
   */
  private static final String FORMAT_YYYYMMDD = "uuuuMMdd";

  /**
   * 基準日から指定日数分過去の日付を取得.
   *
   * @param baseDate 基準日
   * @param days 指定日数
   * @return 指定日数分過去の日付文字列
   */
  public static String getPastDateWithDays(String baseDate, int days) {
    // 基準日を日付型に変換
    LocalDate pastDate = LocalDate.parse(baseDate, DateTimeFormatter.ofPattern(FORMAT_YYYYMMDD));
    // 指定日数分過去の日付を計算
    pastDate = pastDate.minusDays(days);
    return pastDate.format(DateTimeFormatter.ofPattern("uuuuMMdd")).toString();
  }

  /**
   * 基準日から指定週分、過去の日付を取得.
   *
   * @param baseDate 基準日
   * @param months 指定週数
   * @return 指定週分過去の日付文字列
   */
  public static String getPastDateWithWeeks(String baseDate, int weeks) {
    // 基準日を日付型に変換
    LocalDate pastDate = LocalDate.parse(baseDate, DateTimeFormatter.ofPattern(FORMAT_YYYYMMDD));
    // 指定月数分過去の日付を計算
    pastDate = pastDate.minusWeeks(weeks);
    return pastDate.format(DateTimeFormatter.ofPattern("uuuuMMdd")).toString();
  }

  /**
   * システム日付を"YYYYMMDD"形式で取得.
   *
   * @return システム日付文字列
   */
  public static String getSysDate() {
   /* upd by chamaojia 2026-05-06 [10959] システム内でstatic変数を使っている箇所の洗い出し --start */
   // return LocalDate.now(clock).format(DateTimeFormatter.ofPattern(FORMAT_YYYYMMDD));
   return LocalDate.now(Clock.systemUTC()).format(DateTimeFormatter.ofPattern(FORMAT_YYYYMMDD));
   /* upd by chamaojia 2026-05-06 [10959] システム内でstatic変数を使っている箇所の洗い出し --end */
  }

  /* del by chamaojia 2026-05-06 [10959] システム内でstatic変数を使っている箇所の洗い出し --start */
//  /**
//   * Clockを切り替える.
//   * @param newClock 新しいClock
//   */
//  public static void setClock(Clock newClock) {
//    clock = newClock;
//  }
  /* del by chamaojia 2026-05-06 [10959] システム内でstatic変数を使っている箇所の洗い出し --end */

  /**
   * ISO8601形式の日付文字列からDateを取得する。
   * @param dateString ISO8601形式の日付文字列
   * @return Date
   */
  public static Date dateStringToDate_iso8601(String dateString) {
    Date date;
    if(dateString != null && !dateString.equals("null")) {
      // ISO8601形式のフォーマット
      SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSXXX");
      try {
        date = sdf.parse(dateString);
      } catch (ParseException e) {
        // タイムゾーンにコロンがないフォーマットでリトライ
        SimpleDateFormat sdf_noColonInTimeZone = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSZ");
        try {
          date = sdf_noColonInTimeZone.parse(dateString);
        } catch (ParseException e2) {
         // ミリ秒なしフォーマットでリトライ
          SimpleDateFormat sdf_noMiliSec = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ssXXX");
          try {
            date = sdf_noMiliSec.parse(dateString);
          } catch (ParseException e1) {
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang start
//      e1.printStackTrace();
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang end
            date = null;
          }
        }
      }
    } else {
      // 引数がnullのときnullを返す
      date = null;
    }

    return date;
  }

  /**
   * DateからISO8601形式の日付文字列を取得する。
   * @param date
   * @return ISO8601形式の日付文字列
   */
  public static String getDateString_iso8601(Date date) {
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSXXX");
    sdf.setTimeZone(TimeZone.getTimeZone("JST"));
    String dateString = sdf.format(date);
    return dateString;
  }

  /**
   * 開始日から終了日までの日数を取得する.
   *
   * @param dateFromString 開始日(yyyyMMdd)
   * @param dateToString 終了日(yyyyMMdd)
   * @return 開始日から終了日までの日数
   */
  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
  public static Long getDateDiff(String dateFromString, String dateToString) throws ParseException {
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
    SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd");
    Date dateTo = null;
    Date dateFrom = null;

    // Date型に変換
    try {
      dateFrom = sdf.parse(dateFromString);
      dateTo = sdf.parse(dateToString);
    } catch (java.text.ParseException e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
      throw e;
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end

      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      return null;
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
    }

    // 日数を計算する
    Long dateTimeTo = dateTo.getTime();
    Long dateTimeFrom = dateFrom.getTime();
    Long dayDiff = ( dateTimeTo - dateTimeFrom  ) / (1000 * 60 * 60 * 24 ) + 1;

    return dayDiff;
  }
}
