package jp.co.nikkiso.ntss.m_notice.service;

import java.util.List;

import jp.co.nikkiso.ntss.core.entity.MntDeviceEdgeState;
import jp.co.nikkiso.ntss.core.entity.MntMotionRecord;

/**
 * デバイスエッジ状態管理サービス
 */
public interface MntDeviceEdgeStateService {

  /**
   * 施設コード、デバイスエッジ番号に該当するデバイスエッジ状態管理情報を取得.
   *
   * @param facilityCd 施設コード
   * @param deviceEdgeNo デバイスエッジ番号
   * @return 該当する{@link jp.co.nikkiso.ntss.core.entity._MntDeviceEdgeState}
   */
  List<MntDeviceEdgeState> selectByKey(String facilityCd, Integer deviceEdgeNo);

  /**
   * デバイスエッジ状態管理情報のメール送信状況を更新.
   *
   * @param mntDeviceEdgeState デバイスエッジ状態
   * @return 更新件数
   */
  int updateSendMailStatus(MntDeviceEdgeState mntDeviceEdgeState);

  /**
   * イベントがデバイスエッジ通信状態の変更メール送信だった場合、送信状況を更新する
   * @param mntMotionRecord 通知イベント内容
   * @return 更新件数
   */
  int updateSendMailFinish(MntMotionRecord mntMotionRecord);
}
