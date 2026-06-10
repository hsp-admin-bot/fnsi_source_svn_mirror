package jp.co.nikkiso.ntss.data_gathering_auto.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.MODULE_NAME;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.EventLogger;
import jp.co.nikkiso.ntss.core.logger.EventLoggerFactory;
import jp.co.nikkiso.ntss.core.logger.LogClass;
import jp.co.nikkiso.ntss.core.logger.LogObjectUtils;

/**
 * スケジューリング機能
 *
 */
@Service
public class ScheduleService {

  private final String SYSTEM = "system";

  /**
   * ロガー生成コンポーネント
   */
  @Autowired
  private EventLoggerFactory eventLoggerFactory;

  /**
   * 正常動作確認の為、3分毎にログを出力
   */
  @Scheduled(initialDelay = 180000, fixedRate = 180000)
  public void operationCheckLog() {
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("アプリケーション起動中");
    // 本アプリケーションが稼働しているIPアドレスを取得
    eventLogMessage.setEc2Identification(LogObjectUtils.getHostAddress());
    eventLogMessage.setServiceName(MODULE_NAME.NTSS_DATA_GATHERING_AUTO);
    //FNSI-修正 ログ対応 xiebzh add start
    eventLogMessage.setInvokeClass(this.getClass().getName());
    //FNSI-修正 ログ対応 xiebzh add end
    EventLogger logger = eventLoggerFactory.getLogger(SYSTEM, LogClass.APP);
    // ログ出力
    logger.info(eventLogMessage);
  }
}
