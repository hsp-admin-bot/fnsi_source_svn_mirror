package jp.co.nikkiso.ntss.core.dao;

import java.util.List;

import jp.co.nikkiso.ntss.core.config.ConfigAutowireableAuthDb;
import jp.co.nikkiso.ntss.core.entity.SysSystemManager;
import org.seasar.doma.Dao;
import org.seasar.doma.Select;

/**
 * システム設定マスタのDaoインタフェース.
 */

@Dao
@ConfigAutowireableAuthDb
public interface SysSystemManagerDao {

  @Select
  List<SysSystemManager> selectByCtlNo(int ctlNo);
}
