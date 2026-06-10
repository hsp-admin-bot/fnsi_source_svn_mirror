package jp.co.nikkiso.ntss.core.dao;

import java.util.List;

import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;
import org.seasar.doma.jdbc.SelectOptions;

import jp.co.nikkiso.ntss.core.entity.MstFacilityCalendarLayout;

@ConfigAutowireable
@Dao
public interface MstFacilityCalendarLayoutDao {

  /**
   * すべてのマスター施設カレンダーレイアウトを選択
   * @param options
   * @param facilityCd 施設コード
   */
  @Select
  List<MstFacilityCalendarLayout> selectAll(SelectOptions options, String facilityCd);

  /**
   * コードによるマスター施設カレンダーレイアウトの選択
   * @param facCalLayoutCd 施設カレンダーレイアウトコード
   */
  @Select
  MstFacilityCalendarLayout selectById(Long facCalLayoutCd);
}
