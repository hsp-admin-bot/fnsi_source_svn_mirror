package jp.co.nikkiso.ntss.core.logger;

import ch.qos.logback.classic.Logger;
import org.springframework.util.ObjectUtils;

/**
 * EventLogger
 */
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
    //EventLogger.validateParam(logger);
    this.logger = logger;
  }

  /**
   * INFOレベルのログを出力する.
   *
   * @param eventLogMessage メッセージ
   */
  public void info(EventLogMessage eventLogMessage) {
    //EventLogger.validateParam(eventLogMessage);
    if (!ObjectUtils.isEmpty(logger)) {
      logger.info(eventLogMessage.buildLogMessage(LogLevel.INFO));
    }
  }

  /**
   * WARNNINGレベルのログを出力する.

   * @param eventLogMessage メッセージ
   */
  public void warn(EventLogMessage eventLogMessage) {
    //EventLogger.validateParam(eventLogMessage);
    if (!ObjectUtils.isEmpty(logger)) {
      logger.warn(eventLogMessage.buildLogMessage(LogLevel.WARN));
    }
  }

  /**
   * ERRORレベルのログを出力する.
   *
   * @param eventLogMessage メッセージ
   */
  public void error(EventLogMessage eventLogMessage) {
    //EventLogger.validateParam(eventLogMessage);
    if (!ObjectUtils.isEmpty(logger)) {
      logger.error(eventLogMessage.buildLogMessage(LogLevel.ERROR));
    }
  }

  /**
   * 指定されたパラメータが NULL でないことを検証します.
   * @param param パラメータ
   * @param <P> 型パラメータ
   */
  private static <P> void validateParam(P param) {
    if (ObjectUtils.isEmpty(param)) {
      throw new IllegalArgumentException("Parameter is null");
    }
  }

	/**
	 * DEBUGレベルのログを出力する.
	 *
	 * @param eventLogMessage メッセージ
	 */
	public void debug(EventLogMessage eventLogMessage) {
		//EventLogger.validateParam(eventLogMessage);
    if (!ObjectUtils.isEmpty(logger)) {
      logger.error(eventLogMessage.buildLogMessage(LogLevel.DEBUG));
    }
	}
}
