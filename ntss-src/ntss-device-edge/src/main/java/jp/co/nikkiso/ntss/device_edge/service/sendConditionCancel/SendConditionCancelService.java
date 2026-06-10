package jp.co.nikkiso.ntss.device_edge.service.sendConditionCancel;

import jp.co.nikkiso.ntss.device_edge.response.sendConditionCancel.SendConditionCancelResponse;
import jp.co.nikkiso.ntss.core.entity.MstMachine;

public interface SendConditionCancelService {

  public SendConditionCancelResponse DoCancelDBAction(Long ordNo, MstMachine machine) throws Exception;

  // add AWSとDEの通信断からの復旧 --趙-- start
  public SendConditionCancelResponse DoCancelDBActionCommFail(Long ordNo, MstMachine machine) throws Exception;
  // add AWSとDEの通信断からの復旧 --趙-- end

  /**
   * 条件送信キャンセル
   * 1. pat_mainの更新
   *  pat_main.acceptance_status_infoの配列からオーダー番号に一致する情報を削除する
   * @param patId 患者ＩＤ
   * @param ordNo オーダー番号
   * @return
   */
  public SendConditionCancelResponse resetPatMain(Long patId, Long ordNo);

  /**
   * 条件送信キャンセル
   * 2 ord_mainの更新
   *   条件送信開始日時を削除＋ステータスを条件送信前に書き換える
   *   それ以外の実績は残す　
   * @param ordNo ordNo
   * @return
   */
  public SendConditionCancelResponse resetOrdMain(Long ordNo);

  /**
   * 4 mnt_motion_recordの装置記録のorder_noを削除
   * @param facilityCd
   * @param machineTypeCd
   * @param machineSerial
   * @return
   */
  public SendConditionCancelResponse resetMotionRecord(String facilityCd, String machineTypeCd, String machineSerial, Long ordNo);

  /**
   * 5 mni_monitorのorder_noを削除
   * 血圧・体温・血糖値などはorder_no振替後にも引き継ぐ
   * @param facilityCd
   * @param machineTypeCd
   * @param machineSerial
   * @return
   */
  public SendConditionCancelResponse resetMniMonitor(String facilityCd, String machineTypeCd, String machineSerial, Long ordNo);

  /**
   * 6 チェックリストのデータを削除
   * @param ordNo
   * @return
   */
  public SendConditionCancelResponse resetCheckList(Long ordNo);

  /**
   * 7 mnt_machine_stateのデータを削除
   * @param ordNo
   * @return
   */
  public SendConditionCancelResponse resetMachineState(String facilityCd, String machineTypeCd, String machineSerial, Long ordNo);

}
