package jp.co.nikkiso.ntss.admin_web.request.deviceEdgeOrder;

import lombok.Data;

@Data
public class DeviceEdgeOrderRequest {
  /**
   * 治療番号
   */
  private Long ordNo;
  /**
   * 装置番号
   */
  private Long machineNo;
  /**
   * デバイスエッジ番号
   */
  private Integer deviceEdgeNo;
  /**
   * 施設コード
   */
  private String facilityCd;
  /**
   * 患者Id
   */
  private Long patId;

  /**
   * 送信フラグ[0：不要/1：必要]
   */
  private String isSendable = "0";
}
