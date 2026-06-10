package jp.co.nikkiso.ntss.device_edge_updater.service.plan;

public interface PlanInfoService {

  /**
   * 更新予定情報を更新する
   * @param facilityCd 施設コード
   * @param deviceEdgeNo デバイスエッジ番号
   * @param strSeqNo 管理番号
   * @param planDate 予約日時
   * @return
   */
  int savePlanInfo(String facilityCd, Integer deviceEdgeNo, String strSeqNo, String planDate);

}
