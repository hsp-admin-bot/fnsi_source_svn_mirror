package jp.co.nikkiso.ntss.core.dao;

import java.sql.Timestamp;
import java.util.List;

import org.seasar.doma.Dao;
import org.seasar.doma.Insert;
import org.seasar.doma.Select;
import org.seasar.doma.Update;
import org.seasar.doma.boot.ConfigAutowireable;

import jp.co.nikkiso.ntss.core.entity.custom.TreatmentStatusListAlarmRecord;

/**
 * 警報注意履歴のDaoインタフェース
 */
@ConfigAutowireable
@Dao
public interface MntAlarmRecordDao {

  @Select
  List<TreatmentStatusListAlarmRecord> selectByOccurDate(String facilityCd, Timestamp occurDateStart, Timestamp occurDateEnd);

  @Insert
  int insert(TreatmentStatusListAlarmRecord treatmentStatusListAlarmRecord);
  @Update
  int update(TreatmentStatusListAlarmRecord treatmentStatusListAlarmRecord);
}
