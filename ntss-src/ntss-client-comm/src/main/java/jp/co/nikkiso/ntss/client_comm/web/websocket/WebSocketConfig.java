package jp.co.nikkiso.ntss.client_comm.web.websocket;

import java.net.InetAddress;
import java.net.UnknownHostException;
import java.util.concurrent.Executors;

import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.TaskScheduler;
import org.springframework.scheduling.concurrent.ConcurrentTaskScheduler;
import org.springframework.web.socket.WebSocketHandler;
import org.springframework.web.socket.config.annotation.EnableWebSocket;
import org.springframework.web.socket.config.annotation.WebSocketConfigurer;
import org.springframework.web.socket.config.annotation.WebSocketHandlerRegistry;
import org.springframework.web.socket.server.support.HttpSessionHandshakeInterceptor;

import com.amazonaws.util.EC2MetadataUtils;

import jp.co.nikkiso.ntss.client_comm.NtssApplicationProperties;
import jp.co.nikkiso.ntss.client_comm.service.LogService;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;


@EnableWebSocket   // WebSocketのBean定義を有効化する
@Configuration
public class WebSocketConfig implements WebSocketConfigurer   {
//WebSocketConfigurerを継承しWebSocket関連のBean定義をカスタマイズする

  @Autowired
  private NtssApplicationProperties properties;

  @Autowired
  private SessionManager sessionCtrl;

  @Autowired
  private LogService logService;

  @Override
  public void registerWebSocketHandlers(WebSocketHandlerRegistry registry) {
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("Websocket use : " + properties.getWebsocket().isUse() + " / path : " + properties.getWebsocket().getPath());
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    if (properties.getWebsocket().isUse()) {
      // WebSocketのエンドポイント(接続時に指定するエンドポイント)を指定
      registry.addHandler(messageHandler(), properties.getWebsocket().getPath())
      .setAllowedOrigins("*") // クロスドメイン許可
      .addInterceptors(new HttpSessionHandshakeInterceptor());

      // アプリケーションが稼働しているサーバ種別[0：DeviceSrv/1：WebAppSrv]
      eventLogMessage.setLogMessage("Server Type : " + properties.getServerType());
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      this.sessionCtrl.setServerType(properties.getServerType());

      //　アプリケーションが動作しているサーバーのIPアドレスを取得しセッション管理に登録する
      String ip;
      try {
        ip = InetAddress.getLocalHost().getHostAddress();
      } catch (UnknownHostException e) {
        // TODO Auto-generated catch block
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
        EventLogMessage eventLogMessageNew = new EventLogMessage();
        eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
        logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end

        // Resolve (first/primary) private IP
        ip = EC2MetadataUtils.getInstanceInfo().getPrivateIp();
      }
      eventLogMessage.setLogMessage("Server IP : " + ip);
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      this.sessionCtrl.setLocalIp( ip );

      //　WSクライアント死活判定間隔
      eventLogMessage.setLogMessage("WSClient Alive Interval : " + properties.getWebsocket().getAliveInterval());
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      this.sessionCtrl.setAliveInterval(properties.getWebsocket().getAliveInterval());

      // REST-API呼び出し用Urlヘッダー部
      eventLogMessage.setLogMessage("Request Url Header : " + properties.getUrl().getRequestHTTP());
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      this.sessionCtrl.setRequestHTTP(properties.getUrl().getRequestHTTP());

      //　別サーバー上の通知サービスを呼び出すための設定をセッション管理に登録する
      eventLogMessage.setLogMessage("Send Message API[WebAppSrv]: " + properties.getUrl().getPostMsgAPI_WebAppSrv());
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      this.sessionCtrl.setPostMsgAPI_WebAppSrv(properties.getUrl().getPostMsgAPI_WebAppSrv());

      //　別サーバー上の通知サービスを呼び出すための設定をセッション管理に登録する
      eventLogMessage.setLogMessage("Send Message API[DeviceSrv]: " + properties.getUrl().getPostMsgAPI_DeviceSrv());
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      this.sessionCtrl.setPostMsgAPI_DeviceSrv(properties.getUrl().getPostMsgAPI_DeviceSrv());

      // EC2上のデバイスエッジ死活管理通知サービスを呼び出すための設定をセッション管理に登録する
      eventLogMessage.setLogMessage("EC2 Url: " + properties.getUrl().getHostName());
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      eventLogMessage.setLogMessage("DeviceEdge Status API: " + properties.getUrl().getPostDEStatusAPI());
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      eventLogMessage.setLogMessage("DeviceEdge Status Post Dilay: " + properties.getUrl().getPostDEStatusDilay());
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      this.sessionCtrl.setHostName(properties.getUrl().getHostName());
      this.sessionCtrl.setPostDEStatusAPI(properties.getUrl().getPostDEStatusAPI());
      this.sessionCtrl.setPostDEStatusDilay(properties.getUrl().getPostDEStatusDilay());
    }
  }
  @Bean
  public WebSocketHandler messageHandler() {
      return new MessageHandler();
  }

  /**
   * WebSocket と Scheduled を併用すると、Spring Boot 2.xにした場合に
   * java.lang.IllegalStateException: Unexpected use of scheduler　で落ちる
   * 公式にはSpring Framework 5.0.5で発生を確認、修正はまだされていない
   * https://jira.spring.io/browse/SPR-16705
   *
   * このメソッドを記述すると動く
   * 参考：
   * https://stackoverflow.com/questions/49742401/spring-websocket-simple-example-java-lang-illegalstateexception-unexpected-us
   * @return
   */
  @Bean
  public TaskScheduler taskScheduler() {
      return new ConcurrentTaskScheduler(Executors.newSingleThreadScheduledExecutor());
  }
}
