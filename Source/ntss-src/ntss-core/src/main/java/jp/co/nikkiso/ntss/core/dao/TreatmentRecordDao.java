package jp.co.nikkiso.ntss.core.dao;

import java.sql.Timestamp;
import java.util.List;

import jp.co.nikkiso.ntss.core.entity.MniMonitor;
import jp.co.nikkiso.ntss.core.entity.MstTreatment;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.TreatmentRecordAddition;
import jp.co.nikkiso.ntss.core.entity.TreatmentRecordCondition;
import jp.co.nikkiso.ntss.core.entity.TreatmentRecordDeviceSetInfo;
import jp.co.nikkiso.ntss.core.entity.TreatmentRecordEquipInfo;
import jp.co.nikkiso.ntss.core.entity.TreatmentRecordMediInfo;
import jp.co.nikkiso.ntss.core.entity.TreatmentRecordMonitor;
import jp.co.nikkiso.ntss.core.entity.TreatmentRecordResult;
import jp.co.nikkiso.ntss.core.entity.TreatmentRecordResultMerge;
import jp.co.nikkiso.ntss.core.entity.TreatmentRecordRoundsInfo;
import jp.co.nikkiso.ntss.core.entity.TreatmentRecordVersionInfo;
import jp.co.nikkiso.ntss.core.entity.TreatmentRecordVitalMonitor;
import jp.co.nikkiso.ntss.core.entity.TreatmentRecordWeight;
import jp.co.nikkiso.ntss.core.entity.custom.ReportCds;
import jp.co.nikkiso.ntss.core.entity.custom.TreatmentRecordReportInfo;
import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.Update;
import org.seasar.doma.boot.ConfigAutowireable;

/**
 * 治療記録のDaoインタフェース.
 */
@ConfigAutowireable
@Dao
public interface TreatmentRecordDao {

  /**
   * オーダ番号に紐づく実績情報を取得.
   * @param ordNo オーダ番号
   * @return 実績情報
   */
  @Select(ensureResult = true)
  TreatmentRecordResult selectTreatmentRecordResultByOrdNo(Long ordNo);

  /**
   * 実績情報を更新する
   * @param ordNo オーダ番号
   * @param entity 実績情報
   * @return 更新件数
   */
  @Update(sqlFile = true)
  int updateTreatmentRecordForResult(Long ordNo, TreatmentRecordResult entity);

  /**
   * オーダ番号に紐づく投与薬剤情報を取得する
   * @param ordNo オーダ番号
   * @return 投与薬剤情報
   */
  @Select(ensureResult = true)
  TreatmentRecordMediInfo selectTreatmentRecordMediInfoByOrdNo(Long ordNo);

  /**
   * 投与薬剤情報を更新する.
   * @param ordNo オーダ番号
   * @return 更新件数
   */
  @Update(sqlFile = true)
  int updateTreatmentRecordForMediInfo(Long ordNo, TreatmentRecordMediInfo entity);

  /**
   * オーダ番号に紐づく実績情報(治療条件)を取得.
   * @param ordNo オーダ番号
   * @return 実績情報(治療条件)
   */
  @Select(ensureResult = true)
  TreatmentRecordCondition selectTreatmentRecordConditionByOrdNo(Long ordNo);

  /**
   * 治療条件を更新する
   * @param ordNo オーダ番号
   * @param entity 治療条件
   * @return 更新件数
   */
  @Update(sqlFile = true)
  int updateTreatmentRecordForCondition(Long ordNo, TreatmentRecordCondition entity);

  /**
   * 装置モニタ情報を取得.
   * @param ordNo オーダ番号
   * @param dataType データ種別
   * @return 装置モニタ情報のリスト
   */
  @Select
  List<MniMonitor> selectMniMonitorForRecirculationRate(Long ordNo, Short dataType);

