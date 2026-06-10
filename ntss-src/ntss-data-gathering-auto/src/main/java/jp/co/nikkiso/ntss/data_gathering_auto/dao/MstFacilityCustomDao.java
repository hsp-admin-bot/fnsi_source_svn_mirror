package jp.co.nikkiso.ntss.data_gathering_auto.dao;

import java.util.List;
import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;

import jp.co.nikkiso.ntss.data_gathering_auto.entity.MstFacilityCustom;

/**
 * 施設マスタDao
 *
 */
@ConfigAutowireable
@Dao
public interface MstFacilityCustomDao {
  @Select
  List<MstFacilityCustom> selectAll();
}
