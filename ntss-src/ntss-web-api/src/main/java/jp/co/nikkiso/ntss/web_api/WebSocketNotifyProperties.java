package jp.co.nikkiso.ntss.web_api;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

import lombok.Data;

/**
 * WebScoket通知機能のプロパティクラス.
 */
@Component
@ConfigurationProperties(prefix = "ntss.web-api.web-socket-notify")
@Data
public class WebSocketNotifyProperties {

  /**
   * サービスライン用通知設定
   */
  private AppSv appSv;

  /**
   * サービスライン用WebScoket通知設定クラス
   */
  @Data
  public static class AppSv {

    /**
     * メッセージ送信API呼び出しPort.
     */
    private Integer wsPort;
    /**
     * メッセージ送信API呼び出しURL.
     */
    private String wsAPI;

    /**
     * メッセージ送信API呼び出しヘッダーキー
     */
    private String headerName;

    /**
     * メッセージ送信API呼び出しヘッダーバリュー
     */
    private String headerValue;
  }
}
