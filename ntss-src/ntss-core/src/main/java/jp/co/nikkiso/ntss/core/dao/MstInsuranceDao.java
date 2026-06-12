package jp.co.nikkiso.ntss.core.dao;

import jp.co.nikkiso.ntss.core.entity.MstInsurance;
import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;

import java.util.List;
import java.util.Map;


@ConfigAutowireable
@Dao
public interface MstInsuranceDao extends MasterDao<Map<String, Object>> {

  @Select
  List<MstInsurance> selectAll();

  /**
   * mst-list-compose 用：保険マスタ（削除済み含む、init を含める）
   */
  @Override
  @Select
  List<Map<String, Object>> selectAllStatus(Map<String, String> params);
}

