package jp.co.nikkiso.ntss.core.dao;

import java.sql.Timestamp;
import java.util.List;
import org.seasar.doma.Dao;
import org.seasar.doma.Delete;
import org.seasar.doma.Insert;
import org.seasar.doma.Select;
import org.seasar.doma.Update;
import org.seasar.doma.boot.ConfigAutowireable;

import jp.co.nikkiso.ntss.core.entity.OrdWeightScale;

@ConfigAutowireable
@Dao
public interface OrdWeightScaleDao {

  @Select
  OrdWeightScale selectByCd(Long weightScaleNo);

  @Select
  OrdWeightScale selectTempDataByCd(Long weightScaleNo);

  @Select
  List<OrdWeightScale> selectByFacility(String facilityCd, Timestamp measure_date_from, Timestamp measure_date_to);

  @Select
  OrdWeightScale selectLastHistory(Long ordNo, Short scaleClass, Short scaleMode);

  @Select
  OrdWeightScale selectLastHistoryByScaleClass(Long ordNo, Short scaleClass);

  @Select
  OrdWeightScale selectLastHistoryByOrdNoSameDay(Long ordNo, String today);

  @Select
  OrdWeightScale selectLastHistoryAnotherOrdNoSameDay(Long ordNo, Long patId, String today);

  @Select
  OrdWeightScale selectLastHistoryByPatIdNoSchedule(Long patId);
  // add #7716 2022/11/18 患者の体重測定値にも値が入力されてしまっている(何の値か不明) dou start
  @Select
  OrdWeightScale selectLastHistoryByPatIdAndToday(Long patId, String today);
  // add #7716 2022/11/18 患者の体重測定値にも値が入力されてしまっている(何の値か不明) dou end
  @Insert
  int insert(OrdWeightScale entity);

  @Delete
  int delete(OrdWeightScale entity);

  @Update
  int update(OrdWeightScale entity);

  @Update(include = {"printStatus", "printErrorMessage", "upDate"})
  int updatePrintStatus(OrdWeightScale entity);

  @Update(sqlFile=true)
  int updateOldDataTimeOut(String facilityCd, Long ordNo, Long machineNo);
  // add FNSI-次回同じ患者を検索する場合測定値保存する 徐 start
  @Select
  double selectMeasuredValueByPatId(String facilityCd, Long patId);
  // add FNSI-次回同じ患者を検索する場合測定値保存する 徐 end
}
