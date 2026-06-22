package jp.co.nikkiso.ntss.device_edge_updater_front.config;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

import lombok.Data;

/**
 * アプリケーションのプロパティクラスです。
 */
@Component
@ConfigurationProperties(prefix="ntss.device-edge-updater-front")
@Data
public class MyProperties {
  
  private RestProperties rest;
  private WebsocketProperties websocket;
  private S3Properties s3;

  @Data
  public static class RestProperties{
    /**
     * アップロードAPI
     */
    private String upload;
  }

  @Data
  public static class WebsocketProperties{
    /**
     * APIのURI部
     */
    private String senduri;
    /**
     * API宛先ポート
     */
    private String port;
  }
  
  @Data
  public static class S3Properties {
    /**
     * アプリケーション差し替え用バケット
     */
    private String app;
    /**
     * アップデータ差し替え用バケット
     */
    private String updater;
    /**
     * 設定アップロード用バケット
     */
    private String confUp;
    /**
     * 設定差し替え用バケット
     */
    private String confdown;
    /**
     * ログファイル格納バケット
     */
    private String log;
  }
}
