package jp.co.nikkiso.ntss.core.dao;

import java.util.List;
import java.util.Map;

import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;
import org.seasar.doma.jdbc.SelectOptions;

import jp.co.nikkiso.ntss.core.entity.MstMedicineClass;

@ConfigAutowireable
@Dao
public interface MstMedicineClassDao extends MasterDao<Map<String,Object>>, UnifiedByCodeListDao {
  @Select
  List<MstMedicineClass> selectAll(SelectOptions options, MstMedicineClass params);

  @Select
  List<MstMedicineClass> selectAllIncludeDeleted(SelectOptions options, MstMedicineClass params);

  @Select
  MstMedicineClass selectByCd(Integer classCd);

  @Select
  List<MstMedicineClass> selectByCdList(List<Integer> classCdList);

  @Select
  List<MstMedicineClass> selectByClassType(Integer classType, String facilityCd);

  @Override
  @Select
  List<Map<String,Object>> selectAllStatus(Map<String,String> params);

  @Override
  @Select
  List<Map<String, Object>> selectAllStatusByCodeList(List<Integer> codeList);
}
