package jp.co.nikkiso.ntss.core.dao;

import jp.co.nikkiso.ntss.core.entity.DevMenteMain;
import jp.co.nikkiso.ntss.core.entity.MstMachineReportList;
import jp.co.nikkiso.ntss.core.entity.MstRoomBedGroup;
import jp.co.nikkiso.ntss.core.entity.custom.CusMachineInfoPeriodic;
import jp.co.nikkiso.ntss.core.entity.custom.CusMachineInfoVersion;
import jp.co.nikkiso.ntss.core.entity.custom.MachineInspection;
import jp.co.nikkiso.ntss.core.entity.custom.PartsRunning;
import jp.co.nikkiso.ntss.core.entity.custom.SchedulePlanData;
import org.seasar.doma.Dao;
import org.seasar.doma.Insert;
import org.seasar.doma.Select;
import org.seasar.doma.Update;
import org.seasar.doma.boot.ConfigAutowireable;
import org.seasar.doma.jdbc.Result;

import java.sql.Date;
import java.sql.Timestamp;
import java.util.List;

/**
 * 検査結果Daoインタフェース.
 */
@ConfigAutowireable
@Dao
public interface DevMenteMainDao {
  @Select
  List<MstRoomBedGroup> selectBedList(List<String> bedGroupList);

  @Select
  List<MachineInspection> selectMachineSearchCondition(
      List<String> machineTypeList, List<Long> listBedCd,
      String facilityCd);

  @Select
  List<MstRoomBedGroup> selectConditionBedList(Long bedGroupCd);
  @Select
  List<MachineInspection> selectDailyMachineSearchCondition(
      String facilityCd, List<String> machineTypeList, List<Long> listBedCd,
      String keyword);

  @Select
  List<MachineInspection> selectMachine(String facilityCd);
  @Select
  List<MachineInspection> selectMachineByLayoutCd(String facilityCd, Long layoutCd);

  @Select
  List<DevMenteMain> selectResultInspectionByMachineAndMainteDateAndClass(
      String facilityCd, String mainteClass, Long machineNo,
      String mainteDate, String mainteDateHistory);

  @Select
  List<DevMenteMain> selectDevMenteMainDatalist(
      String facilityCd, String startDate, String endDate);
  @Select
  List<DevMenteMain> selectDevMenteMainlayoutans1list(
      String facilityCd, String startDate, String endDate);
  @Select
  List<DevMenteMain> selectDevMenteMainlayoutans2list(
      String facilityCd, String startDate, String endDate);
  @Select
  List<DevMenteMain> selectDevMenteMaingroupans1list(
      String facilityCd, String startDate, String endDate);
  @Select
  List<DevMenteMain> selectDevMenteMaingroupans2list(
      String facilityCd, String startDate, String endDate);

  @Select
  List<DevMenteMain> selectDevMenteMainDatalistByComType(String facilityCd);

  @Select
  List<DevMenteMain> selectPeriodicHistory(
      String facilityCd, String machineNo, String menteClass,
      String menteDateStart, String menteDateEnd);

  @Select
  List<DevMenteMain> findListMenteMainByLayoutID(
      String facilityCd, Date menteDate, Long menteLayoutCd);

  @Select
  Long selectNextVal();

  @Insert(sqlFile = true)
  Result<DevMenteMain> insert(DevMenteMain devMenteMain);

  @Insert(sqlFile = true)
  int insertAListMenteMain(List<DevMenteMain> devMenteMains);

  @Update
  Result<DevMenteMain> update(DevMenteMain devMenteMain);

  @Update(sqlFile = true)
  int updatePassAllDaily(
      List<DevMenteMain> devMenteMains, Long checkerId, String detail,
      Timestamp update);

  @Select
  DevMenteMain findMenteMainById(Long devMenteNo);

  @Select
  CusMachineInfoPeriodic selectMachineDetail(Long machineNo);

  @Select
  List<DevMenteMain> selectResultsByMainteDateSpan(
      String facilityCd, String mainteClass, String mainteDateStart,
      String mainteDateEnd);

  @Update(sqlFile = true)
  int updateIsDeleteRecord(List<Long> mainNoList);

  @Select
  PartsRunning selectUseTimeByKey(
      String facilityCd, String machineTypeCd, String machineSerial);

  @Select
  List<DevMenteMain> selectResultsPeriodicByDateListAndNo(
      Date menteDate, Long menteLayoutGroupCd, Long machineNo,
      String facilityCd, String menteClass);

  @Update(sqlFile = true)
  int updateDeletMainteMainByTemDate(String temDate, List<Long> machineNoList);
  @Update(sqlFile = true)
  int updateDeletMainteMainByDevMenteMain(
      String temDate, Long menteLayoutGroupCd, Long machineNo);

  @Select
  CusMachineInfoVersion findMachineById(Long machineNo);

  @Select
  List<Long> selectLayoutCd(
      Long machineNo, String menteDate, String firstName, String firstOrd,
      String secondName, String secondOrd, String thirdName, String thirdOrd);

  @Select
  List<Long> selectLayoutCdByMainteClass(
      Long machineNo, String menteDate, String firstName, String firstOrd,
      String secondName, String secondOrd, String thirdName, String thirdOrd,
      String mainteClass);
  @Select
  List<Long> selectReportCdByMainteClass(
      Long machineNo, String menteDate, String facilityCd, String mainteClass);
  @Select
  List<Long> selectReportCdByMainteClass2(
      Long machineNo, String menteDate, String facilityCd, String mainteClass);

  // add #11117 日常点検記録簿が1ページ1装置で出力される limingzhe start
  @Select
  List<MstMachineReportList> selectReportCdandMachineNoListByMainte(
      String mainteClass, List<Long> machineNos, String facilityCd,
      String fromDate, String toDate);
  // add #11117 日常点検記録簿が1ページ1装置で出力される limingzhe end
  
  /**
   * 指定期間の定期点検データ取得(スケジュール表の予定表示用)
   * @param facilityCd 施設コード
   * @param startDate 開始日
   * @param endDate 終了日
   * @return 定期点検リスト
   */
  @Select
  List<SchedulePlanData> selectScheduleListByPeriod(
    String facilityCd, String startDate, String endDate);
}
