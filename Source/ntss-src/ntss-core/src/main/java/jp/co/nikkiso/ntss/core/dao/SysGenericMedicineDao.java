package jp.co.nikkiso.ntss.core.dao;

import java.util.List;

import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;
import org.seasar.doma.jdbc.SelectOptions;

import jp.co.nikkiso.ntss.core.entity.SysGenericMedicine;

@ConfigAutowireable
@Dao
public interface SysGenericMedicineDao {
  @Select
  List<SysGenericMedicine> selectAll(SelectOptions options);

  @Select
  List<SysGenericMedicine> selectAllIncludeDeleted(SelectOptions options);
}
