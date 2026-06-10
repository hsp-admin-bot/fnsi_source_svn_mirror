package jp.co.nikkiso.ntss.device_edge.service.indApprove;

public interface IndApproveService {

  /**
   * 治療状況マップ表示用指示変更markerの状態を確定とする処理
   * @param ordNo
   * @return
   */
  public int IndApprovedForStatusMap(Long ordNo);
  // add #10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 shiyw 20240529 start
  void indApprovedForCheckContentAndApproveContent(Long ordNo);
  // add #10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 shiyw 20240529 end
}
