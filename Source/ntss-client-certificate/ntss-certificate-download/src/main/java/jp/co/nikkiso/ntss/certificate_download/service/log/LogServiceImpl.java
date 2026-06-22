package jp.co.nikkiso.ntss.certificate_download.service.log;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.EventLoggerFactory;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.logger.EventLogger;
import jp.co.nikkiso.ntss.core.logger.LogObjectUtils;

@Service
public class LogServiceImpl implements LogService {

  private final String FILE_NAME = "NtssClientCertificateLog";
  
  /**
   * ロガー生成コンポーネント
   */
  @Autowired
  private EventLoggerFactory eventLoggerFactory;

  @Override
  public void log(LogLevel logType, EventLogMessage eventLogMessage, String functionCode, String serviceName,
      String sqlFilePath) {
    try {
      if (eventLogMessage == null){
        return;
      }
      if (sqlFilePath != null && eventLogMessage.getSqlIdentification() != null) {
        try {
          LogObjectUtils logObjectUtils = new LogObjectUtils();
          String sqlData = logObjectUtils.readSqlFile(sqlFilePath);
          sqlData += " | " + eventLogMessage.getSqlIdentification();
          eventLogMessage.setSqlIdentification(sqlData);
        } catch (Exception e) {
        }
      }
      if (functionCode != null) {
        eventLogMessage.setFunctionCd(functionCode);
      }
      if (serviceName != null) {
        eventLogMessage.setServiceName(serviceName);
      }
      EventLogger logger = eventLoggerFactory.getLogger(FILE_NAME);
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
    } catch (Exception e) {
      e.printStackTrace();
    }
  }
}
