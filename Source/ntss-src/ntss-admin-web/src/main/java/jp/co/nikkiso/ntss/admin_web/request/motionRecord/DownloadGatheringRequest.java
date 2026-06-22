package jp.co.nikkiso.ntss.admin_web.request.motionRecord;

import lombok.Data;

/**
 * データ収集記録のファイルダウンロードAPIのRequestクラス.
 */
@Data
public class DownloadGatheringRequest {

  /**
   * ファイル名.
   */
  private String filename;

  /**
   * バケット.
   */
  private String bucket;

}
