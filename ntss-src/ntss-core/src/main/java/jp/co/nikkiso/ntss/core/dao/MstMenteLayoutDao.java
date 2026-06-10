package jp.co.nikkiso.ntss.core.dao;

import jp.co.nikkiso.ntss.core.entity.MstMachineType;
import jp.co.nikkiso.ntss.core.entity.MstMenteLayout;
import jp.co.nikkiso.ntss.core.entity.MstMenteLayoutGroupByMachineType;
import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;

import java.util.List;

/**
 * 検査レイアウトDaoインタフェース.
 */
@ConfigAutowireable
@Dao
public interface MstMenteLayoutDao {

  @Select
  List<MstMenteLayout> selectLayoutByClass(String facilityCd, String layoutClass);

  @Select
  List<MstMenteLayout> selectDailyLayoutByMachineNo(String facilityCd, Long machineNo);

  @Select
  List<MstMenteLayout> selectDailyLayoutByCategoryCd(String facilityCd, Long mainteCategoryCd);

  @Select
  List<MstMenteLayout> selectLayoutByClassWithMachineTypeInfo(String facilityCd, String layoutClass);

  @Select
  MstMenteLayout selectLayoutByID(Long mainteLayoutCd);

  @Select
  MstMenteLayout selectLayoutByIDWithDeleted(Long mainteLayoutCd);

  @Select
  List<MstMachineType> selectMachineTypes(String facilityCd);

  @Select
  List<MstMenteLayout> selectLayoutsByIdList(List<Long> layoutCdList);

  @Select
  List<MstMenteLayoutGroupByMachineType> selectLayoutGroupByMachineType(String facilityCd);
}
