package jp.co.nikkiso.ntss.core.dao;

import java.util.List;

import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;

import jp.co.nikkiso.ntss.core.entity.MstSpitz;

/**
 * 検査項目マスタのDaoインタフェース.
 */
@ConfigAutowireable
@Dao
public interface MstSpitzDao {

  /**
   * 採血管マスタ：対象施設の採血管取得用
   * 施設コード：必須
   * @param facilityCd 施設コード
   * @return 対象施設の採血管一覧
   */
  @Select
  List<MstSpitz> selectByFacilityCd(String facilityCd);
}
