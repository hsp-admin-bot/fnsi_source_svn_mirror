package jp.co.nikkiso.ntss.device_edge_updater_front.response;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ResponseUpdateInfo {

  /**
   * 管理番号.
   */
  private Long updaterManageNo;

  /**
   * 指示名.
   */
  private String orderKind;

  /**
   * 指示識別子名.
   */
  private Integer orderSubKind;
  
  /**
   * バケットのパス
   */
  private String s3Bucket;
  
  /**
   * ファイル名
   */
  private String fileName;
}
