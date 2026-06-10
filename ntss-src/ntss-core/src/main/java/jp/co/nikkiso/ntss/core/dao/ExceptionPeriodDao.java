package jp.co.nikkiso.ntss.core.dao;

import jp.co.nikkiso.ntss.core.entity.ExceptionPeriod;
import org.seasar.doma.boot.ConfigAutowireable;
import org.seasar.doma.Dao;
import org.seasar.doma.Delete;
import org.seasar.doma.Insert;
import org.seasar.doma.Select;
import org.seasar.doma.Update;
import java.util.List;

@ConfigAutowireable
@Dao
public interface ExceptionPeriodDao {

  @Select
  List<ExceptionPeriod> selectOrdExceptionPeriod(String facilityCd, Long patId);

  @Insert
  int insert(ExceptionPeriod entity);

  @Delete(sqlFile = true)
  int deleteOrdExceptionPeriod(Long exceptionPeriodNo);

  @Update(sqlFile = true)
  int upDateOrdExceptionPeriod(Long exceptionPeriodNo, String exceptionPeriodFrom, String exceptionPeriodTo, Long updStaffId);

}
