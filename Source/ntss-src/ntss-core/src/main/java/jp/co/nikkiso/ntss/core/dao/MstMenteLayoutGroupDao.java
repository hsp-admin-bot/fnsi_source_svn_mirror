package jp.co.nikkiso.ntss.core.dao;

import java.util.List;

import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;

import jp.co.nikkiso.ntss.core.entity.MstMenteLayoutGroup;

/**
 * 検査レイアウトグループDaoインタフェース.
 */
@ConfigAutowireable
@Dao
public interface MstMenteLayoutGroupDao {

  @Select
  List<MstMenteLayoutGroup> selectAll(String facilityCd);

  @Select
  MstMenteLayoutGroup selectById(Long menteLayoutGroupCd);
}
