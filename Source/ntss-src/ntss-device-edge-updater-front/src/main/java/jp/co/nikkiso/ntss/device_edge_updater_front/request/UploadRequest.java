package jp.co.nikkiso.ntss.device_edge_updater_front.request;

import org.springframework.core.io.Resource;

import lombok.Data;

/**
 * ファイルアップロードAPIのRequestクラス.
 */
@Data
public class UploadRequest {

  /**
   * ファイル名.
   */
  private final Resource file;

  /**
   * バケット.
   */
  private final String filePath;
}
