package jp.co.nikkiso.ntss.core.dao;

import java.util.List;

import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;

import jp.co.nikkiso.ntss.core.entity.custom.TreatmentStatusMap;

/**
 * 治療状況リスト用のDaoインタフェース
 *
 */
@ConfigAutowireable
@Dao
public interface TreatmentStatusMapDao {
  @Select
  List<TreatmentStatusMap> selectMarker(List<Long> ord_no);

  @Select
  List<TreatmentStatusMap> selectBeforeMoveOrdMain(Long ordNo, Long bedCd);
}
