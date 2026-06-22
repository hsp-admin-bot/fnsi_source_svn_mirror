package jp.co.nikkiso.ntss.admin_web.service.weight;

import java.io.IOException;
import java.text.ParseException;
import java.util.List;

import jp.co.nikkiso.ntss.admin_web.request.weight.SendConditionRequest;
import jp.co.nikkiso.ntss.admin_web.response.weight.SendConditionCheckResponse;
import jp.co.nikkiso.ntss.admin_web.response.weight.SendConditionResponse;
import jp.co.nikkiso.ntss.admin_web.response.weight.WeightKurBedResponse;
import jp.co.nikkiso.ntss.admin_web.response.weight.WeightOrderResponse;
import jp.co.nikkiso.ntss.admin_web.response.weight.WeightScheduleResponse;
import jp.co.nikkiso.ntss.admin_web.response.weight.WeighthistoryResponse;
import jp.co.nikkiso.ntss.core.entity.MntMachineState;
import jp.co.nikkiso.ntss.core.entity.MstKur;
import jp.co.nikkiso.ntss.core.entity.MstMachine;
import jp.co.nikkiso.ntss.core.entity.MstRoomBedGroup;
import jp.co.nikkiso.ntss.core.entity.OrdWeightScale;
import jp.co.nikkiso.ntss.core.entity.custom.OrdMainRstWeightInfo;
import jp.co.nikkiso.ntss.core.entity.custom.OrdWeightScaleBuildInfo;
import jp.co.nikkiso.ntss.core.entity.custom.PatExamMainWeightPrint;
import jp.co.nikkiso.ntss.core.entity.custom.PatExamPrint;

public interface WeightService {

  /**
   * 条件送信対象の装置と現患者オーダー情報
   */
  public class MachineCurrentOrdDataSet {
    public MstMachine machine;
    public MntMachineState state;
    public Long targetMachineNextOrdNo;
    public Long targetMachineCurrentOrdNo;
  }

  /**
   * 院内患者IDから患者ID取得
   * @param facilityCd 施設コード
   * @param hospPatId 院内患者ID
   * @return 患者ID
   */
  Long getPatId(String facilityCd, String hospPatId);
  // add FNSI-次回同じ患者を検索する場合測定値保存する 徐 start
  /**
   * 患者IDから患者体重測定値取得
   * @param facilityCd 施設コード
   * @param patId 患者ID
   * @return 患者体重測定値
   */
  double getMeasuredValue(String facilityCd, Long patId);
  // add FNSI-次回同じ患者を検索する場合測定値保存する 徐 end
  /**
   * 施設コードから施設名を取得
   * @param facilityCd 施設コード
   * @return 施設名
   */
  String findFacilityName(String facilityCd);

  /**
   * 非体重計モード時の体重計選択可能フラグ
   * @param facilityCd
   * @return
   */
  String fetchEnableWeightSelect(String facilityCd);

  /**
   * 対象ベッドの関連する装置状態取得
   * @param facilityCd 施設コード
   * @param bedCd ベッドコード
   * @return
   */
  MachineCurrentOrdDataSet findMachineStateByBed(String facilityCd, Long bedCd);

  /**
   * 患者選択用スケジュール取得
   * @param facilityCd 施設コード
   * @param patId 患者ID（NULLで患者特定無し）
   * @param treatDate 治療日
   * @param isPast 過去日フラグ
   * @return
   */
  List<WeightScheduleResponse> selectWeightSchedule(String facilityCd, String hospPatId, String treatDate, boolean isPast);

  public enum currentOrdTargetAction {
    /**
     * 条件送信可能
     */
    canSendCondition,
    /**
     * 条件送信確認前（キャンセル必要）
     */
    doCancel,
    /**
     * 条件確認済み（条件送信不可）
     */
    checked,
    /**
     * 治療中（条件送信不可）
     */
    dialysis,
    /**
     * 治療後（現患者クリア必要）
     */
    clearCurrentOrd
  }

  /**
   * 条件送信前にキャンセルや現患者クリアが必要かどうかをチェックする
   * @param targetOrdNo 装置の治療中オーダー番号
   * @return
   */
  currentOrdTargetAction validationCurrentOrdTargetAction(Long targetOrdNo);

  public enum currentMachineTreatState {
    /**
     * 条件送信可能
     */
    canSendCondition,
    /**
     * 通信異常（条件送信不可）
     */
    connectError,
    /**
     * 治療中（条件送信不可）
     */
    treating
  }
  /**
   * 条件送信前に装置状態が治療中や通信異常かどうかをチェックする
   * @param targetOrdNo 装置の治療中オーダー番号
   * @return
   */
  currentMachineTreatState validationMachineStateCanSend(MachineCurrentOrdDataSet machineCurrentOrdDataSet);

