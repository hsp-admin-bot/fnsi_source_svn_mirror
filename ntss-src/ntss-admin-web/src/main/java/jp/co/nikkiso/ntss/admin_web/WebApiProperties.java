package jp.co.nikkiso.ntss.admin_web;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

import lombok.Data;

/**
 * web-apiアクセスのプロパティクラス.
 */
@Component
@ConfigurationProperties(prefix = "ntss.admin-web")
@Data
public class WebApiProperties {

  /**
   * web-apiの設定.
   */
  private WebApi webApi;

  /**
   * web-apiの設定クラス.
   */
  @Data
  public static class WebApi {

    /**
     * DeviceサーバのファイルアップロードAPI呼び出しURL.
     */
    private String url;

    /**
     * ファイルアップロードAPIのパス
     */
    private String upload;

    /**
     * 次患者更新APIのパス
     */
    private String setNextPat;

    /**
     * 現患者クリアAPIのパス
     */
    private String currentPatClear;

    /**
     * API呼び出しのヘッダーネーム.
     */
    private String headerName;

    /**
     * 呼び出しのヘッダーバリュー.
     */
    private String headerValue;
  }
}
