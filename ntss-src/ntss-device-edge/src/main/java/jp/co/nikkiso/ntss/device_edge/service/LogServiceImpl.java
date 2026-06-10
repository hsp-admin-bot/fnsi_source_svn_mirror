package jp.co.nikkiso.ntss.device_edge.service;

import com.zaxxer.hikari.HikariDataSource;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.MODULE_NAME;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.EventLogger;
import jp.co.nikkiso.ntss.core.logger.EventLoggerFactory;
import jp.co.nikkiso.ntss.core.logger.LogClass;
import jp.co.nikkiso.ntss.core.logger.LogObjectUtils;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import org.springframework.util.ObjectUtils;

/**
 * ログ出力サービス
 */
@Service("ntss-device-edge")
public class LogServiceImpl implements LogService {

  private final String SYSTEM = "system";

  /**
   * ロガー生成コンポーネント
   */
  @Autowired
  private EventLoggerFactory eventLoggerFactory;

  // #11810 2025.05.29 add ログ強化 TDC片口 start
  @Autowired
  private HikariDataSource dataSource;
  // #11810 2025.05.29 add ログ強化 TDC片口 end

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
        eventLogMessage.setServiceName(MODULE_NAME.NTSS_DEVICE_EDGE+ ", " + serviceName);
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

      // #8732 2023.06.26 add ログ強化 TDC片口 start
      // #11810 2025.05.29 mod ログ強化 TDC片口 start
//      eventLogMessage.setLogMessage(LogObjectUtils.getSystemInfo());
      eventLogMessage.setLogMessage(LogObjectUtils.getSystemInfo() + " / " + LogObjectUtils.getThreadGroupInfo() + " / DB_ACTIVE_SESSION_COUNT=" + dataSource.getHikariPoolMXBean().getActiveConnections());
      // #11810 2025.05.29 mod ログ強化 TDC片口 end
      logger.debug(eventLogMessage);
      // #8732 2023.06.26 add ログ強化 TDC片口 end

    } catch (Exception e) {}
  }
}
