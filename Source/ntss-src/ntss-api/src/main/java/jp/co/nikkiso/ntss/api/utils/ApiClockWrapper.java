package jp.co.nikkiso.ntss.api.utils;

import java.time.Clock;
import java.time.ZoneId;

import org.springframework.stereotype.Component;

/**
 * {@link Clock} のラッパークラス
 * 通常稼働時はサーバ時刻をミリ秒で取得し、UT時はモック化します
 *
 */
@Component
public class ApiClockWrapper {
  public Clock getClock() {
    return Clock.system(ZoneId.of("JST", ZoneId.SHORT_IDS));
  }

  /**
   * exchange.
   * {@link ApiClockWrapper#getClock()} -> long
   * @return long
   */
  public long getClockMillis() {
    return getClock().millis();
  }
}
