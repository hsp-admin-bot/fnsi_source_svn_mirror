package jp.co.nikkiso.ntss.admin_web.request.motionRecord;

import lombok.Data;

/**
 * サービス対応区分更新APIのRequestクラス.
 */
@Data
public class UpdateServiceSupportRequest {

  /**
   * 装置動作記録番号.
   */
  private Long motionRecordNo;

  /**
   * 更新するサービス対応区分
   */
  private String serviceSupportType;

}