  /**
   * オーダ番号に紐づく実績情報(体重)を取得.
   * @param ordNo オーダ番号
   * @return 実績情報(体重)
   */
  @Select(ensureResult = true)
  TreatmentRecordWeight selectTreatmentRecordWeightByOrdNo(Long ordNo);

  /**
   * 実績情報(体重)を更新する.
   * @param ordNo オーダ番号
   * @param entity 実績情報(体重)
   * @return 更新件数
   */
  @Update(sqlFile = true)
  int updateTreatmentRecordForWeight(Long ordNo, TreatmentRecordWeight entity);

  /**
   * オーダ番号に紐づく医療材料情報を取得する
   * @param ordNo オーダ番号
   * @return 医療材料情報
   */
  @Select(ensureResult = true)
  TreatmentRecordEquipInfo selectTreatmentRecordEquipInfoByOrdNo(Long ordNo);

  /**
   * 医療材料情報を更新する.
   * @param ordNo オーダ番号
   * @param entity 医療材料情報
   * @return 更新件数
   */
  @Update(sqlFile = true)
  int updateTreatmentRecordForEquipInfo(Long ordNo, TreatmentRecordEquipInfo entity);

  /**
   * 患者IDと施設コードに紐づく最新の治療記録レコードのオーダ番号を取得する.
   *
   * @param patId 患者ID
   * @param facilityCd 施設コード
   * @return オーダ番号
   */
  @Select
  Long selectLatestOrdNoByPatIdAndFacilityCd(Long patId, String facilityCd);

  /**
   * オーダ番号に紐づく指示コメント情報を取得する
   * @param ordNo オーダ番号
   * @return 指示コメント情報
   */
  @Select(ensureResult = true)
  TreatmentRecordAddition selectTreatmentRecordAdditionByOrdNo(Long ordNo);

  /**
   * 治療概要で使用する治療記録情報を取得する.
   *
   * @param ordNo オーダ番号
   * @return 治療記録レコードのEntity
   */
  @Select(ensureResult = true)
  OrdMain selectByOrdNoForSummary(Long ordNo);

  /**
   * 指示コメント情報を更新する.
   * @param ordNo オーダ番号
   * @param entity 指示コメント情報
   * @return 更新件数
   */
  @Update(sqlFile = true)
  int updateTreatmentRecordForAddition(Long ordNo, TreatmentRecordAddition entity);

  /**
   * オーダ番号に紐づく装置モニタデータ情報を取得する
   * @param ordNo オーダ番号
   * @param facilityCd 施設番号
   * @return 治療情報のEntity（装置モニタデータ情報）のリスト
   */
  @Select
  List<TreatmentRecordVitalMonitor> selectTreatmentRecordVitalMonitors(String facilityCd, Long ordNo);

  /**
   * オーダ番号に紐づく装置モニタデータ情報を取得する
   * @param ordNo オーダ番号
   * @return 治療情報のEntity（装置モニタデータ情報）のリスト
   */
  @Select
  List<TreatmentRecordMonitor> selectTreatmentRecordMonitors(Long ordNo);

  /**
   * 装置設定情報を取得.
   * @param ordNo オーダ番号
   * @return 治療情報のEntity（装置設定情報）
   */
  @Select(ensureResult = true)
  TreatmentRecordDeviceSetInfo selectTreatmentRecordDeviceSetInfoByOrdNo(Long ordNo);

  /**
   * 回診記録情報を取得.
   * @param ordNo オーダ番号
   * @return 回診記録情報のEntity（回診記録情報）
   */
  @Select(ensureResult = true)
  TreatmentRecordRoundsInfo selectTreatmentRecordRoundsInfoByOrdNo(Long ordNo);

  /**
   * 回診記録情報を更新する.
   * @param ordNo オーダ番号
   * @param entity 回診記録情報
   * @return 更新件数
   */
  @Update(sqlFile = true)
  int updateTreatmentRecordForRoundsInfo(Long ordNo, TreatmentRecordRoundsInfo entity);

