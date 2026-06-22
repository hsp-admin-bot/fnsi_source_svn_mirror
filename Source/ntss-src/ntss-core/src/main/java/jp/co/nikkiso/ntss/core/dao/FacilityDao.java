package jp.co.nikkiso.ntss.core.dao;

import java.util.List;

import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;

/**
 * 施設マスタ（ユーザメニュー系）のDaoインタフェース.
 */
@ConfigAutowireable
@Dao
public interface FacilityDao {

  /**
   * 施設コードに紐づく使用可能機能を取得.
   * @param facilityCd 施設コード
   * @return 使用可能機能のリスト
   */
  @Select
  List<String> selectUseFunctionByFacilityCd(String facilityCd);
}
