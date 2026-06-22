package jp.co.nikkiso.ntss.core.dao;

import jp.co.nikkiso.ntss.core.entity.SysReportSetting;
import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;

import java.util.List;

/**
 * 機能帳票設定のDaoインタフェース
 */
@ConfigAutowireable
@Dao
public interface SysReportSettingDao {

  /**
   * 機能帳票設定データ収集
   * @return 機能帳票設定のリスト
   */
  //mod 7323 機能帳票マスタの機能名リストに初回リリースに含まれない機能が表示されている 周安寧 start
//  @Select
//  List<SysReportSetting> selectAll();
  @Select
  List<SysReportSetting> selectAll(String facilityCd);
//mod 7323 機能帳票マスタの機能名リストに初回リリースに含まれない機能が表示されている 周安寧 end
}
