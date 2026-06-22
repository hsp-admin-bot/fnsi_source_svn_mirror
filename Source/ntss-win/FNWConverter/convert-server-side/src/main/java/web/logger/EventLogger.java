package web.logger;

import ch.qos.logback.classic.Logger;
import lombok.extern.slf4j.Slf4j;
import org.springframework.util.ObjectUtils;

/**
 * EventLogger
 */
@Slf4j
public class EventLogger {

  /**
   * Logger.
   */
  private final Logger logger;

  /**
   * コンストラクタ.
   *
   * @param logger Loggerインスタンス
   */
  EventLogger(Logger logger) {
    this.logger = logger;
  }

  /**
   * INFOレベルのログを出力する.
   *
   * @param eventLogMessage メッセージ
   */
  public void info(EventLogMessage eventLogMessage) {
    if (!ObjectUtils.isEmpty(logger)) {
      logger.info(eventLogMessage.buildLogMessage(LogLevel.INFO));
      log.info(eventLogMessage.buildLogMessage(LogLevel.INFO));
    }
  }

  /**
   * WARNNINGレベルのログを出力する.

   * @param eventLogMessage メッセージ
   */
  public void warn(EventLogMessage eventLogMessage) {
    if (!ObjectUtils.isEmpty(logger)) {
      logger.warn(eventLogMessage.buildLogMessage(LogLevel.WARN));
      log.warn(eventLogMessage.buildLogMessage(LogLevel.WARN));
    }
  }

  /**
   * ERRORレベルのログを出力する.
   *
   * @param eventLogMessage メッセージ
   */
  public void error(EventLogMessage eventLogMessage) {
    if (!ObjectUtils.isEmpty(logger)) {
      logger.error(eventLogMessage.buildLogMessage(LogLevel.ERROR));
      log.error(eventLogMessage.buildLogMessage(LogLevel.ERROR));
    }
  }

	/**
	 * DEBUGレベルのログを出力する.
	 *
	 * @param eventLogMessage メッセージ
	 */
	public void debug(EventLogMessage eventLogMessage) {
    if (!ObjectUtils.isEmpty(logger)) {
      logger.debug(eventLogMessage.buildLogMessage(LogLevel.DEBUG));
      log.debug(eventLogMessage.buildLogMessage(LogLevel.DEBUG));
    }
	}
}
