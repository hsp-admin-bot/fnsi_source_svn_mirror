package jp.co.nikkiso.ntss.core.config;

import java.time.Clock;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * Clockを使用したシステム日時取得の設定クラス.
 */
@Configuration
public class DateTimeConfig {

  @Bean
  public Clock clock() {
    return Clock.systemDefaultZone();
  }
}
