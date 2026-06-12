package jp.co.nikkiso.ntss.admin_web;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

/**
 * selfupdateのプロパティクラス.
 */
@Component
@ConfigurationProperties(prefix = "ntss.admin-web")
@Data
public class SelfUpdateProperties {

  /**
   * application-udの設定.
   */
  private ApplicationUd applicationUd;

  /**
   * application-udの設定クラス.
   */
  @Data
  public static class ApplicationUd {

    /**
     * file-location.
     */
    private String fileLocation;
  }
}
