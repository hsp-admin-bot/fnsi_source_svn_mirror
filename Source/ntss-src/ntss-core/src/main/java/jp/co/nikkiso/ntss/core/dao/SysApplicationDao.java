package jp.co.nikkiso.ntss.core.dao;

import jp.co.nikkiso.ntss.core.entity.SysApplication;
import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;
import org.seasar.doma.jdbc.SelectOptions;

import java.util.List;

/**
 * sys_application(アプリケーションダウンロード)のインターフェイスクラス
 */
@ConfigAutowireable
@Dao
public interface SysApplicationDao {
  @Select
  SysApplication selectByFileName(String filename, String is_disp, String is_del);
}
