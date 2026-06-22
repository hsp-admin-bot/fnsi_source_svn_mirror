package jp.co.nikkiso.ntss.core.dao;

import java.util.List;

import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;

import jp.co.nikkiso.ntss.core.entity.MstMoniItem;

@ConfigAutowireable
@Dao
public interface MstMoniItemDao {
  
  @Select
  List<MstMoniItem> selectAll();
  @Select
  List<MstMoniItem> selectByFacility(String facility_cd);
  @Select
  List<MstMoniItem> selectByFacilityModel(String facility_cd, String model);
  @Select
  List<MstMoniItem> selectByFacilityModelMoniNo(String facility_cd, String model, int moni_no);
}
