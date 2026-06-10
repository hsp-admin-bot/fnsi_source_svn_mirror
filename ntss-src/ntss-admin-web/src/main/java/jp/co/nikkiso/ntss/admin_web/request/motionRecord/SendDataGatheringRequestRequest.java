package jp.co.nikkiso.ntss.admin_web.request.motionRecord;

import lombok.Data;

/**
 * データ収集API呼び出しのrequestクラス.
 */
@Data
public class SendDataGatheringRequestRequest {

  /**
   * base64化された文字列.
   */
  private String content;

}
