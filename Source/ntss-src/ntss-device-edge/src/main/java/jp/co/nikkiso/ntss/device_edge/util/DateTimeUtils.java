package jp.co.nikkiso.ntss.device_edge.util;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Date;
import java.util.TimeZone;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * 日時操作のユーティリティクラス.
 */
public class DateTimeUtils {

  /* del by chamaojia 2026-05-07 [10959] システム内でstatic変数を使っている箇所の洗い出し --start */
  // /**
  //  * Clock.
  //  */
  // private static Clock clock = Clock.systemUTC();
  /* del by chamaojia 2026-05-07 [10959] システム内でstatic変数を使っている箇所の洗い出し --end */

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

  /* del by chamaojia 2026-05-07 [10959] システム内でstatic変数を使っている箇所の洗い出し --start */
  // /**
  //  * システム日付を"YYYYMMDD"形式で取得.
  //  *
  //  * @return システム日付文字列
  //  */
  // public static String getSysDate() {
  //  return LocalDate.now(clock).format(DateTimeFormatter.ofPattern(FORMAT_YYYYMMDD));
  // }

  // /**
  //  * Clockを切り替える.
  //  * @param newClock 新しいClock
  //  */
  // public static void setClock(Clock newClock) {
  //   clock = newClock;
  // }
  /* del by chamaojia 2026-05-07 [10959] システム内でstatic変数を使っている箇所の洗い出し --end */

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
//        e1.printStackTrace();
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
    if (date == null) {
      return null;
    }
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSXXX");
    sdf.setTimeZone(TimeZone.getTimeZone("JST"));
    String dateString = sdf.format(date);
    return dateString;
  }

  /**
   * ISO8601日付のをLocalDateTimeに変換
   * 入力日付のフォーマットは、yyyy-MM-dd'T'HH:mm:ss.SSSXXX
   * @param s  日付文字列
   * @return LocalDateTime
   */
  public static LocalDateTime convertLocalDateTimeIso8601(String s)
  {

    final String format = "yyyy-MM-dd'T'HH:mm:ssXXX" ;
    final String formatLong = "yyyy-MM-dd'T'HH:mm:ss.SSSXXX" ;

    try {
      //時間を変換
      String date1 = s;
      Pattern pattern = Pattern.compile("T");
      Matcher matcher1 = pattern.matcher(date1);

      String formatDate1 = matcher1.find() ? date1 : date1 + "T00:00:00.000+09:00";

      DateTimeFormatter f1 = DateTimeFormatter.ofPattern(format);
      if (formatDate1.length() > 25) {
        f1 = DateTimeFormatter.ofPattern(formatLong);
      }

      return LocalDateTime.parse(formatDate1, f1);

    }
    catch(Exception e)
    {
      return null;
    }
  }

  /**
   * ISO8601日付の比較
   * 入力日付のフォーマットは、yyyy-MM-dd'T'HH:mm:sssXXX
   * @param s1  比較1
   * @param s2  比較2
   * @return
   *   s1 == s2 の場合は値0
   *   s1 <  s2 の場合は0より小さい値
   *   s1 >  s2 の場合は0より大きい値
   */
  public static int compareDateLong(String s1,String s2)
  {
    String targetDate1 = s1 ;
    String targetDate2 = s2 ;

    Pattern pattern = Pattern.compile("T");
    Matcher matcher1 = pattern.matcher(targetDate1);
    Matcher matcher2 = pattern.matcher(targetDate2);

    if (!matcher1.find()) {
      targetDate1 += "T00:00:00.000+09:00";
    }
    if (!matcher2.find()) {
      targetDate2 += "T00:00:00.000+09:00";
    }

    Date A = DateTimeUtils.dateStringToDate_iso8601(targetDate1);
    Date B = DateTimeUtils.dateStringToDate_iso8601(targetDate2);

    return B.compareTo(A);
  }

}
