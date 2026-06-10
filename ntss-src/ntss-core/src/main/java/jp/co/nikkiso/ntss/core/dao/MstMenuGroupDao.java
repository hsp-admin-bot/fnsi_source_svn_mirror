package jp.co.nikkiso.ntss.core.dao;

import java.util.List;

import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;

import jp.co.nikkiso.ntss.core.entity.MstMenuGroup;


@ConfigAutowireable
@Dao
public interface MstMenuGroupDao {

  /**
   * メニューグループマスタを取得する
   * @param facilityCd 施設コード
   * @return メニューグループリスト
   */
  @Select
  List<MstMenuGroup> selectAll(String facilityCd);

}
