package jp.co.nikkiso.ntss.device_edge.request.hostNotify;

import lombok.Data;

@Data
public class IntervalCheckRequest {
  /**
   * 施設コード
   */
  private String facilityCd;
  /**
   * デバイスエッジ番号
   */
  private Integer deviceEdgeNo;
}
