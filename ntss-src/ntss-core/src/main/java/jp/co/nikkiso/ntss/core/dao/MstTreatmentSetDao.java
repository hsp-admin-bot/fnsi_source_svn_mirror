package jp.co.nikkiso.ntss.core.dao;

import java.util.List;
import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;
import org.seasar.doma.jdbc.SelectOptions;

import jp.co.nikkiso.ntss.core.entity.MstTreatmentSet;


@ConfigAutowireable
@Dao
public interface MstTreatmentSetDao {
  @Select
  List<MstTreatmentSet> selectAll(SelectOptions options, MstTreatmentSet params);

  @Select
  List<MstTreatmentSet> selectByCd(Integer treatment_set_cd);

  /*
  @Insert
  int insert(MstTreatmentSet mstTreatmentSet);

  @Delete
  int delete(MstTreatmentSet mstTreatmentSet);

  @Update(sqlFile = true)
  int updateByCd(MstTreatmentSet param);
  */
}
