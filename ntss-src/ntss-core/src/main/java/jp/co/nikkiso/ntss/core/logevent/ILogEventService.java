package jp.co.nikkiso.ntss.core.logevent;

import jp.co.nikkiso.ntss.core.logger.LogLevel;
import org.springframework.data.domain.Page;

import java.util.List;

public interface ILogEventService {
  Page<LogEvent> findAll(LogEvent params);
  void create(LogLevel logType, LogEvent params);
  /* add by chamaojia 2023-03-14 新しい一括ログ記録方法の追加  --start */
  void createToBatch(LogLevel logType, List<LogEvent> logEventList);
  /* add by chamaojia 2023-03-14 新しい一括ログ記録方法の追加  --end */
  String getPersonalInfoDecrypt(String inData);
  String getPersonalInfoEncrypt(String inData);
  String getPersonalUserName(Long userId);
}
