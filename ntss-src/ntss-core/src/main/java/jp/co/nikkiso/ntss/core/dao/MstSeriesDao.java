package jp.co.nikkiso.ntss.core.dao;

import java.util.List;

import org.seasar.doma.Dao;
import org.seasar.doma.Delete;
import org.seasar.doma.Insert;
import org.seasar.doma.Select;
import org.seasar.doma.Update;
import org.seasar.doma.boot.ConfigAutowireable;

import jp.co.nikkiso.ntss.core.entity.MstSeries;

/**
 * 系列施設マスタの Daoインタフェース.
 */
@ConfigAutowireable
@Dao
public interface MstSeriesDao {

  @Select
  List<MstSeries> selectAll();
  
  @Select
  MstSeries selectByCd(String seriesCd);
  
  @Insert
  int insert(MstSeries mstSeries);
  
  @Delete
  int delete(MstSeries mstSeries);
  
  @Update
  int update(MstSeries mstSeries);
  
}
