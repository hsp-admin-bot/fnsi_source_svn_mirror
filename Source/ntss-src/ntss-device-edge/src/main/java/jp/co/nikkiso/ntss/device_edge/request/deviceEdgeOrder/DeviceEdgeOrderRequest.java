package jp.co.nikkiso.ntss.device_edge.request.deviceEdgeOrder;

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
}
