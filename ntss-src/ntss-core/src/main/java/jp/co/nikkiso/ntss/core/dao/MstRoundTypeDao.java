package jp.co.nikkiso.ntss.core.dao;

import java.util.List;

import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;

import jp.co.nikkiso.ntss.core.entity.MstRoundType;

/**
 * 種別マスタのDaoインタフェース.
 */
@ConfigAutowireable
@Dao
public interface MstRoundTypeDao {

  /**
   * 指定された施設コードに一致する種別マスタを取得します.
   *
   * @param facilityCd 施設コード
   * @return 種別
   */
  @Select
  List<MstRoundType> selectByFacilityCd(String facilityCd);

  /**
   * 指定された種別コードに一致する種別マスタを取得します.
   *
   * @param roundTypeCd 種別コード
   * @return 種別
   */
  @Select
  MstRoundType selectByRoundTypeCd(Long roundTypeCd);

}
