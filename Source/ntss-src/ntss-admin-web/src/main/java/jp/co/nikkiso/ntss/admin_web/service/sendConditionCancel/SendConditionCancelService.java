package jp.co.nikkiso.ntss.admin_web.service.sendConditionCancel;

import jp.co.nikkiso.ntss.admin_web.response.sendConditionCancel.SendConditionCancelResponse;
import jp.co.nikkiso.ntss.core.entity.MstMachine;
import jp.co.nikkiso.ntss.core.entity.OrdMain;

import java.util.List;

public interface SendConditionCancelService {

  /**
   * 現患者クリア
   * @param facility_cd 施設コード
   * @param machine_type_cd 型式コード
   * @param machine_serial 製造番号
   * @return
   */
  public SendConditionCancelResponse currentPatClear(String facilityCd, String machineTypeCd, String machineSerial) ;

  /**
   * 条件送信キャンセル（キャンセル対象が対象オーダー番号と一致する場合はキャンセルしない）
   * @param facilityCd 施設コード
   * @param bedCd 対象ベッドコード
   * @param baseOrdNo キャンセルしないオーダー番号
   * @return
   */
  public SendConditionCancelResponse doCancel(String facilityCd, Long bedCd, Long baseOrdNo);

  /**
   * 条件送信キャンセル
   * @param facilityCd 施設コード
   * @param bedCd 対象ベッドコード
   * @return
   */
  public SendConditionCancelResponse doCancel(String facilityCd, Long bedCd);

  /**
   * 条件送信キャンセル（キャンセル対象が対象オーダー番号と一致する場合はキャンセルしない）
   * @param machine 対象装置
   * @param targetOrdNo 対象オーダー番号
   * @param baseOrdNo キャンセルしないオーダー番号
   * @return
   */
  public SendConditionCancelResponse doCancel(MstMachine machine, Long targetOrdNo, Long baseOrdNo);

  // bug 5628 修正 chen start
  /**
   * 条件送信キャンセル（キャンセル対象が対象オーダー番号と一致する場合はキャンセルしない）
   * @param machine 対象装置
   * @param targetOrdNo 対象オーダー番号
   * @param baseOrdNo キャンセルしないオーダー番号
   * @param mntMachineOrdNo キャンセルしないオーダー番号
   * @return
   */
  public SendConditionCancelResponse doCancel(MstMachine machine, Long targetOrdNo, Long baseOrdNo, Long mntMachineOrdNo);
  // bug 5628 修正 chen end

  /**
   * 条件送信キャンセル
   * @param machine 対象装置
   * @param targetOrdNo 対象オーダー番号
   * @return
   */
  public SendConditionCancelResponse doCancel(MstMachine machine, Long targetOrdNo);

  /**
   * 条件送信キャンセル
   * 1. pat_mainの更新
   *  pat_main.acceptance_status_infoで配列にあるオーダー番号の情報を削除する
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
   * 条件送信キャンセル
   * 3 mnt_machine_stateの更新(次患者更新) ★現患者クリアも必要では
   * @param facility_cd 施設コード
   * @param machine_type_cd 型式コード
   * @param machine_serial 製造番号
   * @return
   */
  public SendConditionCancelResponse resetMachineStateNextPat(String facilityCd, String machineTypeCd, String machineSerial) ;

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

  // add #10739 コンバート施設で指示受け(治療単位)が表示されない 関 start
  /**
   * 8 pat_ind_approveのデータを削除
   * @param ordNos
   * @return
   */
  public SendConditionCancelResponse resetPatIndApprove(List<Long> ordNos);
  // add #10739 コンバート施設で指示受け(治療単位)が表示されない 関 end

  //add FNSI改修401 房 start
  /**
   * 条件送信キャンセル（キャンセル対象が対象オーダー番号と一致する場合はキャンセルしない）
   * @param machine 対象装置
   * @param targetOrdNo 対象オーダー番号
   * @param baseOrdNo キャンセルしないオーダー番号
   * @param flag 改修フラグ
   * @return
   */
  public SendConditionCancelResponse doCancel(MstMachine machine, Long targetOrdNo, Long baseOrdNo, String flag);

  /**
   * 条件送信キャンセル（キャンセル対象が対象オーダー番号と一致する場合はキャンセルしない）
   * @param facilityCd 施設コード
   * @param bedCd 対象ベッドコード
   * @param baseOrdNo キャンセルしないオーダー番号
   * @param flag 改修フラグ
   * @return
   */
  public SendConditionCancelResponse doCancel(String facilityCd, Long bedCd, Long baseOrdNo, String flag);

  //del #10412 次患者更新関連全体見直し対応 朴 start
//  // mod #10132 時間外加算処理不正 dengshen start
//  /**
//   * 条件送信キャンセル（キャンセル対象が対象オーダー番号と一致する場合はキャンセルしない）
//   * @param facilityCd 施設コード
//   * @param bedCd 対象ベッドコード
//   * @param baseOrdNo キャンセルしないオーダー番号
//   * @param flag 改修フラグ
//   * @return
//   */
//  public SendConditionCancelResponse cancelSendMessage(String facilityCd, Long bedCd, Long baseOrdNo, String flag);
//  // mod #10132 時間外加算処理不正 dengshen start
  //del #10412 次患者更新関連全体見直し対応 朴 end

  /**
   * 6 チェックリストのデータを削除
   * @param ordNo オーダー番号
   * @param facilityCd 施設コード
   * @param flag 改修フラグ
   * @return
   */
  public SendConditionCancelResponse resetCheckList(Long ordNo, String facilityCd, String flag);
  //add FNSI改修401 房 start

  //add #10412 次患者更新関連全体見直し対応 朴 start
  /**
   * 条件送信キャンセル（キャンセル対象が対象オーダー番号と一致する場合はキャンセルしない）
   * @param facilityCd
   * @param bedCd
   * @param targetOrdNo
   * @return
   */
  public SendConditionCancelResponse doCancel2(String facilityCd, Long bedCd, Long targetOrdNo);

  /**
   * 条件送信キャンセル（キャンセル対象が対象オーダー番号と一致する場合はキャンセルしない）
   * @param facilityCd
   * @param machineTypeCd
   * @param machineSerial
   * @param targetOrdMain
   * @return
   */
  public SendConditionCancelResponse doCancel2(String facilityCd, String machineTypeCd, String machineSerial, OrdMain targetOrdMain);
  //add #10412 次患者更新関連全体見直し対応 朴 end
}
