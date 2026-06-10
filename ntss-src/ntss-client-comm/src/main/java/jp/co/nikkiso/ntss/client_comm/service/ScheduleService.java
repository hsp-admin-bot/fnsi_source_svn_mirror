package jp.co.nikkiso.ntss.client_comm.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import jp.co.nikkiso.ntss.client_comm.web.websocket.SessionManager;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.MODULE_NAME;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.EventLogger;
import jp.co.nikkiso.ntss.core.logger.EventLoggerFactory;
import jp.co.nikkiso.ntss.core.logger.LogClass;
import jp.co.nikkiso.ntss.core.logger.LogObjectUtils;


/**
 * スケジューリング機能
 * @author H.Yonezawa
 *
 */
//@Slf4j
@Service
public class ScheduleService {

  private final String SYSTEM = "system";

  @Autowired
  private SessionManager sessionCtrl;

  /**
   * 10秒周期
   */
  @Scheduled(initialDelay = 10000, fixedRate = 10000)
  public void rate10SExecute() {
      // log.debug("1000ms毎に実行：ScheduleService.rate10SExecute()");

      // WSクライアント死活監視処理
      sessionCtrl.checkWSClientConnectionStatus();

      // クライアント異常切断処理
      sessionCtrl.checkErrorDisconnClient();
  }

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
    eventLogMessage.setServiceName(MODULE_NAME.NTSS_CLIENT_COMM);
    EventLogger logger = eventLoggerFactory.getLogger(SYSTEM, LogClass.APP);
    // ログ出力
    logger.info(eventLogMessage);
  }
}
