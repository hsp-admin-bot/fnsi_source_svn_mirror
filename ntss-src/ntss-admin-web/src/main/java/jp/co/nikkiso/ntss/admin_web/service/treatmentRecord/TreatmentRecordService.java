package jp.co.nikkiso.ntss.admin_web.service.treatmentRecord;

import tools.jackson.core.JacksonException;
import jp.co.nikkiso.ntss.admin_web.response.treatmentRecord.TreatmentRecordSummary;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.core.entity.MniMonitor;
import jp.co.nikkiso.ntss.core.entity.MntMachineState;
import jp.co.nikkiso.ntss.core.entity.MstMachine;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.TreatmentRecordAddition;
import jp.co.nikkiso.ntss.core.entity.TreatmentRecordCondition;
import jp.co.nikkiso.ntss.core.entity.TreatmentRecordEquipInfo;
import jp.co.nikkiso.ntss.core.entity.TreatmentRecordMediInfo;
import jp.co.nikkiso.ntss.core.entity.TreatmentRecordResult;
import jp.co.nikkiso.ntss.core.entity.TreatmentRecordVitalMonitor;
import jp.co.nikkiso.ntss.core.entity.TreatmentRecordWeight;
import jp.co.nikkiso.ntss.core.entity.custom.ComsvSet;
import jp.co.nikkiso.ntss.core.entity.custom.ReportCds;
import jp.co.nikkiso.ntss.core.entity.custom.TreatmentRecordReportInfo;
import jp.co.nikkiso.ntss.core.exception.NotExistException;

import java.io.IOException;
import java.lang.reflect.InvocationTargetException;
import java.util.List;

import jp.co.nikkiso.ntss.admin_web.response.treatmentRecord.RecirculationRate;
import org.springframework.http.ResponseEntity;

/**
 * 治療記録画面のServiceインタフェース.
 */
public interface TreatmentRecordService {

  /**
   * 治療記録（治療概要）の取得.
   * <p>
   * オーダ番号に該当するレコードが存在しない場合、例外を発生させる.
   * </p>
   * @param ordNo オーダ番号
   * @return 治療記録（治療概要）
   * @throws NotExistException オーダ番号に該当するレコードが存在しない場合
   */
  TreatmentRecordSummary getTreatmentRecordSummary(Long ordNo) throws NotExistException;

  /**
   * 治療記録（実績情報）の取得.
   * <p>
   * オーダ番号に該当するレコードが存在しない場合、例外を発生させる.
   * </p>
   * @param ordNo オーダ番号
   * @return 治療記録（実績情報）
   * @throws NotExistException オーダ番号に該当するレコードが存在しない場合
   */
  TreatmentRecordResult getTreatmentRecordResult(Long ordNo) throws NotExistException;

  /**
   * 治療記録（実績情報）の更新
   * <p>
   * オーダ番号に該当するレコードが存在しない場合、例外を発生させる.
   * </p>
   * @param ordNo オーダ番号
   * @param treatmentRecordResult 実績情報
   * @throws NotExistException オーダ番号に該当するレコードが存在しない場合
   */
  void updateTreatmentRecordResult(Long ordNo, TreatmentRecordResult treatmentRecordResult) throws NotExistException;

  /**
   * 治療記録（実績情報）の更新
   * <p>
   * オーダ番号に該当するレコードが存在しない場合、例外を発生させる.
   * </p>
   * @param ordNo オーダ番号
   * @param treatmentRecordResult 実績情報
   * @param processType 処理区分
   * @param userId 利用者ID
   * @throws NotExistException オーダ番号に該当するレコードが存在しない場合
   */
  void updateTreatmentRecordResultWithCondition(Long ordNo, TreatmentRecordResult treatmentRecordResult, int processType, Long userId) throws NotExistException;

  /**
   * 治療記録（投与薬剤情報）の取得
   * <p>
   * オーダ番号に該当するレコードが存在しない場合、例外を発生させる.
   * </p>
   * @param ordNo オーダ番号
   * @return 治療記録（投与薬剤情報）
   * @throws NotExistException オーダ番号に該当するレコードが存在しない場合
   */
  TreatmentRecordMediInfo getTreatmentRecordMediInfo(Long ordNo) throws NotExistException;

