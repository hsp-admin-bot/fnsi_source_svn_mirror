package jp.co.nikkiso.ntss.certificate_management.service.log;

import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;

public interface LogService {
  
  void log(LogLevel logType, EventLogMessage evm, String functionCode, String servicename, String sqlFilePath);
}
