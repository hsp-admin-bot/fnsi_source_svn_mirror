package jp.co.nikkiso.ntss.admin_web.service.log;

import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.MODULE_NAME;
import jp.co.nikkiso.ntss.core.logevent.ILogEventService;
import jp.co.nikkiso.ntss.core.logevent.LogEventUtil;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.EventLogger;
import jp.co.nikkiso.ntss.core.logger.EventLoggerFactory;
import jp.co.nikkiso.ntss.core.logger.LogClass;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.logger.LogObjectUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.util.ObjectUtils;
import org.springframework.util.StringUtils;

/**
 * ログ出力サービス
 */
@Service
public class LogServiceImpl implements LogService {

  //add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 zhaoqi 20240228 start
  private final String SYSTEM = "system";
  //add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 zhaoqi 20240228 end

  /**
   * ロガー生成コンポーネント
   */
  @Autowired
  private EventLoggerFactory eventLoggerFactory;

  //FNSI-修正 ログ対応 xiebzh add start
  @Autowired
  private ILogEventService logEventService;
  //FNSI-修正 ログ対応 xiebzh add end

  /**
   * {@inheritDoc}
   */
  @Override
  public void log(LogLevel logType, EventLogMessage eventLogMessage, String functionCode, String serviceName,
                  String sqlFilePath) {
    try {
      NtssUser user = null;
      if (SecurityContextHolder.getContext().getAuthentication() != null &&
             SecurityContextHolder.getContext().getAuthentication().getPrincipal() != null) {

        if (SecurityContextHolder.getContext().getAuthentication().getPrincipal() instanceof NtssUser) {
          user = (NtssUser) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
          if (user == null || eventLogMessage == null)
            return;
          // 利用者ID
          eventLogMessage.setUserId(user.getUserId().toString());
          // 施設コード
          eventLogMessage.setFacilityCd(user.getFacilityCd());
          // 接続先IPアドレス
          eventLogMessage.setClientIp(user.getClientIpAddress());
          // セッションID
          eventLogMessage.setSessionId(user.getSessionId());
        }
      }

      // SQL名
      if (sqlFilePath != null && eventLogMessage.getSqlIdentification() != null) {
        try {
          String sqlData = LogObjectUtils.readSqlFile(sqlFilePath);
          sqlData += " | " + eventLogMessage.getSqlIdentification();
          eventLogMessage.setSqlIdentification(sqlData);
        } catch (Exception e) {
        }
      }
      // 機能コード
      if (!StringUtils.isEmpty(functionCode)) {
        eventLogMessage.setFunctionCd(functionCode);
      }
      // サービス名
      if (!StringUtils.isEmpty(serviceName)) {
        eventLogMessage.setServiceName(MODULE_NAME.ADMIN_WEB + "," + serviceName);
      }

      //add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 zhaoqi 20240228 start
      // ロガー取得
      String fileName;
      if (ObjectUtils.isEmpty(eventLogMessage.getFacilityCd())) {
        fileName = SYSTEM;
      } else {
        fileName = eventLogMessage.getFacilityCd();
      }
      //add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 zhaoqi 20240228 end

      //FNSI-修正 ログ対応 xiebzh add start
      if (logType == LogLevel.MONGO) {
        logEventService.create(LogLevel.INFO, LogEventUtil.getLogEvent(LogLevel.INFO.name(), eventLogMessage));
      } else {
        //mod #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 zhaoqi 20240228 start
        // ロガー取得
        EventLogger logger = eventLoggerFactory.getLogger(fileName, LogClass.APP);
        //mod #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 zhaoqi 20240228 end

        switch (logType) {
          case INFO:
            logger.info(eventLogMessage);
            break;
          case ERROR:
            logger.error(eventLogMessage);
            break;
          case WARN:
            logger.warn(eventLogMessage);
            break;
          case DEBUG:
            logger.debug(eventLogMessage);
            break;
          default:
            return;
        }
      }
      //FNSI-修正 ログ対応 xiebzh add end

    } catch (Exception e) {}
  }

}
