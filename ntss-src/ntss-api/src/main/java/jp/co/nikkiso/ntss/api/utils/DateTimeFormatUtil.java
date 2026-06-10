package jp.co.nikkiso.ntss.api.utils;

import org.springframework.util.StringUtils;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeFormatterBuilder;
import java.time.format.DateTimeParseException;
import java.util.Date;
import java.util.Objects;
import java.util.regex.Pattern;

/**
 * 日時操作のユーティリティクラス.
 * ISO 8601の日付フォーマット変換
 *
 * @since 2024-01-03
 * @author IES Tao.zhou
 */
public class DateTimeFormatUtil {

  /** ISO8601日付書式のパターン */
  static final Pattern ISO_DATE_PATTERN;
  /** ISO8601時刻付き日付書式のパターン */
  static final Pattern ISO_DATE_TIME_PATTERN;
  /** ISO8601タイムゾーン付き日付書式のパターン */
  static final Pattern ISO_DATE_TIME_WITH_TZ_PATTERN;

  /** TimeZoneFormatter :
   * The ISO date-time formatter that formats or parses a date-time with an offset,
   * such as '2011-12-03T10:15:30+09:00'. */
  public static final DateTimeFormatter  ISO_LOCAL_DATE_TIME = new DateTimeFormatterBuilder()
    .append(DateTimeFormatter.ISO_LOCAL_DATE_TIME).appendOffsetId().toFormatter();

  /* 初期化 正規表現 用の変数 */
  static {

    /* 正規表現式-文字列スタート */
    final String REGEXP_START = "^";
    /* 正規表現式-文字列終了 */
    final String REGEXP_END = "$";
    /* 正規表現式-ISO8601日付書式 */
    final String ISO_DATE_FORMAT_REGEXP = "(\\d{4}-[0-1]\\d-[0-3]\\d)";
    /* 正規表現式-ISO8601時刻付き日付書式 */
    final String ISO_TIME_WITH_MS_FORMAT_REGEXP = "("
      + "(([0-1]\\d)|([2][0-4]))"
      + ":[0-5]\\d"
      + ":[0-5]\\d"
      + "(\\.\\d+)?"
      + ")";
    /* 正規表現式-ISO8601タイムゾーン付き日付書式 */
    final String ISO_TIME_ZONE_FORMAT_REGEXP = "("
      + "(([0-1]\\d)|([2][0-4]))"
      + ":[0-5]\\d"
      + ":[0-5]\\d"
      + "(\\.\\d+)?"
      + "([+-][0-1]\\d:(?:00|[0-5]\\d))"
      + ")";
    /* ISO8601日付書式のパターン */
    ISO_DATE_PATTERN = Pattern.compile(
      ISO_DATE_FORMAT_REGEXP
      , Pattern.MULTILINE);
    /* ISO8601時刻付き日付書式のパターン */
    ISO_DATE_TIME_PATTERN = Pattern.compile(
      REGEXP_START
        + ISO_DATE_FORMAT_REGEXP
        + "T"
        + ISO_TIME_WITH_MS_FORMAT_REGEXP
        + REGEXP_END
      , Pattern.MULTILINE);
    /* ISO8601タイムゾーン付き日付書式のパターン */
    ISO_DATE_TIME_WITH_TZ_PATTERN = Pattern.compile(
      REGEXP_START
        + ISO_DATE_FORMAT_REGEXP
        + "T"
        + ISO_TIME_ZONE_FORMAT_REGEXP
        + REGEXP_END
      , Pattern.MULTILINE
    );
  }

  /**
   * 正規表現を用いてパラメータがSO8601日付書式であるがどうかを検証して
   *
   * @param dateStr 検証のパラメータ
   * @return 検証の文字列がISO8601標準日付フォーマットですが？
   */
  public static boolean checkDateFormat(String dateStr) {
    if (StringUtils.hasText(dateStr)) {
      return ISO_DATE_PATTERN.matcher(dateStr).matches();
    }
    return false;
  }

