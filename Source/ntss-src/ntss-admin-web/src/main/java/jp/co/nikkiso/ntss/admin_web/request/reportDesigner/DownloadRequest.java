package jp.co.nikkiso.ntss.admin_web.request.reportDesigner;

import lombok.Data;

/**
 * ファイルダウンロードAPIのRequestクラス.
 */
@Data
public class DownloadRequest {

  /**
   * ファイル名.
   */
  private String filename;

  /**
   * バケット.
   */
  private String bucket;
  // add 9601 印刷サーバにて帳票の印刷が行われない　吉 start
  private String serviceIp;
// add 9601 印刷サーバにて帳票の印刷が行われない　吉 end

}
