package jp.co.nikkiso.ntss.admin_web.aspect;

import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.logger.LogObjectUtils;
import org.seasar.doma.jdbc.UtilLoggingJdbcLogger;
import org.springframework.security.core.context.SecurityContextHolder;
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
    } catch (Exception e) {
      outputLog(e.getMessage(), false);
    }
  }

  /**
   * ログ出力
   * @param sqlMessage sql文
   */
  private void outputLog(String sqlMessage, boolean sqlLogFlg) {

    if (StringUtils.isEmpty(sqlMessage) || sqlMessage.indexOf("SQL LOG") < 0) {
      return;
    }

    if (sqlLogFlg && sqlMessage.indexOf("SQL LOG") < 0) {
      return;
    }
    
    // ロガーの設定を取得するSQLに対してログ出力を実施すると無限ループになる為、処理をスキップする
    if (sqlMessage.indexOf("PATH=[META-INF/jp/co/nikkiso/ntss/core/dao/SysSystemDefineDao/selectByCtlNo.sql]") > 0 && sqlMessage.indexOf("ctl_no = 27") > 0) {
      return;
    }

    EventLogMessage eventLogMessage = new EventLogMessage();
    NtssUser user = null;
    try {
      user = (NtssUser) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
    } catch (Exception e) {}

    if (user != null) {
      // 利用者ID
      eventLogMessage.setUserId(user.getUserId().toString());
      // 施設コード
      eventLogMessage.setFacilityCd(user.getFacilityCd());
      // 接続先IPアドレス
      eventLogMessage.setClientIp(user.getClientIpAddress());
      // セッションID
      eventLogMessage.setSessionId(user.getSessionId());
    }

    eventLogMessage.setEc2Identification(LogObjectUtils.getHostAddress());
    eventLogMessage.setLogMessage(sqlMessage);

    this._logService.log(LogLevel.INFO, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
  }
}
