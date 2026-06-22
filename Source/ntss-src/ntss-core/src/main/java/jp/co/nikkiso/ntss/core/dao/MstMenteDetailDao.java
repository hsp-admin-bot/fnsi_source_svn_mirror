package jp.co.nikkiso.ntss.core.dao;

import java.util.List;

import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;

import jp.co.nikkiso.ntss.core.entity.MstMenteDetail;
import jp.co.nikkiso.ntss.core.entity.MstMainteCategoryAndDetail;

/**
 * 検査項目情報Daoインタフェース.
 */
@ConfigAutowireable
@Dao
public interface MstMenteDetailDao {

  @Select
  List<MstMenteDetail> selectByFacilityCdList(String facilityCd);

  @Select
  List<MstMenteDetail> selectMenteDetailAll(String facilityCd, String mainteClass);

  @Select
  List<MstMenteDetail> selectByDetailCdListWithDeleted(List<Long> detailCdList);
  // add #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe start
  @Select
  List<MstMainteCategoryAndDetail> selectDailyMainteCategoryandDetailList(String facilityCd, String mainteClass);

  @Select
  List<MstMainteCategoryAndDetail> selectPeriodicMainteCategoryandDetailList(String facilityCd, String mainteClass);
  // add #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe end

}
