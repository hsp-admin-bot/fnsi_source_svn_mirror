package jp.co.nikkiso.ntss.device_edge.service;

import java.io.IOException;
import java.util.List;

import jp.co.nikkiso.ntss.core.entity.MstChecklist;
import jp.co.nikkiso.ntss.core.entity.MstDialyzer;
import jp.co.nikkiso.ntss.core.entity.MstEquipment;
import jp.co.nikkiso.ntss.core.entity.MstMedicine;
import jp.co.nikkiso.ntss.core.entity.MstPersonalUser;
import jp.co.nikkiso.ntss.core.entity.OrdChecklist;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.device_edge.response.checkList.CheckListScheduleResponse;
import jp.co.nikkiso.ntss.device_edge.response.checkList.ChecklistUpdateResponse;
import jp.co.nikkiso.ntss.device_edge.response.checkList.ComsvChecklistResponse;
import jp.co.nikkiso.ntss.device_edge.response.checkList.MediUpdateResponse;
import jp.co.nikkiso.ntss.device_edge.response.checkList.OrdChecklistWithUserNameResponse;;

public interface ComsvOrdCheckListService {

  /**
   * 施設コードと次患者フラグからスケジュール情報を取得するREST API
   * @param facilityCd
   * @param nextPat 次患者[0:次クール, 1:当日, 2:次クール以降]
   * @return
   */
  List<CheckListScheduleResponse> getOrderTreatment(String facilityCd, Short nextPat);

  /**
   * 施設コードと治療日からスケジュール情報を取得するREST API
   * @param facilityCd
   * @return
   */
  List<CheckListScheduleResponse> getOrderByTreatDate(String facilityCd, String treatDate);

  /**
   * オーダー番号からスケジュール情報を取得するREST API
   * @param ordNo
   * @return
   * @throws IOException
   */
  CheckListScheduleResponse getOrderByOrderNo(Long ordNo) throws IOException;

  /**
   * チェックリストコードリストからチェックリストマスタ情報を取得するREST API
   * @param checklistCd チェックリストコード
   * @return
   */
  MstChecklist getMstChecklistByChecklistCd(Long checklistCd);

  /**
   * ダイアライザコードリストからダイアライザマスタ情報を取得するREST API
   * @param dialyzerList  ダイアライザコードリスト
   * @return
   */
  List<MstDialyzer> getDialyzerList(List<Integer> dialyzerList);

  /**
   * 薬剤コードリストから薬剤マスタ情報を取得するREST API
   * @param medicineList  薬剤コードリスト
   * @return
   */
  List<MstMedicine> getMedicineList(List<Integer> medicineList);

  /**
   * 調整薬剤コードリストから調整薬剤マスタ情報を取得するREST API
   * @param modifierList  調整薬剤コードリスト
   * @return
   */
  //List<MstModifier> getModifierList(List<Integer> modifierList);

  /**
   * 医療材料コードリストから医療材料マスタ情報を取得するREST API
   * @param equipList  医療材料コードリスト
   * @return
   */
  List<MstEquipment> getEquipList(List<Integer> equipList);

  /**
   * オーダー番号とリストコードからチェックリスト実績情報を取得するREST API
   * @param ordNo オーダー番号
   * @param listCd  リストコード
   * @return
   */
  List<OrdChecklistWithUserNameResponse> getOrdCheckListByListCd(Long ordNo, Short listCd);

  /**
   * オーダー番号からチェックリスト実績(チェック項目数,項目数)情報を取得するREST API
   * @param ordNo オーダー番号
   * @return
   */
  List<List<Long>> getOrdCheckListByOrdNo(Long ordNo);

  /**
   * チェックリスト実績更新
   * @param param
   * @return
   */
  //mod #283:仮想端末チェックリストを操作すると通信が切れる 劉 start
  //ChecklistUpdateResponse ordChecklistUpdate(List<OrdChecklist> param, String facilityCd) throws IOException;
  ChecklistUpdateResponse ordChecklistUpdate(Short send_flg, List<OrdChecklist> param, String facilityCd) throws IOException;
  //mod #283:仮想端末チェックリストを操作すると通信が切れる 劉 end

  /**
   * 施設コードからスタッフマスタ情報を取得するREST API
   * @param facilityCd 施設コード
   * @return
   */
  List<MstPersonalUser> getMstPersonalUser(String facilityCd);

  /**
   * オーダー番号の投与薬剤実績更新
   * @param ordNo オーダー番号
   * @param param
   * @return
   */
  MediUpdateResponse ordMainMediInfoUpdate(OrdMain param) throws IOException;

  /**
   * 条件送信時
   * 指定オーダー番号のチェックリスト実績作成・更新
   * @param ordNo オーダー番号
   * @param facilityCd 施設コード
   * @return
   */
  ChecklistUpdateResponse createOrdChecklistSendCondition(String facilityCd, Long ordNo) throws IOException;

  // add FNSI-バグ 通信サーバ 劉 start
  /**
   * ????患者生成
   * 指定オーダー番号のチェックリスト実績作成・更新
   * @param ordNo オーダー番号
   * @param facilityCd 施設コード
   * @return
   */
  ChecklistUpdateResponse createOrdChecklistUnregistered(String facilityCd, Long ordNo) throws IOException;
  // add FNSI-バグ 通信サーバ 劉 end

  /**
   * 条件送信前のチェックリスト情報を取得する
   * @param ordNo オーダー番号
   * @param listCd  リストコード
   * @param facilityCd 施設コード
   * @return
   */
  List<OrdChecklist> getBeforeCheckListByListCd(Long ordNo, Short listCd, String facilityCd) throws IOException;

  /**
   * チェックリスト実績情報を取得する
   * @param ordNo オーダー番号
   * @param listCd  リストコード
   * @return
   */
  List<OrdChecklist> getAfterCheckListByListCd(Long ordNo, Short listCd);

  /**
   * 条件送信前のチェックリスト情報（仮想端末用データ）を取得する
   * @param ordNo オーダー番号
   * @param listCd  リストコード
   * @param facilityCd 施設コード
   * @return
   */
  List<ComsvChecklistResponse> getBeforeCheckList(Long ordNo, Short listCd, String facilityCd) throws IOException;

  /**
   * チェックリスト実績情報（仮想端末用データ）を取得する
   * @param ordNo オーダー番号
   * @param listCd  リストコード
   * @return
   */
  List<ComsvChecklistResponse> getAfterCheckList(Long ordNo, Short listCd);

  /**
   * チェックリスト実績情報（仮想端末用データ）を更新する
   * @param facilityCd 施設コード
   * @param noJson No配列（json）
   * @param ordCheckList チェックリスト実績情報
   * @return
   */
  //mod #283:仮想端末チェックリストを操作すると通信が切れる 劉 start
  //public int updateOrdChecklist(String facilityCd, String noJson, List<OrdChecklist> ordCheckList);
  public int updateOrdChecklist(Short send_flg, String facilityCd, String noJson, List<OrdChecklist> ordCheckList);
  //mod #283:仮想端末チェックリストを操作すると通信が切れる 劉 end

}
