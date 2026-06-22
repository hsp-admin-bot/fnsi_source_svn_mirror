package jp.co.nikkiso.ntss.core.dao;

import jp.co.nikkiso.ntss.core.entity.MstVitalGraph;
import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;

import java.util.List;

/**
 * バイトルグラフマスタのDaoインタフェース.
 */
@ConfigAutowireable
@Dao
public interface MstVitalGraphDao {

  /**
   * 指定された施設コードに一致するバイトルグラフマスタを取得します.
   *
   * @param facilityCd 施設コード
   * @return バイトルグラフ
   */
  @Select
  List<MstVitalGraph> selectByFacilityCd(String facilityCd);

}
