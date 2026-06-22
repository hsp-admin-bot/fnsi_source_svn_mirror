package jp.co.nikkiso.ntss.core.dao;

import java.util.List;

import jp.co.nikkiso.ntss.core.entity.custom.MtsMachineWithMachineRecordCd;
import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.Update;
import org.seasar.doma.boot.ConfigAutowireable;

import jp.co.nikkiso.ntss.core.entity.MniMonitor;
import jp.co.nikkiso.ntss.core.entity.custom.TreatmentStatusList;

/**
 * 治療状況リスト用のDaoインタフェース
 *
 */
@ConfigAutowireable
@Dao
public interface TreatmentStatusListDao {
  @Select
  List<TreatmentStatusList> selectAll(String facilityCd);

  @Select
  List<TreatmentStatusList> selectOrdMainUnedition(String facilityCd);

  /* add by chamaojia 2024-03-28 [10303、10304] add query interface --start */
  @Select
  List<TreatmentStatusList> selectTreatStatusListToOrd(String facilityCd, List<Long> bedCdList, List<Long> kurCdList);
  
  /* modify by chamaojia 2024-10-24 [9312] add param 【functionCode】 --start */
  /**
   * current patient inquiry regarding treatment status
   * @param facilityCd  施設コード
   * @param bedCdList   クール
   * @param functionCode   "1": 治療状況リスト -> 装置一覧  "2": 治療状況マップ -> 治療状況 
   * @return
   */
  @Select
  List<TreatmentStatusList> selectTreatStatusListToMachineNow(String facilityCd, List<Long> bedCdList, String functionCode);
  /* modify by chamaojia 2024-10-24 [9312] add param 【functionCode】 --end */

  @Select
  List<TreatmentStatusList> selectTreatStatusListToMachineNext(String facilityCd, List<Long> bedCdList, List<Long> kurCdList);

  @Select
  List<TreatmentStatusList> selectAllNextPatToOrdMain(String facilityCd);

  @Select
  List<TreatmentStatusList> selectTreatmentStatusMapToSchedule(String facilityCd, String treatDate, Long kurCd, List<Long> bedCdList);
  /* add by chamaojia 2024-03-28 [10303、10304] add query interface --start */

  @Select
  List<TreatmentStatusList> selectOrdMain(String facilityCd, String treatDate);

  @Select
  List<TreatmentStatusList> selectOrdMainOnSchedule(String facilityCd, String treatDate);

  //add FNSI redmine 5461 劉祥霖 start
  @Select
  List<TreatmentStatusList> selectOrdMainRstTreatInfoByTreatDate(String facilityCd, String treatDate);

  //add FNSI redmine 5461 劉祥霖 end
  @Select
  List<TreatmentStatusList> selectOrdMainOnMachine(String facilityCd);

  @Select
  MniMonitor selectMniMonitor(String facilityCd, String machineTypeCd, String machineSerial, String occurDate);

  @Select
  List<TreatmentStatusList> selectOrdMainRstUserInfo(Long ordNo);
  // add FNSI-装置自己診断の追加 徐 start
  @Select
  String selectMntMotionRecord(String facilityCd, String machineTypeCd, String machineSerial);
  // add FNSI-装置自己診断の追加 徐 end

  @Update(sqlFile = true)
  int updateOrdMainRstUserInfo(Long ordNo, String rst_puncture_user_info,String rst_return_user_info,String rst_charge_user_info);

  // add FNSI-7217 必要なデータを事前にクエリする 查 start
  @Select
  // mod #7862 2022-10-09 【デグレ】治療状況リスト，治療状況マップの表示が不正_再発 dou start
//  List<MtsMachineWithMachineRecordCd> selectMntMotionRecordByFacilityCd(String facilityCd);
  List<MtsMachineWithMachineRecordCd> selectMntMotionRecordByFacilityCd(String facilityCd, String machineTypeCd, String machineSerial, String beginDate, String endDate);
  // mod #7862 2022-10-09 【デグレ】治療状況リスト，治療状況マップの表示が不正_再発 dou end
  // add FNSI-7217 必要なデータを事前にクエリする 查 end

  /* modify #6746 zhangruixue 2023-03-08 治療状況リスト、治療状況マップを開くのが遅い --star */
  @Select
  List<MtsMachineWithMachineRecordCd> selectMntMotionRecordByFacilityCdAndRegDate(String facilityCd, List<MtsMachineWithMachineRecordCd> queryList);
  /* modify #6746 zhangruixue 2023-03-08 治療状況リスト、治療状況マップを開くのが遅い --end */

  @Select
  List<TreatmentStatusList> selectBedOrdIndex(String facilityCd);
}