  /**
   * 正規表現を用いてパラメータがSO8601日付書式であるがどうかを検証して
   *
   * @param dateTimeStr 検証のパラメータ
   * @return 検証の文字列がISO8601標準日付()フォーマットですが？
   */
  public static boolean checkDateTimeFormat(String dateTimeStr) {
    if (StringUtils.hasText(dateTimeStr)) {
      return ISO_DATE_TIME_PATTERN.matcher(dateTimeStr).matches();
    }
    return false;
  }

  /**
   * 正規表現を用いてパラメータがSO8601日付書式であるがどうかを検証して
   *
   * @param dateStr 検証のパラメータ
   * @return 検証の文字列がISO8601標準日付フォーマット(TimeZone)ですが？
   */
  public static boolean checkDateTimeWithTZFormat(String dateStr) {
    if (StringUtils.hasText(dateStr)) {
      return ISO_DATE_TIME_WITH_TZ_PATTERN.matcher(dateStr).matches();
    }
    return false;
  }

  /**
   * ISO8601標準日付書式に基づいて文字列を日付に変換する。
   * 変換前に、日付文字列の書式を検証して、非標準の日付文字列は今の時を変換する。
   *
   * @param dateStr 日付文字列
   * @return 指定日付
   */
  public static LocalDateTime parseDateTime(String dateStr) {

    try {
      if (checkDateFormat(dateStr)) {
        // for pattern: 'yyyy-mm-dd'
        return LocalDate.parse(dateStr, DateTimeFormatter.ISO_LOCAL_DATE).atStartOfDay();
      } else if (checkDateTimeFormat(dateStr)) {
        // for pattern: 'yyyy-mm-ddTHH:MM:ss?SSS' (can be with millis_second or not)
        return LocalDateTime.parse(dateStr, DateTimeFormatter.ISO_LOCAL_DATE_TIME);
      } else if (checkDateTimeWithTZFormat(dateStr)) {
        // for pattern: 'yyyy-mm-ddTHH:MM:ss?SSSXXX',the time zone pattern not a 'Z'
        return ZonedDateTime.parse(dateStr, ISO_LOCAL_DATE_TIME).toLocalDateTime();
      } else {
        // try with ISO_DATE_TIME
        return LocalDateTime.parse(dateStr, DateTimeFormatter.ISO_DATE_TIME);
      }
    } catch (DateTimeParseException dtpEx) {
      // if fail to parse localtime, we will return a now time.
      return LocalDateTime.now();
    }
  }

  /**
   * ISO8601標準日付書式に基づいて文字列を日付に変換する。
   * 変換前に、日付文字列の書式を検証して、非標準の日付文字列は今の時を変換する。
   *
   * @param dateStr 日付文字列
   * @return 指定日付
   */
  public static Date parseDateTimeTODate(String dateStr) {
    return Date.from(
        parseDateTime(dateStr)
        .atZone(ZoneId.systemDefault())
        .toInstant()
      );
  }

  /**
   * 指定した日付を文字列を変換(ISO8601)
   *
   * @param dateTime 指定日付
   * @return ISO8601日付書式文字列、指定日付はNULLの時、今の時の文字列を変換。
   */
  public static String formatDateString(LocalDateTime dateTime) {
    return Objects.requireNonNullElseGet(dateTime, LocalDateTime::now)
      .atZone(ZoneId.systemDefault())
      .format(ISO_LOCAL_DATE_TIME);
  }

  /**
   * 指定した日付を文字列を変換(ISO8601)<br />
   * Using the Instant and the timeZone, avoided issues caused by time zone offset.
   *
   * @param date 指定日付
   * @return ISO8601日付書式文字列、指定日付はNULLの時、今の時の文字列を変換。
   */
  public static String formatDateString(Date date) {
    return Objects.requireNonNullElseGet(date, Date::new)
        .toInstant()
        .atZone(ZoneId.systemDefault())
        .format(ISO_LOCAL_DATE_TIME);
  }
}
