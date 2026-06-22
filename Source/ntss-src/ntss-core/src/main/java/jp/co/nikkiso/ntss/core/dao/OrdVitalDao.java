package jp.co.nikkiso.ntss.core.dao;

import java.util.List;
import org.seasar.doma.Dao;
import org.seasar.doma.Delete;
import org.seasar.doma.Insert;
import org.seasar.doma.Select;
import org.seasar.doma.Update;
import org.seasar.doma.boot.ConfigAutowireable;
import org.seasar.doma.jdbc.SelectOptions;

import jp.co.nikkiso.ntss.core.entity.OrdVital;


@ConfigAutowireable
@Dao
public interface OrdVitalDao {
  @Select
  List<OrdVital> selectAll(SelectOptions options);

  @Select
  List<OrdVital> selectByCd(String pat_id, Long ord_no, Integer edition, Short ctl_no, String dialysis_date_from, String dialysis_date_to);

  @Insert
  int insert(OrdVital ordVital);

  @Delete
  int delete(OrdVital ordVital);

  @Update
  int update(OrdVital ordVital);
}
