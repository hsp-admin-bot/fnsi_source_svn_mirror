package jp.co.nikkiso.ntss.core.dao;

import java.util.List;

import org.seasar.doma.Dao;
import org.seasar.doma.Delete;
import org.seasar.doma.Insert;
import org.seasar.doma.Select;
import org.seasar.doma.Update;
import org.seasar.doma.boot.ConfigAutowireable;

import jp.co.nikkiso.ntss.core.entity.MstArea;

/**
 * 地域マスタのDaoインタフェース.
 */
@ConfigAutowireable
@Dao
public interface MstAreaDao {
  
  @Select
  List<MstArea> selectAll();
  
  @Select
  MstArea selectByCd(String areaCd);
  
  @Insert
  int insert(MstArea mstArea);
  
  @Delete
  int delete(MstArea mstArea);
  
  @Update
  int update(MstArea mstArea);
  
}
