package jp.co.nikkiso.ntss.core.dao;

import jp.co.nikkiso.ntss.core.entity.ExceptionPeriod;
import jp.co.nikkiso.ntss.core.entity.MntMedicineSupport;
import jp.co.nikkiso.ntss.core.entity.custom.CheckAvgData;
import org.seasar.doma.Dao;
import org.seasar.doma.Delete;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;

import java.util.List;
import java.util.Map;

/**
 * 投薬支援のDaoインタフェース.
 */
@ConfigAutowireable
@Dao
public interface MstSupportDao {

  @Select
  List<MntMedicineSupport> selectMedicineSupport(String facilityCd);

  @Select
  List<Map<String,Object>> selectResultValue(String facilityCd, String cd, String patId, String startDate, String endDate,List<ExceptionPeriod> listExceptionPeriod);

  @Select
  List<CheckAvgData> selectCheckAvgData(String facilityCd, String patId, String startDate, String endDate, List<ExceptionPeriod> listExceptionPeriod, String cd);

  @Select
  List<Map<String,Object>> selectExceptionPeriod(String facilityCd, String patId);

  @Select
  // #11205 -ペンテスト2－4認可制御の不備  mod 20260416 start
  Map<String,Object> selectRange(String cd, String facilityCd);
  // #11205 -ペンテスト2－4認可制御の不備  mod 20260416 end

  @Select
  List<Map<String,Object>> selectDrugData(String facilityCd, String patId, String baseDate, String cd);

  @Select
  List<Map<String,Object>> selectMedicineData(String cd);

  @Select
  String selectRstValueData(String facilityCd, String patId, String startDate,String endDate, String suppliesCd,String rstClass,List<ExceptionPeriod> listExceptionPeriod);

  @Select
  List<Object> selectDayOfMonth(String startDate, String endDate);

  @Select
  String selectAvgData(String facilityCd, String patId, String startDate, String endDate, String cd,List<ExceptionPeriod> listExceptionPeriod);

  @Select
  String selectUnitOfCd(String cd, String type);

  @Select
  String selectWeekCountOfCd(String cd, String baseDate, String facilityCd, String patId);

  @Select
    // mod #7746 投与支援で薬剤に薬効換算マスタの薬剤グループを設定すると算出できない 鄭爽 start
//  List<Map<String,Object>> selectMultiplicationData(String groupCd, String baseDate, String facilityCd, String patId);
  List<Map<String,Object>> selectMultiplicationData(String groupCd, String startDate, String endDate, String facilityCd, String patId);
  // mod #7746 投与支援で薬剤に薬効換算マスタの薬剤グループを設定すると算出できない 鄭爽 end
  @Select
  List<String> selectOrdNo(String baseDate, String facilityCd, long patId);

  @Delete(sqlFile = true)
  int deleteMaterial(String baseDate, String facilityCd, long patId);

    // #11205 -ペンテスト2－4認可制御の不備  add 20260326 zhangYingJie start
    @Select
    MntMedicineSupport selectMntMedicineSupportByCd(String cd);
    // #11205 -ペンテスト2－4認可制御の不備  add 20260326 zhangYingJie end
}
