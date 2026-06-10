package jp.co.nikkiso.ntss.core.dao;

import jp.co.nikkiso.ntss.core.entity.OrdWeightScale;
import jp.co.nikkiso.ntss.core.entity.custom.ScaleBedAllState;
import org.seasar.doma.boot.ConfigAutowireable;
import jp.co.nikkiso.ntss.core.entity.MntScaleBedState;
import org.seasar.doma.Dao;
import org.seasar.doma.Insert;
import org.seasar.doma.Select;
import org.seasar.doma.Update;
import org.seasar.doma.Delete;
import org.seasar.doma.boot.ConfigAutowireable;
import java.util.List;

/**
 * スケールベッド状態管理のDaoインタフェース.
 */
@ConfigAutowireable
@Dao
public interface MntScaleBedStateDao {

  @Select
  MntScaleBedState selectByScaleBedCd(long bed_cd);

  @Select
  MntScaleBedState selectByBedCd(Long bedCd);

  @Select
  List<MntScaleBedState> selectByFacilityCd(String facilityCd);

  @Select
  List<ScaleBedAllState> selectScaleBedAllStateByFacility(String facilityCd);

  @Select
  List<ScaleBedAllState> selectScaleBedAllRstStateByFacility(String facilityCd,String treatLocalDate,String endState);

  @Insert(sqlFile=true)
  int insertNewScaleBed(String facilityCd);

  @Insert
  int insert(MntScaleBedState param);

  @Update
  int update(MntScaleBedState param);

  @Delete(sqlFile=true)
  int deleteByScaleBedFacilityCd(String facilityCd);

  @Delete(sqlFile=true)
  int deleteByScaleBedBedCd(Long bedCd);

  @Update(sqlFile = true)
  int updateByBed(Long bedCd,Long weightCd);

  @Select
  OrdWeightScale selectForOrdWeightScaleByBedCd(Long bedCd, Long targetOrdNo);
}
