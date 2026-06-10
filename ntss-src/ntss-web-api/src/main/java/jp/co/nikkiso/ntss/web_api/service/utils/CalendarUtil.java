package jp.co.nikkiso.ntss.web_api.service.utils;

import java.util.Calendar;

/**
 * 日付に関するユーティリティクラス。
 */
public class CalendarUtil {

  /**
   * 指定された月だけ移動した時刻を求める。
   *
   * @param now 時刻
   * @param months 月数
   * @return 移動した時刻
   */
  public static Long shiftMonth(Long now, int months) {
    Calendar c = Calendar.getInstance();
    c.setTimeInMillis(now);
    c.add(Calendar.MONTH, months);
    return c.getTimeInMillis();
  }

}
