package jp.co.nikkiso.ntss.core.dao;

import java.util.Map;
import java.util.List;
import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;
import org.seasar.doma.jdbc.SelectOptions;

import jp.co.nikkiso.ntss.core.entity.MstEquipmentSet;

@ConfigAutowireable
@Dao
public interface MstEquipmentSetDao extends MasterDao<Map<String,Object>>, UnifiedByCodeListDao {
  @Select
  List<MstEquipmentSet> selectAll(SelectOptions options, MstEquipmentSet params);

  @Select
  List<MstEquipmentSet> selectWithDeleted(SelectOptions options, MstEquipmentSet params);

  /**
   * mst-list-compose 用：表示対象（is_del=0 & is_disp=1）に加え、
   * initEquipmentSetCd が指定された場合は削除済み行も含めて返却する（接頭辞用に deleted/includeDeleted を付与）。
   */
  @Override
  @Select
  List<Map<String,Object>> selectAllStatus(Map<String,String> params);

  @Override
  @Select
  List<Map<String, Object>> selectAllStatusByCodeList(List<Integer> codeList);

  /**
   * 指定した医療材料が含まれる医療材料セットリストを返却する
   * @param facilityCd
   * @param equipType (0：医療材料、1：ダイアライザ)
   * @param equipmentCdList
   * @return
   */
  @Select
  List<MstEquipmentSet> selectByEquipmentCdList(String facilityCd, Integer equipType, List<String> equipmentCdList);
}