  /**
   * 装置次患者情報が不一致だった場合に割り当てを行う
   * @param machine 対象装置
   * @param nextOrdNo 次患者オーダー番号
   * @return
   */
  boolean updateMachineNextOrdInfo(MstMachine machine, Long nextOrdNo);

  /**
   * 条件送信用に体重測定履歴の追加を行う
   * @param request
   * @return
   * @throws IOException
   */
  SendConditionResponse saveSendConditionOrdWeightScale(SendConditionRequest request, Short weightScaleStatus)
    throws IOException;

  /**
   * 前体重実績を書き込む
   * @param request
   * @return
   */
  SendConditionResponse saveBeforeWeight(SendConditionRequest request);

  /**
   * 体重＋車いす一時保存を行う
   * @param request
   * @return
   * @throws IOException
   */
  OrdWeightScale insertSendConditionWeightAndChair(SendConditionRequest request, Short weightScaleStatus)
    throws IOException;

  /**
   * 指示情報の書き換えと体重測定履歴の追加を行う
   * @param request
   * @return
   */
  OrdWeightScale insertSendConditionChairInfo(SendConditionRequest request, Short weightScaleStatus);

  /**
   * 後体重用の指示情報の書き換えと体重測定履歴の追加を行う
   * @param request
   * @return
   * @throws IOException
   */
  OrdWeightScale insertSendAfterWeightInfo(SendConditionRequest request, Short weightScaleStatus) throws IOException;

  /**
   * 後体重測定済み状態への遷移を行う
   * @param request
   * @return
   * @throws IOException
   */
  OrdWeightScaleBuildInfo updateStateAfterWeight(Long ordNo, String facilityCd);

  /**
   * 体重測定履歴のステータス変更を行う
   * @param weightScaleCd 体重計測定記録管理番号
   * @param weigtScaleStatus 測定ステータス
   * @return
   */
  OrdWeightScale updateOrdWeightStatus(Long weightScaleCd, Short weightScaleStatus, String message);

  /**
   * 体重測定履歴から前回測定時の値取得を行う
   * @return
   */
  OrdWeightScale fetchLastWeightScale(Long ordNo, Short scaleClass);

  /**
   * 体重測定履歴から前回測定時の値取得を行う (スケジュールなし)
   * @return
   */
  OrdWeightScale fetchLastScaleNoSchedule(Long patId);

  /**
   * 体重測定履歴から対象測定時の値取得を行う
   * @return
   */
  OrdWeightScale fetchTargetWeightScale(Long weightScaleCd);

  /**
   * 体重測定履歴の追加を行う
   * @param request
   * @return
   * @throws IOException
   */
  OrdWeightScale insertOrdWeight(SendConditionRequest request, Short weightScaleStatus) throws IOException;

  /**
   * 条件から装置マスタを取得
   * 実績ベース
   * @param ordNo オーダー番号
   * @return デバイスエッジ番号
   */
  MstMachine getMachineByOrderRst(Long ordNo);

  /**
   * 条件から装置マスタを取得
   * 指示ベース
   * @param ordNo オーダー番号
   * @return デバイスエッジ番号
   */
  MstMachine getMachineByOrderInd(Long ordNo);

  /**
   * 条件を取得
   * @param machine
   * @return 条件JSON文字列
   */
  String getTmpDeviceSetInfo(MstMachine machine);

  /**
   * 現在の治療状況を取得
   * @param ordNo
   * @return
   */
  String getCurrentDialysisState(Long ordNo);

  /**
   * 施設コードからクールのセレクター情報とベッドグループのリストを返す
   * @param facilityCd
   * @param excludeDialysisRoom 1：透析室(group_class = 2)を除外 / -1：全選択
   * @return
   */
  WeightKurBedResponse getKurBedSelector(String facilityCd, short excludeDialysisRoom);
  /**
   * 施設コードからクールの一覧を取得する
   * @param facilityCd
   * @return
   */
  List<MstKur> getKurList(String facilityCd);

  /**
   * 施設コードからベッドグループの一覧を取得する
   * @param facilityCd
   * @return
   */
  List<MstRoomBedGroup> getBedGroupList(String facilityCd);

  /**
   * 指示番号からオーダー情報を取得するREST API
   * @param ordNo
   * @return
   */
  WeightOrderResponse buildOrderResponse(Long ordNo);

