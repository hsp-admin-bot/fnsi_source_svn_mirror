package jp.co.nikkiso.ntss.device_edge;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

import lombok.Data;

/**
 * WebScoket通知機能のプロパティクラス.
 */
@Component
@ConfigurationProperties(prefix = "ntss.device-edge.web-socket-notify")
@Data
public class WebSocketNotifyProperties {

  /**
   * サービスライン用通知設定
   */
  private AppSv appSv;
  /**
   * デバイスライン用通知設定
   */
  private DeviceSv deviceSv;

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

  /**
   * デバイスライン用WebScoket通知設定クラス
   */
  @Data
  public static class DeviceSv {

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
