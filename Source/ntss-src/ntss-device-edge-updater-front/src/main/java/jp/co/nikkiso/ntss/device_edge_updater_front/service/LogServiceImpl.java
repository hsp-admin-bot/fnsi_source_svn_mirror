package jp.co.nikkiso.ntss.device_edge_updater_front.service;

import jp.co.nikkiso.ntss.core.logevent.ILogEventService;
import jp.co.nikkiso.ntss.core.logevent.LogEventUtil;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.MODULE_NAME;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.EventLogger;
import jp.co.nikkiso.ntss.core.logger.EventLoggerFactory;
import jp.co.nikkiso.ntss.core.logger.LogClass;
import jp.co.nikkiso.ntss.core.logger.LogObjectUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.util.ObjectUtils;
import org.springframework.util.StringUtils;

/**
 * ログ出力サービス
 */
@Service
public class LogServiceImpl implements LogService {

  private final String SYSTEM = "system";

  /**
   * ロガー生成コンポーネント
   */
  @Autowired
  private EventLoggerFactory eventLoggerFactory;

  /**
   * {@inheritDoc}
   */
  @Override
  public void log(LogLevel logType, EventLogMessage eventLogMessage, String functionCode, String serviceName,
                  String sqlFilePath) {
    try {
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
        eventLogMessage.setServiceName(MODULE_NAME.NTSS_DEVICE_EDGE_UPDATER_FRONT + ", " + serviceName);
      }

      // ロガー取得
      String fileName;
      if (ObjectUtils.isEmpty(eventLogMessage.getFacilityCd())) {
        fileName = SYSTEM;
      } else {
        fileName = eventLogMessage.getFacilityCd();
      }

      EventLogger logger = eventLoggerFactory.getLogger(fileName, LogClass.APP);

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

    } catch (Exception e) {}
  }

}
