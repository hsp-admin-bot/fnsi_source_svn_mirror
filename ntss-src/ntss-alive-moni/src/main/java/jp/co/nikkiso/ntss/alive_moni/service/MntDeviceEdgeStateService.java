package jp.co.nikkiso.ntss.alive_moni.service;

import java.util.List;

import jp.co.nikkiso.ntss.core.entity.MntDeviceEdgeState;

public interface MntDeviceEdgeStateService {
  /**
   * デバイスエッジの状態取得
   * @param facilityCd 施設コード
   * @param deviceEdgeNo デバイスエッジ番号
   * @return
   */
  List<MntDeviceEdgeState> findById(String facilityCd, Integer deviceEdgeNo);

  /**
   * デバイスエッジ状態の新規登録
   * @param deviceEdgeState デバイスエッジ状態
   * @return
   */
  int insert(MntDeviceEdgeState deviceEdgeState);

  /**
   * デバイスエッジ状態の更新
   * @param deviceEdgeState デバイスエッジ状態
   * @return
   */
  int update(MntDeviceEdgeState deviceEdgeState);

  /**
   * デバイスエッジのメール送信状態の更新
   * @param deviceEdgeState デバイスエッジ状態
   * @return
   */
  int updateSendMailStatus(MntDeviceEdgeState deviceEdgeState);
}
