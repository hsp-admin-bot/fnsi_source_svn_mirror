package jp.co.nikkiso.ntss.core.dao;

import java.util.List;
import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.Update;
import org.seasar.doma.boot.ConfigAutowireable;
import org.seasar.doma.jdbc.SelectOptions;

import jp.co.nikkiso.ntss.core.entity.MstPatListLayout;


@ConfigAutowireable
@Dao
public interface MstPatListLayoutDao {
  @Select
  List<MstPatListLayout> selectAll(SelectOptions options, MstPatListLayout params);
  
  @Update(sqlFile = true)
  int updateByCd(long pat_list_layout_cd, MstPatListLayout patListLayout);

  @Select
  MstPatListLayout selectByCd(Long patListLayoutCd);
}
