package jp.co.nikkiso.ntss.core.dao;

import java.util.List;
import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;
import org.seasar.doma.jdbc.SelectOptions;

import jp.co.nikkiso.ntss.core.entity.MstEquipmentSet;

@ConfigAutowireable
@Dao
public interface MstEquipmentSetDao {
  @Select
  List<MstEquipmentSet> selectAll(SelectOptions options, MstEquipmentSet params);

  @Select
  List<MstEquipmentSet> selectWithDeleted(SelectOptions options, MstEquipmentSet params);

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
