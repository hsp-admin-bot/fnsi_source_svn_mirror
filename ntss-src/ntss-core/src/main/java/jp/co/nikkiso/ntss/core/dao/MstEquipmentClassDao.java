package jp.co.nikkiso.ntss.core.dao;

import java.util.List;
import java.util.Map;

import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;
import org.seasar.doma.jdbc.SelectOptions;

import jp.co.nikkiso.ntss.core.entity.MstEquipmentClass;
import jp.co.nikkiso.ntss.core.entity.custom.MstEquipmentClassForChecklist;

@ConfigAutowireable
@Dao
public interface MstEquipmentClassDao extends MasterDao<Map<String,Object>> {
  @Select
  List<MstEquipmentClass> selectAll(SelectOptions options, MstEquipmentClass params);

  @Select
  List<MstEquipmentClass> selectAllIncludeDeleted(SelectOptions options, MstEquipmentClass params);

  @Select
  List<MstEquipmentClassForChecklist> selectAllChecklist(SelectOptions options, String facilityCd);

  @Select
  MstEquipmentClass selectByCd(Integer classCd);

  @Select
  List<MstEquipmentClass> selectByCdList(List<Integer> classCdList);

  @Override
  @Select
  List<Map<String,Object>> selectAllStatus(Map<String,String> params);
}
