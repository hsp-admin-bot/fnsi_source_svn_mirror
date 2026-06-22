package jp.co.nikkiso.ntss.admin_web.response.mstSynchro;

import java.util.List;

import lombok.AllArgsConstructor;

/**
 * 緊急発報マスタ同期処理のResponse.
 */
@AllArgsConstructor
public class SynchroMstMNoticeResponse {
  
  /**
   * 同期失敗したデバイスエッジ情報のリスト.
   */
  public List<MstDeviceEdge> failedDeviceEdgeList;

  /**
   * 成功/失敗フラグ.
   */
  public boolean isSuccess;

}
