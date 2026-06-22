package jp.co.nikkiso.ntss.core.logger;

import ch.qos.logback.classic.Logger;
import ch.qos.logback.classic.LoggerContext;
import ch.qos.logback.classic.encoder.PatternLayoutEncoder;
import ch.qos.logback.classic.spi.ILoggingEvent;
import ch.qos.logback.core.rolling.RollingFileAppender;
import ch.qos.logback.core.rolling.SizeAndTimeBasedRollingPolicy;
import ch.qos.logback.core.util.FileSize;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;

import java.nio.charset.StandardCharsets;
import java.text.MessageFormat;

/**
 * ロガー生成コンポーネント
 */
@Component
public class EventLoggerFactory {

  private final String SYSTEM = "system";

  /**
   * ログのプロパティクラス
   */
  @Autowired
  private EventLoggingProperties eventLoggingProperties;

  /**
   * ロガーを取得する.
   * <p>
   * ログファイルの出力に使用されます。
   * </p>
   * @param loggerName ロガー名
   * @return ロガー
   */
  public EventLogger getLogger(String loggerName) {

    if (!StringUtils.hasLength(loggerName)) {
      throw new IllegalArgumentException("loggerName is Null or Empty");
    }

    final Logger logger = (Logger) LoggerFactory.getLogger(loggerName);
    synchronized (logger) {
      if (logger.getAppender(loggerName) == null) {
        final LoggerContext lc = (LoggerContext) LoggerFactory.getILoggerFactory();
        final PatternLayoutEncoder ple = new PatternLayoutEncoder();
        ple.setPattern("\"%d{yyyy/MM/dd HH:mm:ss}\",%msg%n"); // ログメッセージはCSV形式で出力
        ple.setContext(lc);
        ple.setCharset(StandardCharsets.UTF_8);
        ple.start();
        // del #9232 CL証明書のログローテート設定とその制御処理 shiyw 2024-06-26 start
        String serverName = LogObjectUtils.getHostName();
        String projectName = eventLoggingProperties.getApplicationName();
        // del #9232 CL証明書のログローテート設定とその制御処理 shiyw 2024-06-26 end
        // ローテーションの設定取得
        final RollingFileAppender<ILoggingEvent> fileAppender = new RollingFileAppender<>();
        fileAppender.setName(loggerName);
        // mod #9232 CL証明書のログローテート設定とその制御処理 shiyw 2024-06-26 start
//        String logFileName = MessageFormat.format(eventLoggingProperties.getFileName(), SYSTEM, serverName, projectName);
        String logFileName = eventLoggingProperties.getFileName();
        // mod #9232 CL証明書のログローテート設定とその制御処理 shiyw 2024-06-26 end
        fileAppender.setFile(logFileName);
        fileAppender.setAppend(true);
        fileAppender.setContext(lc);

        // 時刻ベースのローテーションの設定取得
        final SizeAndTimeBasedRollingPolicy<ILoggingEvent> rollingPolicy = new SizeAndTimeBasedRollingPolicy<>();
        // mod #9232 CL証明書のログローテート設定とその制御処理 shiyw 2024-06-26 start
//        String fileNamePattern = MessageFormat.format(eventLoggingProperties.getFileNamePattern(), SYSTEM, serverName, projectName);
        String fileNamePattern = eventLoggingProperties.getFileNamePattern();
        // mod #9232 CL証明書のログローテート設定とその制御処理 shiyw 2024-06-26 end
        rollingPolicy.setFileNamePattern(fileNamePattern);
        rollingPolicy.setMaxHistory(eventLoggingProperties.getMaxHistory());
        rollingPolicy.setParent(fileAppender);
        rollingPolicy.setContext(lc);
        FileSize fs = FileSize.valueOf(eventLoggingProperties.getMaxFileSize() + "MB");
        rollingPolicy.setMaxFileSize(fs);
        rollingPolicy.start();

        fileAppender.setRollingPolicy(rollingPolicy);
        fileAppender.setEncoder(ple);
        fileAppender.start();

        logger.addAppender(fileAppender);
        logger.setAdditive(false);
      }
    }
    return new EventLogger(logger);
  }

}
