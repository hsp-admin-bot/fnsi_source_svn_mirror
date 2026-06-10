package jp.co.nikkiso.ntss.client_comm;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

import lombok.Data;

/**
 * アプリケーションのプロパティクラスです。
 */
@Component
@ConfigurationProperties(prefix="ntss.client-comm")
@Data
public class NtssApplicationProperties {
  /**
   * アプリケーションが稼働しているサーバー種別[0：DeviceSrv/1：WebAppSrv] 
   */
  private int serverType;
  
  private WebsocketProperties websocket;
  
  private urlProperties url;
  
  
  @Data
  public static class WebsocketProperties{
    /**
     * WebSocket使用有無
     */
    private boolean use;    
    /**
     * WebSocketパス名
     */
    private String path;
   
    /**
     * WSクライアント死活判定間隔[分] 
     */
    private int aliveInterval;
    
    
    /**
     * 
     * @return
     */
    public boolean isUse() {
      return use;
    }
  }
  
  @Data
  public static class urlProperties{
    
    /**
     * 別サーバーへの通知APIを呼び出すためのhttp部分
     */
    private String requestHTTP;
    
    /**
     * WebAppSrv上のメッセージ通知APIを呼び出すためのAPI部分[ポート番号/API]
     */
    private String postMsgAPI_WebAppSrv;
    /**
     * DeviceSrv上のメッセージ通知APIを呼び出すためのAPI部分[ポート番号/API]
     */
    private String postMsgAPI_DeviceSrv;
    
    /**
     * EC2APIの呼び出し先ホスト名
     */
    private String hostName;
      
    /**
     * デバイスエッジ死活監視の通知APIを呼び出すためのAPI部分[ポート番号/API]
     */
    private String postDEStatusAPI;
    
    /**
     * デバイスエッジ死活監視の通知APIを呼び出すための遅延時間[分]
     */
    private int postDEStatusDilay;
  }
}
