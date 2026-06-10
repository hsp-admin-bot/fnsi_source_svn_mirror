package jp.co.nikkiso.ntss.device_edge_updater_front.config;

import java.time.Clock;
import java.time.ZoneId;
import java.time.ZonedDateTime;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;

@Profile("test")
@Configuration
public class DateTimeTestConfig {
  @Bean
  public Clock clock() {
    return Clock.fixed(ZonedDateTime.parse("2011-01-01T12:00:00+09:00").toInstant(), ZoneId.systemDefault());
  }
}
