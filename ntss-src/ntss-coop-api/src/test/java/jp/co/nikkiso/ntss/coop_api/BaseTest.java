package jp.co.nikkiso.ntss.coop_api;

import java.sql.Timestamp;
import java.time.Clock;
import java.time.Instant;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.ZoneOffset;
import java.time.format.DateTimeFormatter;

public class BaseTest {
  public LocalDateTime getExpectTime() {
    return LocalDateTime.of(2019, 11, 12, 15, 0, 0, 0);
  }

  public LocalDateTime getExpectMockTime() {
    return LocalDateTime.of(2019, 10, 10, 10, 0, 0, 0);
  }

  public Clock getExpectMockClock() {
    return Clock.fixed(getExpectMockTime().toInstant(ZoneOffset.ofHours(+9)), ZoneId.systemDefault());
  }

  public long getMockClockMillis() {
    Instant instant = getExpectMockTime().toInstant(ZoneOffset.ofHours(+9));
    return Clock.fixed(instant, ZoneId.systemDefault()).millis();
  }

  /**
   * 指定した ミリ秒を 指定した日付フォーマット文字列にして返す
   *
   * @param time {@link Timestamp#Timestamp(long)} の引数
   * @param format 日付フォーマットのパターン
   * @return {@code format} で指定した形式の文字列
   */
  public String formatDate(long time, String format) {
    DateTimeFormatter formatter = DateTimeFormatter.ofPattern(format);
    return new Timestamp(time).toLocalDateTime().format(formatter);
  }
}
