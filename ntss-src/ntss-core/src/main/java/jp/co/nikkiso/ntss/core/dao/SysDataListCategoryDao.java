package jp.co.nikkiso.ntss.core.dao;

import java.util.List;

import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;

import jp.co.nikkiso.ntss.core.entity.SysDataListCategory;
/**
 * データリストカテゴリのDAO.
 */
@ConfigAutowireable
@Dao
public interface SysDataListCategoryDao {

  /**
   * テンプレートコードによりデータリストカテゴリ配列を取得
   */
  @Select
  List<SysDataListCategory> selectByTemplateCd(Integer templateCd);
}
