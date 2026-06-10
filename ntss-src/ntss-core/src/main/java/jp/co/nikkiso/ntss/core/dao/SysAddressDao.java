package jp.co.nikkiso.ntss.core.dao;

import java.util.List;
import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;
import org.seasar.doma.jdbc.SelectOptions;
import jp.co.nikkiso.ntss.core.entity.SysAddress;

/**
 * sys_address(住所マスタ)のインターフェイスクラス
 */
@ConfigAutowireable
@Dao
public interface SysAddressDao {
  @Select
  List<SysAddress> selectAll(SelectOptions options, SysAddress params);
}
