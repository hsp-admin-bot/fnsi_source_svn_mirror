package jp.co.nikkiso.ntss.core.dao.utils;

import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.logevent.LogServiceCoreImpl;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.TimeZone;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

/**
 * 日時操作のユーティリティクラス.
 */
public class DateTimeUtils {

  /**
   * YYYYMMDDのフォーマット.
   */
  private static final String FORMAT_YYYYMMDD = "yyyyMMdd";

  /**
   * ISO8601形式の日付文字列からyyyyMMddの日付文字列を取得する。
   * @param dateString ISO8601形式の日付文字列
   * @return String yyyyMMddの日付文字列
   */
  public static String dateStirng_iso8601ToDateString_yyyyMMdd(String dateString) {

    String dateResult;
    Date date;
    if(dateString != null && !dateString.equals("null")) {
      // ISO8601形式のフォーマット
      SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS");
      SimpleDateFormat sdf2 = new SimpleDateFormat(FORMAT_YYYYMMDD);
      try {
        date = sdf.parse(dateString);
        dateResult = sdf2.format(date);
      } catch (ParseException e) {
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang start
//      e.printStackTrace();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang end
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 add yangxuewang start
        LogServiceCoreImpl logServiceCore = new LogServiceCoreImpl();
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
        if (logServiceCore != null) {
          logServiceCore.log(LogLevel.ERROR, eventLogMessage, "", null, LoggingConstant.SERVICE_NAME.FNSI, null);
        }
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 add yangxuewang end
        dateResult = null;
      }
    } else {
      // 引数がnullのときnullを返す
      dateResult = null;
    }
    return dateResult;
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
}
