package jp.co.nikkiso.ntss.coop_api.utils;

import java.time.Clock;
import java.time.ZoneId;

import org.springframework.stereotype.Component;

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
}
