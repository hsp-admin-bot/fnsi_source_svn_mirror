package jp.co.nikkiso.ntss.device_edge_updater.request;

import lombok.Data;

@Data
public class VersionRequest {

  /**
   * 施設コード
   */
  private String facilityCd;
  /**
   * デバイスエッジ番号
   */
  private Integer deviceEdgeNo;
  /**
   * デバイスエッジのログに出力するversion情報をまるまる文字列化したもの
   *    ～～～～
   *    ・～～～.exe     1.1.1
   *    ・～～～.exe     1.1.1
   */
  private String content;
}