  /**
   * 患者ＩＤからスケジュール無し用情報を取得するREST API
   * @param patId
   * @return
   */
  WeightOrderResponse buildOrderResponseNoSchedule(Long patId, String facilityCd);

  /**
   * 患者情報も何もなしの指示情報を取得するREST API（施設コードくらい）
   * @return
   */
  WeightOrderResponse buildOrderResponseNoPat(String facilityCd);

  /**
   * 指示風袋情報を更新
   * @param ordNo
   * @param tareInfo
   * @return
   */
  boolean updateIndTare(Long ordNo, String tareInfo);

  /**
   * 指示除水補正情報を更新
   * @param ordNo
   * @param offWaterInfo
   * @return
   */
  boolean updateIndOffWater(Long ordNo, String offWaterInfo);

  /**
   * 前回後体重を含む実績を取得
   * @param ordNo
   * @param previousWeightSourceClass
   * @return
   */
  OrdMainRstWeightInfo getLastWeightRecord(Long ordNo, Integer previousWeightSourceClass) throws ParseException;

  /**
   * 前回後体重を含む実績を取得
   * @param patNo
   * @param previousWeightSourceClass
   * @return
   */
  OrdMainRstWeightInfo getLastWeightRecordPat(Long patId, Integer previousWeightSourceClass) throws ParseException;

  /**
   * 指定日の前回後体重を含む実績を取得
   * @param patId
   * @param previousWeightSourceClass
   * @param treatDate
   * @return
   */
  OrdMainRstWeightInfo getWeightByTreatDate(Long patId, Integer previousWeightSourceClass, String treatDate)
    throws ParseException;

  /* #10443 ADD 測定日と同日の治療日の治療データから、測定タイミングと一致する体重を対象にデータ取得をする Start */
  /**
   * 測定日と同日の治療日の治療データから、測定タイミングと一致する体重を対象にデータ取得をする
   *
   * @param facilityCd
   * @param patId
   * @param ordClass
   * @param treatDate
   * @param treatTime
   * @return
   */
  String getNearestWeightRecordForPat(String facilityCd, Long patId, String ordClass,
                                      String treatDate, String treatTime);
  /* #10443 ADD 測定日と同日の治療日の治療データから、測定タイミングと一致する体重を対象にデータ取得をする End */
  /**
   * 測定履歴モーダル情報取得
   * @param facilityCd
   * @param patId
   * @param previousWeightSourceClass
   * @return
   */
  //  List<MarkerInfoResponse> getMarkerInfo(List<Long> ord_no);
  List<WeighthistoryResponse> getWeighthistoryInfo(String facilityCd, Long patId, String treatDate,
                                                   Integer previousWeightSourceClass) throws ParseException;
  /**
   * 体重計レシート印刷用
   * @param facilityCd
   * @param patId 患者ID
   * @param strBaseDate 取得範囲最新日付 YYYYMMDD
   * @param itemCdList 取得する検査項目コードのリスト
   * @return
   */
  // FNSI-add redmine4656 徐 start
//  List<PatExamMainWeightPrint> fetchExamForPrint(String facilityCd, Long patId, String strBaseDate, List<String> itemCdList);
  List<PatExamMainWeightPrint> fetchExamForPrint(String facilityCd, Long patId, String strBaseDate, List<PatExamPrint> itemCdList);
  // FNSI-add redmine4656 徐 end

  // add 2020-08-08 FNSI-仕様追加 カード読み込み時にIdmでカード有効無効なチェック処理 夏 start
  /**
   * カードIDMを取得
   * @param patientID
   * @return
   */
  String getCardIdm(Long patId);
  // add 2020-08-08 FNSI-仕様追加 カード読み込み時にIdmでカード有効無効なチェック処理 夏 end
  // add FNSI-分類不一致判断の追加 徐 start
  /**
   * 治療条件分類不一致判断
   * @param ordNo
   * @param ordNos
   * @return
   */
  SendConditionCheckResponse getChkIndCondInfoData(Long ordNo, Long ordNos, Boolean chkIndCondInfoFlg, Boolean mstDelFlg, Boolean mstOverdueFlg);
  // add FNSI-分類不一致判断の追加 徐 end
  // del 11613 by shiyw 20250307 start
  // add FNSI-確定フラグを”1”に更新 徐 start
//  int updateIsConfirm(Long ordNo, Long patId);
  // add FNSI-確定フラグを”1”に更新 徐 end
  // del 11613 by shiyw 20250307 end
}
