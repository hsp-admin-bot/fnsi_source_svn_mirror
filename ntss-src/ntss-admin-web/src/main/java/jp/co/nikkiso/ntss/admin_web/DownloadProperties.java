package jp.co.nikkiso.ntss.admin_web;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

import lombok.Data;

/**
 * downloadのプロパティクラス.
 */
@Component
@ConfigurationProperties(prefix = "ntss.admin-web")
@Data
public class DownloadProperties {

  /**
   * application-dlの設定.
   */
  private ApplicationDl applicationDl;

  /**
   * application-dlの設定クラス.
   */
  @Data
  public static class ApplicationDl {

    /**
     * file-location.
     */
    private String fileLocation;
  }
}
