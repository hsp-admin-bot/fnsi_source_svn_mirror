package jp.co.nikkiso.ntss.admin_web.service.master.machine;

import java.util.List;

import jp.co.nikkiso.ntss.admin_web.request.masterMaintenance.machine.MstMachineChangeMachineRequest;
import jp.co.nikkiso.ntss.admin_web.request.masterMaintenance.machine.MstMachineSwitchOfflineRequest;
import jp.co.nikkiso.ntss.core.entity.MstMachineType;
import jp.co.nikkiso.ntss.core.entity.MstDeviceEdge;
import jp.co.nikkiso.ntss.core.entity.MstMachine;

public interface MstMachineService {
  // mod #8118 2022/12/06 装置マスタから装置を削除すると治療状況ベッドレイアウトマスタが編集不可 dou start
  List<MstMachine> selectByFacility(String facilityCd);
  // mod #8118 2022/12/06 装置マスタから装置を削除すると治療状況ベッドレイアウトマスタが編集不可 dou end
  List<MstMachineType> selectMachineTypeAll();

  List<MstDeviceEdge> selectDeviceEdgeByFacilityCd(String facilityCd);

  // add #11015 デバイスエッジマスタで項目を削除した際に関連マスタで表示不正 zkm start
  List<MstDeviceEdge> selectAllDeviceEdgeByFacilityCd(String facilityCd);
  // add #11015 デバイスエッジマスタで項目を削除した際に関連マスタで表示不正 zkm end

  MstMachine selectMachine(String machineTypeCd, String machineSerial, String facilityCd);

  int deleteMachine(MstMachine mstMachine);
  //9871 addデバイスエッジが並び順の通りに表示しない zhao start
  List<MstDeviceEdge> selectByOrderItem(String facilityCd,List<MstDeviceEdge> res_device_edge);
  //9871 addデバイスエッジが並び順の通りに表示しない zhao end

  /**
   * オフライン装置の工程状態を準備"07"に変更
   * @param facilityCd 施設コード
   * @param codeList mst_machine.machine_no
   */
  int updateStateOfflineMachines(String facilityCd, List<Long> codeList);
  /**
   * オンライン装置の工程状態を未設定に変更
   * @param facilityCd 施設コード
   * @param codeList mst_machine.machine_no
   */
  int updateStateOnlineMachines(String facilityCd, List<Long> codeList);

  /**
   * 指定の装置の工程を準備"07"に変更
   * @param facilityCd 施設コード
   * @param codeList mst_machine.machine_no
   * @return
   */
  int updateProcStateToDefault(String facilityCd, List<Long> codeList);

  /**
   * 指定の装置の状態を初期値0に変更
   * @param facilityCd 施設コード
   * @param codeList mst_machine.machine_no
   * @return
   */
  int updateMachineStatusToDefault(String facilityCd, List<Long> codeList);

  /**
   * 条件送信済み～治療中の装置を取得する
   * @param facilityCd 施設コード
   * @return
   */
  List<MstMachine> selectEntryMachineList(String facilityCd);

  /* add by zhouyingying  2023-02-01 [Transaction] start */
  /**
   *（装置自動登録）通知指示
   * @param procMode
   * @return
   */
  boolean notificationMstFindMachine(Integer procMode, String facilityCd);
  /* add by zhouyingying  2023-02-01 [Transaction] end */

  /* add by zhouyingying  2023-02-01 [Transaction] start */
  /**
   * 型式や通信フォーマットを切り替えた装置のステータスを初期値状態にする
   * @param request
   */
  void updateChangeMachine(MstMachineChangeMachineRequest request);
  /* add by zhouyingying  2023-02-01 [Transaction] end */

  /* add by zhouyingying  2023-02-01 [Transaction] start */
  /**
   * オンラインからオフライン装置に切り替えられた装置のステータスを準備状態にする
   * @param request
   */
  void updateStateOffline(MstMachineSwitchOfflineRequest request);
  /* add by zhouyingying  2023-02-01 [Transaction] end */

  // #11124 2025.08.26 add 酸素飽和度対応 TDC高村 start
  /**
   * 該当施設からΔSO2を使用する装置件数を取得
   *
   * @param facilityCd 施設コード
   * @return ΔSO2を使用する装置件数
   */
  Long getMachineSo2OptCount(String facilityCd);
  // #11124 2025.08.26 add 酸素飽和度対応 TDC高村 end
}
