package jp.co.nikkiso.ntss.web_api.util;

import java.sql.Date;
import java.time.Clock;
import java.time.ZoneId;

import org.springframework.stereotype.Component;

import jp.co.nikkiso.ntss.web_api.service.utils.NtssDateTimeUtils;

/**
 * {@link Clock} のラッパークラス
 * 通常稼働時はサーバ時刻をミリ秒で取得し、UT時はモック化します
 *
 */
@Component
public class ClockWrapper {
  public Clock getClock() {
    return Clock.system(ZoneId.of("JST", ZoneId.SHORT_IDS));
  }

  /**
   * exchange.
   * {@link ClockWrapper#getClock()} -> long
   * @return long
   */
  public long getClockMillis() {
    return getClock().millis();
  }

  /**
   * 現在時刻の文字列表現を取得する。
   *
   * @return 現在時刻の文字列表現
   */
  public String getCurrentTimeStr() {
    Long t = getClockMillis();
    return NtssDateTimeUtils.getDateString_iso8601(new Date(t));
  }
}
