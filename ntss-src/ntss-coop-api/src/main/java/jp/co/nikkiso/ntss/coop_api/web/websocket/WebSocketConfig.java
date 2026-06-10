package jp.co.nikkiso.ntss.coop_api.web.websocket;

import java.net.InetAddress;
import java.net.UnknownHostException;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.socket.WebSocketHandler;
import org.springframework.web.socket.config.annotation.EnableWebSocket;
import org.springframework.web.socket.config.annotation.WebSocketConfigurer;
import org.springframework.web.socket.config.annotation.WebSocketHandlerRegistry;

import com.amazonaws.util.EC2MetadataUtils;

import jp.co.nikkiso.ntss.coop_api.config.IfEdgeConfigulation;
import jp.co.nikkiso.ntss.coop_api.service.LogService;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;


@EnableWebSocket   // WebSocketのBean定義を有効化する
@Configuration
public class WebSocketConfig implements WebSocketConfigurer {
  @Value("${websocket.dataset.path}")
  private String dataSetPath;

  // add 2021-04-23 外部連携:定時のView連携の対応 孫 start
  @Value("${websocket.dataset.time-path}")
  private String timeDataSetPath;
  // add 2021-04-23 外部連携:定時のView連携の対応 孫 end

  // add 2020-11-16 各API間の呼び出しフローの修正（エッジ主体からAWS主体へ）→負荷増加回避策が必要 孫 start
  @Value("${websocket.if-edge-journal.path}")
  private String ifEdgejournalPath;
  // add 2020-11-16 各API間の呼び出しフローの修正（エッジ主体からAWS主体へ）→負荷増加回避策が必要 孫 end

//WebSocketConfigurerを継承しWebSocket関連のBean定義をカスタマイズする


  @Autowired
  private IfEdgeConfigulation ifEdgeConfigulation;

  @Autowired
  IfEdgeMntSessionManager ifEdgeMntSessionManager;

  @Autowired
  LogService logService;

  @Override
  public void registerWebSocketHandlers(WebSocketHandlerRegistry registry) {
	// for view公開
    registry.addHandler(iFEdgeHandler(), dataSetPath);

    // add 2021-04-23 外部連携:定時のView連携の対応 孫 start
  // for time view公開
    registry.addHandler(iFEdgeTimeHandler(), timeDataSetPath);
    // add 2021-04-23 外部連携:定時のView連携の対応 孫 end

	// for if maintenance
    // WebSocketのエンドポイント(接続時に指定するエンドポイント)を指定
    registry.addHandler(messageHandler(), ifEdgeConfigulation.getWsPath());

    // add 2020-11-16 各API間の呼び出しフローの修正（エッジ主体からAWS主体へ）→負荷増加回避策が必要 孫 start
  // for 連携受信
    registry.addHandler(ifEdgeSysJournalHandler(), ifEdgejournalPath);
    // add 2020-11-16 各API間の呼び出しフローの修正（エッジ主体からAWS主体へ）→負荷増加回避策が必要 孫 end

    // アプリケーションが動作しているサーバーのIPアドレスを取得しセッション管理に登録する
    String ip;
    EventLogMessage eventLogMessage = new EventLogMessage();
    try {
      ip = InetAddress.getLocalHost().getHostAddress();
    } catch (UnknownHostException e) {

      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
      eventLogMessage.setInvokeClass(this.getClass().getName());
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      ip = EC2MetadataUtils.getInstanceInfo().getPrivateIp();
    }
    // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
    eventLogMessage.setInvokeClass(this.getClass().getName());
    // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
    eventLogMessage.setLogMessage("Server IP : " + ip);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);

    this.ifEdgeMntSessionManager.setLocalIp( ip );
  }

  @Bean
  public IFEdgeDataSetHandler iFEdgeHandler() {
    return new IFEdgeDataSetHandler();
  }
  @Bean
  public WebSocketHandler messageHandler() {
      return new IfEdgeMntMessageHandler();
  }

  // add 2020-11-16 各API間の呼び出しフローの修正（エッジ主体からAWS主体へ）→負荷増加回避策が必要 孫 start
  @Bean
  public IfEdgeSysJournalHandler ifEdgeSysJournalHandler() {
    return new IfEdgeSysJournalHandler();
  }
  // add 2020-11-16 各API間の呼び出しフローの修正（エッジ主体からAWS主体へ）→負荷増加回避策が必要 孫 end

  // add 2021-04-23 外部連携:定時のView連携の対応 孫 start
  @Bean
  public IFEdgeTimeDataSetHandler iFEdgeTimeHandler() {
    return new IFEdgeTimeDataSetHandler();
  }
  // add 2021-04-23 外部連携:定時のView連携の対応 孫 end
}
