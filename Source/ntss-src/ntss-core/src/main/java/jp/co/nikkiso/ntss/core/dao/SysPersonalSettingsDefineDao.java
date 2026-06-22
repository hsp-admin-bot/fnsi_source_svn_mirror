package jp.co.nikkiso.ntss.core.dao;

import java.util.Arrays;
import java.util.List;

import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;
import org.springframework.dao.EmptyResultDataAccessException;

import jp.co.nikkiso.ntss.core.entity.SysPersonalSettingsDefine;

/**
 * 共通設定タブ定義のDaoインターフェース
 */
@Dao
@ConfigAutowireable
public interface SysPersonalSettingsDefineDao {

  /**
   * 指定したタブの共通設定定義を取得
   * @param tabDefineCd タブ定義コード
   * @return タブの共通設定定義
   */
  default SysPersonalSettingsDefine selectByTabDefineCd(Integer tabDefineCd) {
    final List<SysPersonalSettingsDefine> defines = selectByTabDefineCds(Arrays.asList(tabDefineCd));

    if(defines.isEmpty()) throw new EmptyResultDataAccessException(1);

    return defines.get(0);
  }

  /**
   * 指定したタブの共通設定定義を取得
   * @param tabDefineCds タブ定義コードの集合
   * @return タブの共通設定定義
   */
  @Select
  List<SysPersonalSettingsDefine> selectByTabDefineCds(Iterable<Integer> tabDefineCds);
}
