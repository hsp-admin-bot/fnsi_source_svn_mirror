package jp.co.nikkiso.ntss.device_edge.request;

import lombok.Data;

/**
 * ファイルダウンロードAPIのRequestクラス.
 */

@Data
public class DownloadRequest {

  /**
   * ファイル名.
   */
  private final String filename;

  /**
   * バケット.
   */
  private final String bucket;
}
