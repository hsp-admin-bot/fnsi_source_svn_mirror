package jp.co.nikkiso.ntss.api.aspect;

import jp.co.nikkiso.ntss.api.service.LogService;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.logger.LogObjectUtils;
import org.seasar.doma.jdbc.UtilLoggingJdbcLogger;
import org.springframework.util.StringUtils;

import java.util.function.Supplier;
import java.util.logging.Level;

public class NtssUtilLoggingJdbcLogger extends UtilLoggingJdbcLogger {

  private LogService _logService;

  public NtssUtilLoggingJdbcLogger(LogService logService) {
    this._logService = logService;
  }

  @Override
  protected void log(
    Level level,
    String callerClassName,
    String callerMethodName,
    Throwable throwable,
    Supplier<String> messageSupplier) {
    logger.logp(level, callerClassName, callerMethodName, throwable, messageSupplier);
    try {
      outputLog(messageSupplier.get(), true);
    } catch (Exception e) {}
  }

  /**
   * ログ出力
   * @param sqlMessage sql文
   */
  private void outputLog(String sqlMessage, boolean sqlLogFlg) {

    if (StringUtils.isEmpty(sqlMessage)) {
      return;
    }

    if (sqlLogFlg && sqlMessage.indexOf("SQL LOG") < 0) {
      return;
    }

    if (!StringUtils.isEmpty(sqlMessage) &&
      sqlMessage.indexOf("jp/co/nikkiso/ntss/core/dao/SysSystemDefineDao/selectByCtlNo.sql") >= 0 &&
      sqlMessage.indexOf("27") >= 0) {
      return;
    }

    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setEc2Identification(LogObjectUtils.getHostAddress());
    eventLogMessage.setLogMessage(sqlMessage);

    this._logService.log(LogLevel.INFO, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
  }
}
