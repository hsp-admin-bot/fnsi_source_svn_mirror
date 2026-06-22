package jp.co.nikkiso.ntss.admin_web;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

import lombok.Data;

/**
 * データ収集のプロパティクラス.
 */
@Component
@ConfigurationProperties(prefix = "ntss.admin-web")
@Data
public class DataGatheringProperties {

  /**
   * データ収集設定.
   */
  private DataGathering dataGathering;

  /**
   * データ収集設定クラス.
   */
  @Data
  public static class DataGathering {

    /**
     * Deviceサーバのデータ収集API呼び出しURL.
     */
    private String url;

    /**
     * データ収集API呼び出しのヘッダーネーム.
     */
    private String headerName;

    /**
     * データ収集API呼び出しのヘッダーバリュー.
     */
    private String headerValue;
  }
}
