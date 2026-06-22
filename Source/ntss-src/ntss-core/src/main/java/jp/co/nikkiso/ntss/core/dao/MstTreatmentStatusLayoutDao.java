package jp.co.nikkiso.ntss.core.dao;

import java.util.List;

import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;
import org.seasar.doma.jdbc.SelectOptions;

import jp.co.nikkiso.ntss.core.entity.MstTreatmentStatusLayout;

@ConfigAutowireable
@Dao
public interface MstTreatmentStatusLayoutDao {
  @Select
  List<MstTreatmentStatusLayout> selectAll(SelectOptions options, MstTreatmentStatusLayout params);

  @Select
  List<MstTreatmentStatusLayout> selectAllByFacilityCd(String facilityCd);

  @Select
  MstTreatmentStatusLayout selectByLayoutNo(Long layoutNo);
}
