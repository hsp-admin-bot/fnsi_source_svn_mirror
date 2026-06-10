package jp.co.nikkiso.ntss.alive_moni.service.statusUpdate;

import java.sql.Timestamp;

public interface StatusUpdateService {

  /**
   * ステータス更新処理用のレスポンス
   */
  public class DoUpdateStatusResponse{
    /**
     * 通知必要フラグ
     */
    public boolean isNotice;
    public DoUpdateStatusResponse() {
      this.isNotice = false;
    }
  }
  /**
   * デバイスエッジ状態を受け取った際の状態更新処理
   * @param facilityCd 施設コード
   * @param deviceEdgeNo デバイスエッジ番号
   * @param edgeStatus エッジのステータス
   * @param nowDate 登録日時
   * @return
   * @throws Exception 例外発生可能性あり
   */
  public DoUpdateStatusResponse DoUpdateOfDeviceEdgeStatus(String facilityCd, Integer deviceEdgeNo, String edgeStatus, Timestamp nowDate) throws Exception;
  /**
   * デバイスエッジ状態+装置状態を受け取った際の状態更新処理
   * @param facilityCd 施設コード
   * @param deviceEdgeNo デバイスエッジ番号
   * @param edgeStatus エッジのステータス
   * @param machineInfo 装置状態
   * @param nowDate 登録日時
   * @return
   * @throws Exception 例外発生可能性あり
   */
  public DoUpdateStatusResponse DoUpdateOfDeviceEdgeWithMachineStatus(String facilityCd, Integer deviceEdgeNo, String edgeStatus, String machineInfo, Timestamp nowDate) throws Exception;

}
