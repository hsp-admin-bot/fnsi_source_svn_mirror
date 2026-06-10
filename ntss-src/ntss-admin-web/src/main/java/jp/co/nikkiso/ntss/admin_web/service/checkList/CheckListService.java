package jp.co.nikkiso.ntss.admin_web.service.checkList;

import java.io.IOException;
import java.util.List;
import java.util.Map;

import jp.co.nikkiso.ntss.admin_web.response.checkList.CheckListScheduleResponse;
import jp.co.nikkiso.ntss.admin_web.response.checkList.ChecklistUpdateResponse;
import jp.co.nikkiso.ntss.admin_web.response.checkList.MediUpdateResponse;
import jp.co.nikkiso.ntss.admin_web.response.checkList.OrdChecklistWithUserNameResponse;
import jp.co.nikkiso.ntss.core.entity.MstChecklist;
import jp.co.nikkiso.ntss.core.entity.MstDialyzer;
import jp.co.nikkiso.ntss.core.entity.MstEquipment;
import jp.co.nikkiso.ntss.core.entity.MstMedicine;
import jp.co.nikkiso.ntss.core.entity.MstMedicineMix;
import jp.co.nikkiso.ntss.core.entity.MstPersonalUser;
import jp.co.nikkiso.ntss.core.entity.OrdCheckListParams;
import jp.co.nikkiso.ntss.core.entity.OrdChecklist;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
// add FNSI-チェックリスト仕様変更対応#401、#439_患者経過総合ビューア機能分。 周 start
import com.fasterxml.jackson.databind.JsonNode;
import jp.co.nikkiso.ntss.core.entity.custom.OrdMainForCheckListSchedule;
// add FNSI-チェックリスト仕様変更対応#401、#439_患者経過総合ビューア機能分。 周 end

public interface CheckListService {

  // add FNSI-チェックリスト仕様変更対応#401、#439_チェックリスト機能分。 周 start
  /**
   * 施設コードと治療中からスケジュール情報を取得するREST API
   * @param facilityCd
   * @param nextPat 次患者[0:次クール, 1:当日, 2:次クール以降](※無効)
   * @return
   */
  List<CheckListScheduleResponse> getOrdMainChiryouchuu(String facilityCd, Short nextPat);

  /**
   * 施設コードと指定治療日からスケジュール情報を取得するREST API
   * @param facilityCd
   * @param treatDate 治療日
   * @return
   */
  List<CheckListScheduleResponse> getOrdMainShiteibi(String facilityCd, String treatDate);

  /**
   * オーダー番号からチェックリスト進度(チェック項目数,項目数)情報を取得する「条件送信前」REST API
   * @param ordNo オーダー番号
   * @return
   */
  List<List<Long>> getOrdCheckListShindoZen(Long ordNo) throws IOException;

  /**
   * オーダー番号からチェックリスト一覧情報を取得する「条件送信前」REST API
   * @param ordNo オーダー番号
   * @param listCd リストコード
   * @return
   */
  List<OrdChecklistWithUserNameResponse> getOrdCheckListIchiranZen(Long ordNo, Short listCd) throws IOException;

  /**
   * オーダー番号からチェックリスト進度(チェック項目数,項目数)情報を取得する「条件送信以降」REST API
   * @param ordNo オーダー番号
   * @return
   */
  List<List<Long>> getOrdCheckListShindoIcou(Long ordNo);

  /**
   * オーダー番号からチェックリスト一覧情報を取得する「条件送信以降」REST API
   * @param ordNo オーダー番号
   * @param listCd リストコード
   * @return
   */
  List<OrdChecklistWithUserNameResponse> getOrdCheckListIchiranIcou(Long ordNo, Short listCd);
  // add FNSI-チェックリスト仕様変更対応#401、#439_チェックリスト機能分。 周 end

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
  List<MstMedicineMix> getMedicineMixList(String facilityCd, List<Integer> medicineMixList);

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
  ChecklistUpdateResponse ordChecklistUpdate(List<OrdChecklist> param, String facilityCd) throws IOException;

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
   * @return
   */
  ChecklistUpdateResponse createOrdChecklistSendCondition(String facilityCd, Long ordNo) throws IOException;

  /**
   * 施設設定から
   * @param facilityCd
   * @return
   */
  Short getAutoReloadInterval(String facilityCd);

  // add チェックリストマスタ 指示変更、実績変更に伴うチェックリストの反映 孔 start
  /**
   * チェックリスト実績削除
   * @param param
   * @return
   */
  Integer deleteOrdChecklist(List<OrdChecklist> param);
  // add チェックリストマスタ 指示変更、実績変更に伴うチェックリストの反映 孔 end

