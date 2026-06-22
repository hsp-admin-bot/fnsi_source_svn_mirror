package jp.co.nikkiso.ntss.admin_web.request.mstSynchro;

import lombok.Data;

/**
 * マスタ同期APIのRequestクラス.
 */
@Data
public class MstSynchroRequest {
  
  /**
   * 同期対象マスタ名(mst_machine、など).
   */
  private String mstTable;
  
  /**
   * 施設コード
   */
  private String facilityCd;
  
  /**
   * デバイスエッジ番号
   */
  private Integer deviceEdgeNo;
}
