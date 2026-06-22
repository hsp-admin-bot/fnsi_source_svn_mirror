package jp.co.nikkiso.ntss.admin_web.service.statusList;

import java.text.ParseException;
import java.util.List;
import java.util.Map;

import jp.co.nikkiso.ntss.admin_web.request.statusList.CheckAfterWeightRequest;
import jp.co.nikkiso.ntss.admin_web.request.statusList.DeleteRecordRequest;
import jp.co.nikkiso.ntss.admin_web.response.statusList.CheckMediDoneResponse;
import jp.co.nikkiso.ntss.admin_web.response.statusList.DispItemListResponse;
import jp.co.nikkiso.ntss.admin_web.response.statusList.TreatmentStatusListResponse;
import jp.co.nikkiso.ntss.admin_web.response.statusList.TreatmentStatusUpdateResponse;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.core.entity.MniMonitor;
import jp.co.nikkiso.ntss.core.entity.MniMonitorCalendr;
import jp.co.nikkiso.ntss.core.entity.MntMachineState;
import jp.co.nikkiso.ntss.core.entity.MstBed;
import jp.co.nikkiso.ntss.core.entity.MstMachineType;
import jp.co.nikkiso.ntss.core.entity.MstPersonalUser;
import jp.co.nikkiso.ntss.core.entity.MstTreatmentStatusLayout;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.custom.BedMachine;
import jp.co.nikkiso.ntss.core.entity.custom.TreatmentStatusList;
import org.springframework.http.ResponseEntity;

public interface TreatmentStatusListService {

  List<TreatmentStatusList> selectAll(String facilityCd);

  List<TreatmentStatusList> selectOrdMainUnedition(String facilityCd);

  List<TreatmentStatusList> selectOrdMain(String facilityCd, String treatDate);

  List<TreatmentStatusList> selectOrdMainOnMachine(String facilityCd);

  List<TreatmentStatusList> selectOrdMainOnSchedule(String facilityCd, String rstDialysisState);

  /**
   * 与えらたオーダ番号に該当する装置モニタデータを取得する.
   *
   * @param ordNo オーダ番号
   * @return 装置モニタデータのリスト
   */
  List<MniMonitor> monitorSelectByOrdNo(Long ordNo);

  List<MntMachineState> machineSelectAllByFacilityCd(String facilityCd);

  List<MstTreatmentStatusLayout> mstTreatmentStatusLayoutSelectByFacilityCd(String facilityCd);

  /**
   * 後体重測定確認前の投薬未実施チェック
   * @param ordNo
   * @return
   */
  List<CheckMediDoneResponse> checkMediDone(List<String> ordNoList);

  // #10338 2024.04.25 del 実績確定処理updateCheckAfterWeightを改修し不使用になった TDC片口 start
//  /**
//   * 治療状況リストの後体重測定確認
//   * @param request
//   * @param facilityCd
//   * @return
//   */
//  int updateCheckAfterWeight(List<CheckAfterWeightRequest> request, String facilityCd);
  // #10338 2024.04.25 del 実績確定処理updateCheckAfterWeightを改修し不使用になった TDC片口 end

  /**
   * 治療状況レイアウトマスタ装置設定の選択項目取得
   * @param facilityCd 施設コード
   * @return
   */
  List<DispItemListResponse> getTreatmentStatusListDispItems(String facilityCd);

  /**
   * 施設コードからスタッフマスタ情報を取得するREST API
   * @param facilityCd 施設コード
   * @return
   */
  List<MstPersonalUser> getMstPersonalUser(String facilityCd);

  /**
   * 指定したOrdNoの治療状況リストを取得する
   * @param ordNo
   * @return
   */
  List<TreatmentStatusList> selectOrdMainRstUserInfo(Long ordNo);

  /**
   * 治療状況データの更新.
   *
   * @param facilityCd         施設コード
   * @param updateData         画面で編集したマスタデータ
   * @return マスタデータ更新結果(成功フラグとエラーメッセージ)
  * @throws ParseException
   */
  TreatmentStatusUpdateResponse updateTreatmentStatus(String facilityCd,
                                                      Map<String, Object> updateData) throws ParseException;

  MstBed getMstBed(Long bedCd);

  MstMachineType getMstMachineType(String machineTypeCd);

  /* mod #8872 by zhangruixue 2023-06-21 --start */
  TreatmentStatusListResponse getTreatmentStatusMapMachine(String facilityCd, String treatDate, String layoutNo, String bedGroupCd);
  /* mod #8872 by zhangruixue 2023-06-21 --end */

  /* add by chamaojia 2024-03-28 [10303、10304] new interface added --start */
  /**
   * 治療状況リスト->治療状況
   * @param facilityCd 施設コード
   * @param treatDate 透析日
   * @param layoutNo 治療状況レイアウト番号
   * @param bedGroupCd ベッドグループ
   * @param kurCdS クールアレイ
   * @param nextPat 次患者表示   "0":表示しない  "1":現クール  "2": 次クール
   * @return
   */
  TreatmentStatusListResponse getTreatmentStatusListToOrdNo(String facilityCd, String treatDate, String layoutNo, String bedGroupCd, String kurCdS, String nextPat);

