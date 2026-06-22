package jp.co.nikkiso.ntss.core.dao;

import java.sql.Timestamp;
import java.util.List;

import org.seasar.doma.Dao;
import org.seasar.doma.Delete;
import org.seasar.doma.Insert;
import org.seasar.doma.Select;
import org.seasar.doma.Update;
import org.seasar.doma.boot.ConfigAutowireable;
import org.seasar.doma.jdbc.SelectOptions;

import jp.co.nikkiso.ntss.core.entity.PatObsRec;
import jp.co.nikkiso.ntss.core.entity.custom.PatObsRecView;

@ConfigAutowireable
@Dao
public interface PatObsRecDao {
  @Select
  List<PatObsRec> selectAll(SelectOptions options);

  @Select
  PatObsRec selectByCd(Long obsRecNo);

  @Select
  List<PatObsRecView> selectByViewSpan(Long pat_id,
      Long ctl_no,
      Short kind_no,
      Timestamp rec_date_from,
      Timestamp rec_date_to,
      String is_del,
      String is_newest);

  @Select
  List<PatObsRecView> selectByOrdNo(Long ord_no,
      Long ctl_no,
      Short kind_no,
      String is_del,
      String is_newest);

  @Select
  PatObsRecView selectByViewKey(Long patId, Long ctlNo);

  @Insert(sqlFile = true)
  int insertRenew(PatObsRec param);

  @Insert
  int insert(PatObsRec param);

  @Delete
  int delete(PatObsRec param);

  @Update(sqlFile = true)
  int update(PatObsRec param);

  @Update(excludeNull = true)
  int updatePatObsRec(PatObsRec param);

  @Select
  List<PatObsRec> selectByBbsCtlNo(Long bbsCtlNo);

  @Select
  PatObsRec selectById(Long patId, String facilityCd);
}