  /**
   * 治療記録（投与薬剤情報）の更新
   * <p>
   * オーダ番号に該当するレコードが存在しない場合、例外を発生させる.
   * </p>
   * @param ordNo オーダ番号
   * @param treatmentRecordMediInfo 治療記録（投与薬剤情報）
   * @throws NotExistException オーダ番号に該当するレコードが存在しない場合
   */
  void updateTreatmentRecordMediInfo(Long ordNo, TreatmentRecordMediInfo treatmentRecordMediInfo) throws NotExistException;

  /**
   * 治療記録（治療条件）の取得.
   * <p>
   * オーダ番号に該当するレコードが存在しない場合、例外を発生させる.
   * </p>
   * @param ordNo オーダ番号
   * @return 治療記録（治療条件）
   * @throws NotExistException オーダ番号に該当するレコードが存在しない場合
   */
  TreatmentRecordCondition getTreatmentRecordCondition(Long ordNo) throws NotExistException;

  /**
   * 治療記録（治療条件）の更新
   * <p>
   * オーダ番号に該当するレコードが存在しない場合、例外を発生させる.
   * </p>
   * @param ordNo オーダ番号
   * @param treatmentRecordCondition 治療条件
   * @throws NotExistException オーダ番号に該当するレコードが存在しない場合
   */
  void updateTreatmentRecordCondition(Long ordNo, TreatmentRecordCondition treatmentRecordCondition) throws NotExistException;

  /**
   * 再循環率の取得.
   *
   * @param ordNo オーダ番号
   * @return 再循環率のリスト
   */
  List<RecirculationRate> getRecirculationRate(Long ordNo);

  /**
   * 治療記録（体重情報）の取得.
   * <p>
   * オーダ番号に該当するレコードが存在しない場合、例外を発生させる.
   * </p>
   * @param ordNo オーダ番号
   * @return 治療記録（体重情報）
   * @throws NotExistException オーダ番号に該当するレコードが存在しない場合
   */
  TreatmentRecordWeight getTreatmentRecordWeight(Long ordNo) throws NotExistException;

  /**
   * 治療記録（体重情報）の更新
   * <p>
   * オーダ番号に該当するレコードが存在しない場合、例外を発生させる.
   * </p>
   * @param ordNo オーダ番号
   * @param treatmentRecordWeight 体重情報
   * @throws NotExistException オーダー番号に該当するレコードが存在しない場合
   */
  /* modify by chamaojia 2024-07-05 [10774] Add handling of JacksonException exceptions --start */
  void updateTreatmentRecordWeight(Long ordNo, TreatmentRecordWeight treatmentRecordWeight)
          throws NotExistException, JacksonException;
  /* modify by chamaojia 2024-07-05 [10774] Add handling of JacksonException exceptions --end */

  /**
   * 治療記録（医療材料情報）の取得
   * <p>
   * オーダ番号に該当するレコードが存在しない場合、例外を発生させる.
   * </p>
   * @return 治療記録（医療材料情報）
   * @throws NotExistException オーダ番号に該当するレコードが存在しない場合
   */
  TreatmentRecordEquipInfo getTreatmentRecordEquipInfo(Long ordNo) throws NotExistException;

  /**
   * 治療記録（医療材料情報）の更新
   * <p>
   * オーダ番号に該当するレコードが存在しない場合、例外を発生させる.
   * </p>
   * @param ordNo オーダ番号
   * @param treatmentRecordEquipInfo 治療記録（医療材料情報）
   * @throws NotExistException オーダ番号に該当するレコードが存在しない場合
   */
  void updateTreatmentRecordEquipInfo(Long ordNo, TreatmentRecordEquipInfo treatmentRecordEquipInfo) throws NotExistException;

  /**
   * 最新オーダ番号の取得.
   *
   * @param patId 患者ID
   * @param facilityCd 施設コード
   * @return オーダ番号
   */
  Long getLatestOrdNo(Long patId, String facilityCd);

  /**
   * 治療記録（指示コメント）の取得
   * <p>
   * オーダ番号に該当するレコードが存在しない場合、例外を発生させる.
   * </p>
   * @return 治療記録（指示コメント）
   * @throws NotExistException オーダ番号に該当するレコードが存在しない場合
   */
  TreatmentRecordAddition getTreatmentRecordAddition(Long ordNo) throws NotExistException;

