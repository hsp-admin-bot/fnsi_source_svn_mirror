package jp.co.nikkiso.ntss.core.dao;

import java.util.List;
import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;
import org.seasar.doma.jdbc.SelectOptions;

import jp.co.nikkiso.ntss.core.entity.MstPatCalendarLayout;

@ConfigAutowireable
@Dao
public interface MstPatCalendarLayoutDao {
  @Select
  List<MstPatCalendarLayout> selectAll(SelectOptions options, MstPatCalendarLayout params);
}
