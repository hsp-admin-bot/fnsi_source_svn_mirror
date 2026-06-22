package jp.co.nikkiso.ntss.admin_web;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

import lombok.Data;

/**
 * device-edge-manageアクセスのプロパティクラス.
 */
@Component
@ConfigurationProperties(prefix = "ntss.admin-web")
@Data
public class DeviceEdgeManageProperties {

  /**
   * device-edge-manageの設定.
   */
  private DeviceEdgeManage deviceEdgeManage;

  /**
   * device-edge-manageの設定クラス.
   */
  @Data
  public static class DeviceEdgeManage {

    /**
     * 設定ファイル保存Path.
     */
    private String confUploadPath;

    /**
     * s3バケット.
     */
    private String s3Bucket;
  }
}
