package jp.co.nikkiso.ntss.device_edge;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

import lombok.Data;

/**
 * WebApi呼び出しのプロパティクラス.
 */
@Component
@ConfigurationProperties(prefix = "ntss.device-edge.web-api")
@Data
public class WebApiCallProperties {
  /**
   * API呼び出しURL. 例（http://localhost:8080/ntss-web-api)
   */
  private String Url;
}