  /**
   * 治療記録（指示コメント情報）の更新
   * <p>
   * オーダ番号に該当するレコードが存在しない場合、例外を発生させる.
   * </p>
   * @param ordNo オーダ番号
   * @param treatmentRecordAddition 治療記録（指示コメント情報）
   * @throws NotExistException オーダ番号に該当するレコードが存在しない場合
   */
  void updateTreatmentRecordAddition(Long ordNo, TreatmentRecordAddition treatmentRecordAddition) throws NotExistException;

  /**
   * 治療記録（装置モニタデータ(バイタル)情報）の取得
   * <p>
   * オーダ番号に該当するレコードが存在しない場合、空リストを返却する.
   * </p>
   * @param ordNo オーダ番号
   * @param facilityCd 施設番号
   * @return 治療記録（装置モニタデータ(バイタル)情報）
   */
  List<TreatmentRecordVitalMonitor> getTreatmentRecordVitalMonitors(String facilityCd, Long ordNo);

  /**
   * モニタデータ情報の登録更新
   * @param ordNo オーダ番号
   * @param mniMonitorList モニタデータのリスト
   * @param updStaffId 更新者ID
   * @throws NotExistException オーダ番号に該当するレコードが存在しない場合
   */
  void insertOrUpdateTreatmentRecordForMniMonitor(Long ordNo, List<MniMonitor> mniMonitorList, Long updStaffId) throws NotExistException;

  /**
   * オーダ番号に設定されている治療方法コードに該当する透析レポート情報取得
   * @param ordNo オーダ番号
   * @return 透析レポート情報
   */
  TreatmentRecordReportInfo getTreatmentRecordReportInfoByOrdNo(Long ordNo);

  /**
   * 版確定処理.
   * @param ordNo 版確定するオーダ番号
   * @param confirm 更新する確定フラグ
   */
  // mod #8163 2022/12/13 後体重測定時、初版確定時に up_user_id, up_ind_user_id がその操作者に更新される dou start
  //mod FNSI-7531 劉全航 start
  // void updateTreatmentRecordForConfirm(Long ordNo, String confirm, Long updStaffId);
  void updateTreatmentRecordForConfirm(Long ordNo, String confirm);
  //mod FNSI-7531 劉全航 end
  // mod #8163 2022/12/13 後体重測定時、初版確定時に up_user_id, up_ind_user_id がその操作者に更新される dou end

  /**
   * 装置マスタの取得
   * <p>
   * オーダ番号に該当するレコードが存在しない場合、例外を発生させる.
   * </p>
   * @return 装置マスタ
   * @throws NotExistException オーダ番号に該当するレコードが存在しない場合
   */
  List<MstMachine> getMstMachineByOrdNoRst(Long ordNo) throws NotExistException;

  /**
   * 装置状態の取得
   * <p>
   * オーダ番号に該当するレコードが存在しない場合、例外を発生させる.
   * </p>
   * @return 装置状態
   * @throws NotExistException オーダ番号に該当するレコードが存在しない場合
   */
  List<MntMachineState> getMntMachineState(String facilityCd, Long ordNo) throws NotExistException;

  /**
   * 治療方法が特殊浄化かどうかの取得
   * <p>
   * 該当するレコードが存在しない場合、例外を発生させる.
   * </p>
   * @return 特殊浄化ならば"1"
   * @throws NotExistException コードに該当するレコードが存在しない場合
   */
  String getIsPurification(Integer treatmentCd) throws NotExistException;

  //add 帳票コード取得修正 房 start
  /**
   * レポートコードリスト取得
   * @param facilitySettingNo　施設設定番号
   * @param facilityCd 施設番号
   * @return レポートコードリスト
   */
  List<ReportCds> getReportCds(String facilitySettingNo, String facilityCd);
  //add 帳票コード取得修正 房 end

  //add FNSI内容修正 外部Api調用 房 start

  /**
   * 投与薬剤情報チェック
   * @param ordNo
   * @param facilityCd
   * @return
   */
  Integer getCheckIsHave(Long ordNo, String facilityCd);