  /**
   * オーダ番号に紐づく治療記録（実績マージ情報）を取得する.
   * @param ordNo オーダ番号
   * @return 治療記録（実績マージ情報）のリスト
   */
  @Select(ensureResult = true)
  List<TreatmentRecordResultMerge> selectTreatmentRecordResultMergeByOrdNo(Long ordNo);

  /**
   * 治療記録（実績マージ情報）を更新する.
   * @param ordNo オーダ番号
   * @param entity 治療記録（実績マージ情報）
   * @return 更新件数
   */
  @Update(sqlFile = true)
  int updateTreatmentRecordForResultMerge(Long ordNo, TreatmentRecordResultMerge entity);

  /**
   * 版情報を更新する.
   * @param entity 版情報
   * @return 更新件数
   */
  @Update(sqlFile = true)
  int updateTreatmentRecordForVersionInfo(TreatmentRecordVersionInfo entity);

  /**
   * 治療方法マスタを取得する.
   *
   * @param ordNo オーダ番号
   * @return 治療方法マスタのEntity
   */
  @Select(ensureResult = true)
  MstTreatment selectMstTreatmentByOrdNo(Long ordNo);

  /**
   * 透析レポート情報を取得する.
   *
   * @param ordNo オーダ番号
   * @return 治療記録で表示する透析レポート情報
   */
  @Select
  TreatmentRecordReportInfo selectTreatmentRecordReportInfoByOrdNo(Long ordNo);

  /**
   * 版数及び確定フラグを更新する.
   * この処理では、確定フラグが"0"の場合、版数の更新は行わない.
   * 確定フラグが"1"の場合、版数を現在登録されている版数に+1をし、確定フラグを"1:確定済"に更新する.
   * ※版確定の条件は以下の通り.
   * ※　rst_dialysis_state = 6
   * ※　and
   * ※　is_confirm = 1
   *
   * @param ordNo     更新対象のオーダ番号
   * @param confirm   更新する確定フラグ
   * @return 更新件数
   */
  @Update(sqlFile = true)
  // mod #8163 2022/12/13 後体重測定時、初版確定時に up_user_id, up_ind_user_id がその操作者に更新される dou start
  //mod FNSI-7531 劉全航 start
  // int updateTreatmentRecordForConfirm(Long ordNo, String confirm, Long updStaffId);
  int updateTreatmentRecordForConfirm(Long ordNo, String confirm);
  //mod FNSI-7531 劉全航 end
  // mod #8163 2022/12/13 後体重測定時、初版確定時に up_user_id, up_ind_user_id がその操作者に更新される dou end

  //add 帳票コード取得修正 房 start
  /**
   * レポートコードリスト取得
   * @param facilitySettingNo 施設設定番号
   * @param facilityCd 施設番号
   * @return レポートコードリスト
   */
  @Select
  List<ReportCds> selectReportCds(String facilitySettingNo, String facilityCd);
  //add 帳票コード取得修正 房 end

  //add 死活監視ステータス取得 周雨晴 start
  @Select
  String selectMonistatus(String facility_cd, Long device_edge_no);
  //add 死活監視ステータス取得 周雨晴 end

  //add FNSI修正486改修 房 start
  /**
   * オーダ番号に紐づく治療記録（実績マージ情報）を取得する.
   * @param ordNo オーダ番号
   * @return 治療記録（実績マージ情報）のリスト
   */
  @Select
  List<TreatmentRecordResultMerge> selectTreatmentRecordResultMergeListByOrdNo(
    String facilityCd
    , Long ordNo
    , Timestamp startDate
    , Timestamp endDate
    , String isUnknown
    , Long patId);
  //add FNSI修正486改修 房 end

  // add #11471 ord_mian操作時の治療モードデータの登録 関 start
  @Select
  TreatmentRecordReportInfo selectRstCondInfoSettingByOrdNo(Long ordNo);
  // add #11471 ord_mian操作時の治療モードデータの登録 関 end
}
