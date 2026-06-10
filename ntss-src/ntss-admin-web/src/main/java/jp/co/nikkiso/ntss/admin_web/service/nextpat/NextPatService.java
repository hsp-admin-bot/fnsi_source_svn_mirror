package jp.co.nikkiso.ntss.admin_web.service.nextpat;

import jp.co.nikkiso.ntss.core.entity.MntMachineState;
import jp.co.nikkiso.ntss.core.entity.MstComsvSetting;
import jp.co.nikkiso.ntss.core.entity.MstMachine;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.PatMain;
import jp.co.nikkiso.ntss.core.entity.PatPersonalMain;
import jp.co.nikkiso.ntss.core.entity.PatUnique;

import java.time.LocalDateTime;
import java.util.List;

public interface NextPatService {

  /**
   * 次患者更新判定処理（マスタ変更）
   *
   * @param facilityCd
   * @param masterPhysicalName
   * @param beforeMstList 変更前Mst
   * @param afterMstList 変更後Mst
   * @return List<OrdMain>
   * @description パラメータで条件送信キャンセル処理しない場合がある
   */
  public List<OrdMain> FilterNextPatInfo1or2ChangedForMst(String facilityCd, String masterPhysicalName, List<Object> beforeMstList, List<Object> afterMstList);

  /**
   * 次患者更新判定処理（患者情報）
   *
   * @param facilityCd
   * @param beforePatMain 変更前PatMain
   * @param afterPatMain 変更後PatMain
   * @param beforePatPersonalMain 変更前PatPersonalMain
   * @param afterPatPersonalMain 変更後PatPersonalMain
   * @return void
   * @description パラメータで条件送信キャンセル処理しない場合がある
   */
  public boolean CheckDoCallNextPatChangeForPat(String facilityCd, PatMain beforePatMain, PatMain afterPatMain, PatPersonalMain beforePatPersonalMain, PatPersonalMain afterPatPersonalMain);

  /**
   * 次患者更新判定処理　次患者情報メモ（患者情報）
   *
   * @param facilityCd
   * @param bedCd
   * @param beforePatMain 変更前PatMain
   * @param afterPatMain 変更後PatMain
   * @param beforePatPersonalMain 変更前PatPersonalMain
   * @param afterPatPersonalMain 変更後PatPersonalMain
   * @return void
   * @description パラメータで条件送信キャンセル処理しない場合がある　
   */
  public boolean CheckDoCallNextPatChangeForPatMemo(String facilityCd, Integer bedCd, PatMain beforePatMain, PatMain afterPatMain, PatPersonalMain beforePatPersonalMain, PatPersonalMain afterPatPersonalMain, MstComsvSetting mstComsvInfo);

  /**
   * 条件送信キャンセル・次患者更新実行纏め処理 治療情報関連次患者情報１or２で変更が発生したかのチェック
   *
   * @param facilityCd
   * @param beforePatUnique 変更前PatUnique
   * @param afterPatUnique 変更後PatUnique
   * @return List<OrdMain>
   * @description 次患者情報１or２で変更が発生した場合の後で呼び出す元側でCallNextPatChangeを呼び出す必要あり
   */
  public List<OrdMain> FilterNextPatInfo1or2ChangedForDw(String facilityCd, PatUnique beforePatUnique, PatUnique afterPatUnique);

  /**
   * 次患者更新判定処理（治療情報）
   *
   * @param facilityCd
   * @param beforeOrdMain 変更前ord_main
   * @param afterOrdMain 変更後ord_main
   * @return void
   * @description パラメータで条件送信キャンセル処理しない場合がある
   */
  public boolean CheckDoCallNextPatChangeForOrdMain(String facilityCd, OrdMain beforeOrdMain, OrdMain afterOrdMain);

  /**
   * 次患者更新判定処理　次患者情報メモ（治療情報）
   *
   * @param facilityCd
   * @param beforeOrdMain 変更前ord_main
   * @param afterOrdMain 変更後ord_main
   * @return void
   * @description パラメータで条件送信キャンセル処理しない場合がある
   */
  public boolean CheckDoCallNextPatChangeForOrdMainMemo(String facilityCd, OrdMain beforeOrdMain, OrdMain afterOrdMain, MstComsvSetting mstComsvInfo);

  /**
   * 条件送信キャンセル・次患者更新実行纏め処理 治療情報関連次患者情報１or２で変更が発生したかのチェック
   *
   * @param facilityCd
   * @param beforOrdMainList 変更前ord_mainList
   * @return List<OrdMain>
   * @description 次患者情報１or２で変更が発生した場合の後で呼び出す元側でCallNextPatChangeを呼び出す必要あり
   */
  public List<OrdMain> FilterNextPatInfo1or2ChangedForOrdMain(String facilityCd, List<OrdMain> beforOrdMainList);

  /**
   * 条件送信キャンセル・次患者更新実行纏め処理
   *
   * @param facilityCd
   * @param beforOrdMainList 変更前ord_mainList
   * @return void
   * @description
   */
  public void CallNextPatChange(String facilityCd, List<OrdMain> beforOrdMainList);

  /**
   * 条件送信キャンセル・次患者更新実行
   *
   * @param facilityCd
   * @param beforeOrdMain 変更前ord_main※未登録など処理不要の場合 null
   * @param afterOrdMain  変更後ord_main※未登録など処理不要の場合 null
   * @param beforeBedMntMachineState 変更前bedのmnt_machine_state※未登録など処理不要の場合 null
   * @param afterBedMntMachineState  変更後bedのmnt_machine_state※未登録など処理不要の場合 null
   * @param beforeBedMstMachine 変更前bedのmst_machine※未登録など処理不要の場合 null
   * @param afterBedMstMachine  変更後bedのmst_machine※未登録など処理不要の場合 null
   * @param update      更新日時
   * @return message
   * @description パラメータで条件送信キャンセル処理しない場合がある
   */
  //mod #10601 スケジュール表動作不正 start
//  public String callDoCancelSetNextPatInfo2(String facilityCd,
//                                            OrdMain beforeOrdMain, OrdMain afterOrdMain,
//                                            MntMachineState beforeBedMntMachineState, MntMachineState afterBedMntMachineState,
//                                            MstMachine beforeBedMstMachine, MstMachine afterBedMstMachine,
//                                            LocalDateTime update);
  public String callDoCancelSetNextPatInfo2(String facilityCd,
                                            OrdMain beforeOrdMain, OrdMain afterOrdMain,
                                            MntMachineState beforeBedMntMachineState, MntMachineState afterBedMntMachineState,
                                            MstMachine beforeBedMstMachine, MstMachine afterBedMstMachine,
                                            LocalDateTime update, List<Integer> beforBedCdList);
  //mod #10601 スケジュール表動作不正 end

  /**
   * 次患者更新関連マスタデータ取得（マスタ変更）
   *
   * @param facilityCd
   * @param masterPhysicalName
   * @return List<T>
   * @description 注意：マスタデータのデータ物理削除は存在しない前提での処理
   */
  public <T> List<T>  getTableDataBymasterPhysicalName(String facilityCd, String masterPhysicalName);

}
