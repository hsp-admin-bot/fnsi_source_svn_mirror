package jp.co.nikkiso.ntss.core.dao;

import jp.co.nikkiso.ntss.core.entity.SysReleaseInfo;

import java.util.List;

import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;

/**
 * 通知メッセージのDaoインタフェース.
 */
@ConfigAutowireable
@Dao
public interface SysReleaseInfoDao {

  /**
   * リリース情報一覧を取得します.
   *
   * @return リリース情報
   */
  @Select
  List<SysReleaseInfo> selectAll();

  @Select
  String selectPath(Long ctl_no);
}
