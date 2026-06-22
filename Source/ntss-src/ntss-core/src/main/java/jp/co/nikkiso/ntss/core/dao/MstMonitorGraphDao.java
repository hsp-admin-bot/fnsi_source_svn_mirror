package jp.co.nikkiso.ntss.core.dao;

import jp.co.nikkiso.ntss.core.entity.MstMonitorGraph;
import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;

import java.util.List;

/**
 * モニタグラフマスタのDaoインタフェース.
 */
@ConfigAutowireable
@Dao
public interface MstMonitorGraphDao {

  /**
   * 指定された施設コードに一致するモニタグラフマスタを取得します.
   *
   * @param facilityCd 施設コード
   * @return モニタグラフ
   */
  @Select
  List<MstMonitorGraph> selectByFacilityCd(String facilityCd);

}
