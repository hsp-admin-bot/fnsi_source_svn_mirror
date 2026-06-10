package jp.co.nikkiso.ntss.coop_api.service;

import java.util.concurrent.Future;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Async;
import org.springframework.scheduling.annotation.AsyncResult;
import org.springframework.stereotype.Service;

import jp.co.nikkiso.ntss.core.constant.LoggingConstant.MODULE_NAME;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.EventLogger;
import jp.co.nikkiso.ntss.core.logger.EventLoggerFactory;
import jp.co.nikkiso.ntss.core.logger.LogClass;
import jp.co.nikkiso.ntss.core.logger.LogObjectUtils;

/**
 * 正常動作確認の為、3分毎にログを出力
 */
@Service
public class AsyncService {

  private final String SYSTEM = "system";
  private boolean runFlg = true;

  /**
   * ロガー生成コンポーネント
   */
  @Autowired
  private EventLoggerFactory eventLoggerFactory;

  /**
   * 処理停止用
   */
  public void stopLog() {
    this.runFlg = false;
  }

  @Async
  public Future<Integer> operationCheckLog() {
    while(this.runFlg) {
      try {
        Thread.sleep(180000);
      } catch (InterruptedException e) {
        // 停止処理(interrupt())が発火された場合の処理。停止処理の為、そのまま終了時する
        break;
      }
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("アプリケーション起動中");
      // 本アプリケーションが稼働しているIPアドレスを取得
      eventLogMessage.setEc2Identification(LogObjectUtils.getHostAddress());
      eventLogMessage.setServiceName(MODULE_NAME.NTSS_COOP_API);
      EventLogger logger = eventLoggerFactory.getLogger(SYSTEM, LogClass.APP);
      // ログ出力
      logger.info(eventLogMessage);
    }
    return new AsyncResult<>(1);
  }
}