  /**
   * 次患者
   * @param facilityCd  施設コード
   * @param nextPat  次患者表示   "0":表示しない  "1":現クール  "2": 次クール
   * @param bedCdList  クール
   * @param kurCdList  ベッド
   * @return
   */
  List<TreatmentStatusList> getNextPatTreatmentStatusInfo(String facilityCd, String nextPat, List<Long> bedCdList, List<Long> kurCdList);

  /**
   * 治療状況リスト->装置一覧
   * @param facilityCd 施設コード
   * @param treatDate 透析日
   * @param layoutNo 治療状況レイアウト番号
   * @param bedGroupCd ベッドグループ
   * @param nextPat 次患者表示   "0":表示しない  "1":現クール  "2": 次クール
   * @return
   */
  TreatmentStatusListResponse getTreatmentStatusListToMachine(String facilityCd, String treatDate, String layoutNo, String bedGroupCd, String nextPat);

  /**
   * 治療状況マップ->治療状況
   * @param facilityCd 施設コード
   * @param layoutNo 治療状況レイアウト番号
   * @param bedGroupCd ベッドグループ
   * @param nextPat 次患者表示   "0":表示しない  "1":現クール  "2": 次クール
   * @param bedLayoutId ベッドのレイアウト番号
   * @return
   */
  TreatmentStatusListResponse getTreatmentStatusMapToBed(String facilityCd, String layoutNo, String bedGroupCd, String nextPat, Long bedLayoutId);

  /**
   * 治療状況マップ->スケジュール
   * @param facilityCd 施設コード
   * @param treatDate 透析日
   * @param layoutNo 治療状況レイアウト番号
   * @param bedGroupCd ベッドグループ
   * @param bedLayoutId ベッドのレイアウト番号
   * @param kurCd クール
   * @return
   */
  TreatmentStatusListResponse getTreatmentStatusMapToSchedule(String facilityCd, String treatDate, String layoutNo,String bedGroupCd, Long bedLayoutId, Long kurCd);
  /* add by chamaojia 2024-03-28 [10303、10304] new interface added --end */

  /**
   * 指定したデータ区分の最新のモニタデータを取得
   * @param ordNo
   * @param dataType
   * @return
   */
  List<MniMonitor> monitorSelectNowOrdNoDataType(String ordNo, Short dataType);

  /**
   * 指定したデータ区分の最新のモニタデータを取得
   * @param facilityCd
   * @param machineTypeCd
   * @param machineSerial
   * @param dataType
   * @return
   */
  List<MniMonitor> monitorSelectNowMachineDataType(String facilityCd, String machineTypeCd, String machineSerial,
      Short dataType);

  /**
   * 指定施設コードからベッドと装置の一覧を取得
   * @param facilityCd
   * @return
   */
  List<BedMachine> getBedMachineList(String facilityCd);

  //mod FNSI 401対応 房 start
  /**
   * ？？？？患者実績削除
   * @param ordNo
   * @return
   */
  TreatmentStatusUpdateResponse deleteUnknownPatRecord(Long ordNo, String facilityCd);
  /* upd by chamaojia 2026-03-14 [12462] 患者情報共有->患者経過総合ビューア --start */
  List<MniMonitorCalendr> monitorSelectByOrdNos(List<Map<String, Object>> facilityCdAndOrdNoList);
  /* upd by chamaojia 2026-03-14 [12462] 患者情報共有->患者経過総合ビューア --end */
  //mod FNSI 401対応 房 end
  // del 11613 by shiyw 20250307 end
//  /**
//   * add FNSI NO.396 治療記録 版確定 -- Sanjingye Sun 20210126
//   * @param ordNo
//   */
//  void resultReconfirm2Oms(Long ordNo, Long patId);
  // del 11613 by shiyw 20250307 end
  // add #7660 2022/08/22 【デグレ】実績確定するまでの間は治療記録用紙に表示されない項目がある。 王永吉 start
  // mod #7660 2022/08/24 【デグレ】実績確定するまでの間は治療記録用紙に表示されない項目がある。 王永吉 start
  // void MiddleCheck(OrdMain ordMain);
  void middleCheck(OrdMain ordMain);
  // mod #7660 2022/08/24 【デグレ】実績確定するまでの間は治療記録用紙に表示されない項目がある。 王永吉 end
  // add #7660 2022/08/22 【デグレ】実績確定するまでの間は治療記録用紙に表示されない項目がある。 王永吉 end

  // #10338 2024.03.27 mod 実績確定処理updateCheckAfterWeightを改修 TDC片口 start
//  /* add by sunmingyuan  2023-02-01 CodeOptimization  start */
//  ResponseEntity<?> updateCheckAfterWeight(List<CheckAfterWeightRequest> request, NtssUser ntssUser, AllConfirmResponse allConfirmResponse);
//  /* add by sunmingyuan  2023-02-01 CodeOptimization  end */
  TreatmentStatusUpdateResponse updateCheckAfterWeightConfirm(List<CheckAfterWeightRequest> request, String facilityCd);
  // #10338 2024.03.27 mod 実績確定処理updateCheckAfterWeightを改修 TDC片口 end

  /* add by sunmingyuan  2023-02-01 CodeOptimization  start */
  ResponseEntity<TreatmentStatusUpdateResponse> updateDeleteRecord(DeleteRecordRequest request, NtssUser ntssUser);
  /* add by sunmingyuan  2023-02-01 CodeOptimization  end */

}
