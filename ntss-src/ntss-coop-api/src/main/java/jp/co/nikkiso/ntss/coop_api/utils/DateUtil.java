package jp.co.nikkiso.ntss.coop_api.utils;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.time.format.ResolverStyle;
import java.util.Calendar;
import java.util.Date;
import java.util.Locale;
import java.util.Map;

import org.apache.commons.collections4.MapUtils;
import org.springframework.util.StringUtils;
import jp.co.nikkiso.ntss.core.exception.NtssException;
import lombok.AllArgsConstructor;
import lombok.Getter;

/**
 * 日時の文字列表現に関連する処理をまとめたユーティリティクラス。
 */
public class DateUtil {

  /** 日付フォーマット定義(YYYYMMDD) */
  private final static String FORMAT_YYYYMMDD = JournalConvertConstants.DATE_FORMAT_YYYYMMDD;
  /** 日付フォーマット定義(元号YYMMDD) */
  private final static String FORMAT_GYYMMDD = "GyyMMdd";
  /**
   * 日付チェック対象外の日付形式
   * ※死亡日の0000-00-00を想定
   *  */
  private final static String NO_CHECK_DATE = JournalConvertConstants.DIE_DATE_ALIVE;

  /** 新元号 定義 */
  @Getter
  @AllArgsConstructor
  public enum NewJapaneseEra {
    /** 令和(R, 2019.05.01) */
    REIWA("R", LocalDate.of(2019, 5, 1)),
    /** 未定義(x, null) */
    UNDEFINED("x", null);

    // フィールド変数
    private final String key;       // 元号の頭文字
    private final LocalDate since;  // 開始日

    /**
     * フィールド値に一致する元号の取得
     *
     * @param key 元号の文字
     * @return 元号
     * */
    public static NewJapaneseEra getNewJapaneseEra(String key) {
      for(NewJapaneseEra era : values()) {
        if (era.key.equals(key)) {
          return era;
        }
      }
      return UNDEFINED;
    }
  }

  /**
   * マップの中の日付文字列をTimestamp変換用の形式に変換する。
   *
   * @param map マップ
   * @param keyName 日付文字列を持つキー名
   */
  public static void convertDateStrToTimestamp(Map<String, Object> map, String keyName) {

    if (MapUtils.isEmpty(map)) {
      return;
    }

    String v = (String) map.get(keyName);
    if (StringUtils.isEmpty(v)) {
      return;
    }

    map.put(keyName, convertDateStr(v));
  }

  /**
   * 日付文字列をTimestamp変換用の形式に変換する。
   *
   * @param s 日付文字列
   * @return Timestamp変換用の文字列
   */
  public static String convertDateStr(String s) {
    if (s == null) {
      return null;
    }
    return s + JournalConvertConstants.MIDNIGHT;
  }

  /**
   * 日付文字列の形式を判定し、YYYY-MM-DDの形式へ変換
   *
   * @param date 変換対象の日付文字列
   *  YYYY/MM/DD, YYYY-MM-DD, YYYYMMDD, 元号0YYMMDDを想定
   * */
  public static String convertDateToStringFormat(String date) {

    // 変換対象外
    if (NO_CHECK_DATE.equals(date) || NO_CHECK_DATE.replace("-", "").equals(date)) {
      // 特殊な日付形式の場合は、指定形式で返す
      return NO_CHECK_DATE;
    }
    if (StringUtils.isEmpty(date) || date.length() < 8 || date.length() > 10) {
      return null;
    }

    Date convDate = null;
    // ---- 西暦 ----
    // 形式がyyyyMMdd, yyyy/MM/dd,yyyy-MM-ddの場合
    String yyyymmdd = date.replaceAll("/", "").replaceAll("-", "");
    convDate = parseDateFormat(FORMAT_YYYYMMDD, yyyymmdd);

    // ---- 和暦 ----
    if (convDate == null) {
      // 元号0YYMMDD → 元号YYMMDDに変換
      String gyymmdd = date.substring(0,1).concat(date.substring(2));
      // 和暦に変換
      convDate = parseDateFormat(FORMAT_GYYMMDD, gyymmdd);
    }
    // 既存機能で変換できない和暦の場合(新元号)
    if (convDate == null) {
      // 元号の定義に変換
      NewJapaneseEra era = NewJapaneseEra.getNewJapaneseEra(date.substring(0,1));
      switch (era) {
      case REIWA: // 令和
        // yyyymmddの形式にする
        yyyymmdd = convertNewJpEraDate(era, date);
        convDate = parseDateFormat(FORMAT_YYYYMMDD, yyyymmdd);
        break;
        default:
          convDate = null;
          break;
      }
    }

    if (convDate == null) {
      // 日付の変換ができない場合
      String error = String.format("日付の変換に失敗しました。date:[%s]", date);
      throw new NtssException(error);
    }

    // 日付チェックの形式に変換
    SimpleDateFormat sdf = new SimpleDateFormat(JournalConvertConstants.PATTERN_DATE);
    return sdf.format(convDate);
  }

  /**
   * 日付のフォーマット変換
   *
   * @param pattern 変換フォーマット
   * @param dataStr 日付文字列
   * @return Date 変換結果
   * */
  public static Date parseDateFormat(String pattern, String dateStr) {

    // 日付チェック
    if (FORMAT_YYYYMMDD.equals(pattern)) {
      try {
        DateTimeFormatter dtf = DateTimeFormatter
            .ofPattern("uuuuMMdd")
            .withResolverStyle(ResolverStyle.STRICT);
        dtf.parse(dateStr);
      } catch (DateTimeParseException e) {
        return null;
      }
    }

    Date date;
    try {
      SimpleDateFormat sdf = new SimpleDateFormat(pattern);
      if (FORMAT_GYYMMDD.equals(pattern)) {
        // 和暦変換の場合
        Locale locale = new Locale("ja", "JP", "JP");
        sdf = new SimpleDateFormat(pattern, locale);
      }
      // Date型に変換
      date = sdf.parse(dateStr);
    } catch (ParseException e) {
      // 変換できない場合
      date = null;
    }
    return date;
  }

  /**
   * 新元号を西暦に変換
   *
   * @param era {@link NewJapaneseEra } 対象の和暦
   * @param date 変換対象の和暦(形式:元号YYMMDD)
   * */
  private static String convertNewJpEraDate(NewJapaneseEra era, String date) {
    // 元年を0とする
    int yy = Integer.valueOf(date.substring(2, 4)) - 1;
    Calendar calendar = Calendar.getInstance();
    // 新元号の開始日
    calendar.set(era.getSince().getYear()
               , era.getSince().getMonthValue()
               , era.getSince().getDayOfMonth());
    // 年を取得
    calendar.add(Calendar.YEAR, yy);
    // YYYYMMDDで返却
    return String.valueOf(calendar.get(Calendar.YEAR)) + date.substring(4);
  }
}
