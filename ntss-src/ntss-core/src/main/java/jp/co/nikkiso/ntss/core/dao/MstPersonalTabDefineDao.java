package jp.co.nikkiso.ntss.core.dao;

import java.util.List;

import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;

import jp.co.nikkiso.ntss.core.entity.TabDisplayNameAndContentsId;

@Dao
@ConfigAutowireable
public interface MstPersonalTabDefineDao {

  /**
   * 施設コードに紐づく個人設定タブ定義を取得.
   * @param facilityCd 施設コード
   * @return 個人設定タブ定義
   */
  @Select
  List<TabDisplayNameAndContentsId> selectDisplayNameAndContentsIdByFacilityCd(String facilityCd);
}