  // add FNSI-チェックリスト仕様変更対応#401、#439_患者経過総合ビューア機能分。 周 start
  /**
   * チェックリスト実績削除
   * @param ordNo
   * @param facilityCd
   * @return
   */
  Integer deleteByOrdNo(long ordNo, String facilityCd);

  // mod 9324 gjn start
  List<Object> getMstData(List<OrdMainForCheckListSchedule> ordMain);

  /**
   * 登録用チェックリストデータを作成
   * @param ordMain
   * @param mstChecklist
   * @param checklistCd
   * @param hasDummyData
   * @return
   */
  List<OrdChecklist> getRegisterChecklist(OrdMainForCheckListSchedule ordMain,
                                          JsonNode mstChecklist,
                                          Long checklistCd,
                                          boolean hasDummyData,
                                          List<Object> mstData) throws IOException;
  // mod 9324 gjn end

  //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  start
  /**
   * 登録用チェックリストデータを作成
   * @param ordMain
   * @param mstChecklist
   * @param checklistCd
   * @param hasDummyData
   * @return
   */
  List<OrdChecklist> getRegisterChecklistRst(OrdMainForCheckListSchedule ordMain,
                                             JsonNode mstChecklist,
                                             Long checklistCd,
                                             boolean hasDummyData) throws IOException;
  //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  end

  // add FNSI-チェックリスト仕様変更対応#401、#439_患者経過総合ビューア機能分。 周 end

  // add FNSI-障害票一覧_患者経過総合ビューアNo.29 李 start
  /**
   * チェックリスト実績を追加する
   * @param latestOrdNo
   * @param oldOrdNo
   * @return 追加結果
   */
  Integer insertOrdChecklist(String latestOrdNo, String oldOrdNo);
  // add FNSI-障害票一覧_患者経過総合ビューアNo.29 李 end

  /**
   * オーダー番号からチェックリスト進度(チェック項目数,項目数)情報を取得する「条件送信前」REST API
   * @param ordNo オーダー番号
   * @return
   */
  List<List<List<Long>>> getOrdCheckListShindoZen(List<OrdCheckListParams> ordCheckListParamsList, String facilityCd) throws IOException;

  /**
   * オーダー番号からチェックリスト進度(チェック項目数,項目数)情報を取得する「条件送信以降」REST API
   * @param ordNo オーダー番号
   * @return
   */
  List<List<List<Long>>> getOrdCheckListShindoIcou(List<OrdCheckListParams> ordCheckListParamsList);

  /**
   * 治療状況マップ表示用指示変更markerの状態を確定とする処理
   * @param orderNo
   * @return
   */
  void indApprovedForStatusMap(Long orderNo) throws Exception;

  //add 9324 治療情報を異なる状態で変更した後のord_checklistの再編成共通方法 gjn start
  /**
   * ord _ noからord _ checklistのデータを取得する
   *
   * @param orderNo
   * @return
   */
  List<OrdChecklist> getOrdCheckListByOrdNO (Long orderNo);


  Map<String, JsonNode> makeMstChecklistByOrdChecklist (List<OrdChecklist> ordChecklistList);

  /**
   * marge OrdCheckList left
   *
   * @param ordChecklistListOfMarge
   * @param ordChecklistListForMarge
   * @return
   */
  void margeOrdCheckListInsCheckLeft(List<OrdChecklist> ordChecklistListOfMarge, List<OrdChecklist> ordChecklistListForMarge);

  /**
   * marge OrdCheckList del
   *
   * @param ordChecklistListOfMarge
   * @param ordChecklistListForMarge
   * @return
   */
  void margeOrdCheckListInsDel(List<OrdChecklist> ordChecklistListOfMarge, List<OrdChecklist> ordChecklistListForMarge);
  /**
   * marge OrdCheckList right
   *
   * @param ordChecklistListOfMarge
   * @param ordChecklistListForMarge
   * @return
   */
  List<OrdChecklist> margeOrdCheckListInsCheckRight(List<OrdChecklist> ordChecklistListOfMarge, List<OrdChecklist> ordChecklistListForMarge, boolean isDelete);

  //add 9324 治療情報を異なる状態で変更した後のord_checklistの再編成共通方法 gjn end

  //add #10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 zhaoqi 20240529 start

  /**
   *
   * @param ordNo システムで管理する一意なオーダ番号
   */
  void indApprovedForContent(Long ordNo);
  //add #10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 zhaoqi 20240529 end
  //add #9507 一括指示受けに時間がかかる zrx start
  /**
   *
   * @param ordNo システムで管理する一意なオーダ番号
   */
  String getIndApprovedForContent(Long ordNo);
  //add #9507 一括指示受けに時間がかかる zrx end
}