  /**
   * 治療中ordNo取得
   * @param patId
   * @param stateList
   * @return
   */
  List<OrdMain> selectTreatingOrdno(Long patId, List<String> stateList);

  /**
   * お知らせ取得
   * @param facilityCd
   * @param deviceEdgeNo
   * @return
   */
  ComsvSet selectComsvSet(String facilityCd, Integer deviceEdgeNo);
 //add FNSI内容修正 外部Api調用 房 end
  //add FNSI内容修正 ベッド切り替え 房 start

  /**
   * ベッド切替処理
   * @param ordNo
   * @param facilityCd
   * @return
   */
  List<Long> bedChangeHandle(Long ordNo, Long bedNo, String facilityCd);
  //add FNSI内容修正 ベッド切り替え 房 start

 //add 死活監視ステータス取得 周雨晴 start
  /**
   * 治療記録（死活監視ステータス）の取得.
   * @param facilityCd 施設番号
   * @param deviceEdgeNo デバイスエッジ番号
   * @return 治療記録（死活監視ステータス）
   * @throws NotExistException コードに該当するレコードが存在しない場合
   */
  String getmonistatus(String facilityCd, Long deviceEdgeNo) throws NotExistException;
  //add 死活監視ステータス 周雨晴 end

  //mod FNSI修正401対応 房 start
  /**
   *
   * @param ordNo
   * @param treatmentRecordEquipInfo
   * @param facilityCd
   * @throws NotExistException
   * @throws IOException
   */
  void updateCheckListEquipInfo(Long ordNo, TreatmentRecordEquipInfo treatmentRecordEquipInfo, String facilityCd) throws NotExistException, IOException;

  /**
   *
   * @param ordNo
   * @param treatmentRecordMediInfo
   * @param facilityCd
   * @throws NotExistException
   * @throws IOException
   */
  void updateCheckListMediInfo(Long ordNo, TreatmentRecordMediInfo treatmentRecordMediInfo, String facilityCd) throws NotExistException, IOException;

  /**
   * 治療記録（治療条件）の更新
   * <p>
   * オーダ番号に該当するレコードが存在しない場合、例外を発生させる.
   * </p>
   * @param ordNo オーダ番号
   * @param treatmentRecordCondition 治療条件
   * @throws NotExistException オーダ番号に該当するレコードが存在しない場合
   */
  void updateTreatmentRecordCondition(Long ordNo, TreatmentRecordCondition treatmentRecordCondition, String facilityCd) throws NotExistException, InvocationTargetException, NoSuchMethodException, IllegalAccessException, IOException;
  //mod FNSI修正401対応 房 end

  /**
   *
   * DIALYSISSCHESENDののMODIFY_SEND_CLASS取得.
   *
   * @param facilityCd 施設コード
   * @return 設定値
   */
  Integer getCoopIniSchModifySendClass(String facilityCd);

  //add FNSI-7528 劉全航 start
  boolean getTreatmentRecordCondition(Long ordNo, String facilityCd);
  //add FNSI-7528 劉全航 end

  /* add by songqingyang  2023-02-01 [CodeOptimization]  start */
  ResponseEntity<TreatmentRecordReportInfo> getTreatmentRecordReportInfoByOrdNoAndNtssUser(Long ordNo, NtssUser ntssUser);

  ResponseEntity<String> getTreatingOrdNo(NtssUser ntssUser, Long ordNo);

  ResponseEntity<?> updateTreatmentRecordResult(Long ordNo, TreatmentRecordResult request, NtssUser ntssUser);
  /* add by songqingyang  2023-02-01 [CodeOptimization]  end */
  // #9315 2024.02.14 add 治療状況のみを取得する計量REST APIの追加 TDC片口 start

  /**
   * 対象ord_mainの治療状況を取得する
   * @param ordNo オーダ番号
   * @return 治療状況コード
   */
  String getRstDialysisState(Long ordNo);
  // #9315 2024.02.14 add 治療状況のみを取得する計量REST APIの追加 TDC片口 end
  // add #11471 ord_mian操作時の治療モードデータの登録 関 start
  ResponseEntity<TreatmentRecordReportInfo> getRstCondInfoSettingByOrdNo(Long ordNo);
  // add #11471 ord_mian操作時の治療モードデータの登録 関 end
}
