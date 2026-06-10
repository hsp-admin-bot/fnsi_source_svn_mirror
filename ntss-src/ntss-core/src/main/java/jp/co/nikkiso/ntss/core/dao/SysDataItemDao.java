package jp.co.nikkiso.ntss.core.dao;

import java.util.List;
import org.seasar.doma.Dao;
import org.seasar.doma.Delete;
import org.seasar.doma.Insert;
import org.seasar.doma.Select;
import org.seasar.doma.Update;
import org.seasar.doma.boot.ConfigAutowireable;
import org.seasar.doma.jdbc.SelectOptions;

import jp.co.nikkiso.ntss.core.entity.SysDataItem;


@ConfigAutowireable
@Dao
public interface SysDataItemDao {
  @Select
  List<SysDataItem> selectAll(SelectOptions options);

  @Select
  List<SysDataItem> selectByCd(String facility_cd, Integer template_no, Integer item_category, Integer item_sub_category);

  @Insert
  int insert(SysDataItem sysDataItem);

  @Delete
  int delete(SysDataItem sysDataItem);

  @Update
  int update(SysDataItem sysDataItem);
}
