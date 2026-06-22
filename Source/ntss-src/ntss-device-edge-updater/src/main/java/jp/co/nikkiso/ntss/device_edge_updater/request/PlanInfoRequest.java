package jp.co.nikkiso.ntss.device_edge_updater.request;

import lombok.Data;

@Data
public class PlanInfoRequest {

  /**
   * 施設コード
   */
  private String facilityCd;
  /**
   * デバイスエッジ番号
   */
  private Integer deviceEdgeNo;
  /**
   * 管理番号
   */
  private String seqNo;

  /**
   * 予約日時 yyyyMMdd
   */
  private String planDate;
}
