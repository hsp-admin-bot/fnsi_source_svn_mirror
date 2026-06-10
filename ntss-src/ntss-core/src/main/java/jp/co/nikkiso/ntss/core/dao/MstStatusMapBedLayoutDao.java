package jp.co.nikkiso.ntss.core.dao;

import java.util.List;
import java.util.Map;

import org.seasar.doma.Dao;
import org.seasar.doma.Delete;
import org.seasar.doma.Insert;
import org.seasar.doma.Select;
import org.seasar.doma.Update;
import org.seasar.doma.boot.ConfigAutowireable;

import jp.co.nikkiso.ntss.core.entity.MstStatusMapBedLayout;

@ConfigAutowireable
@Dao
public interface MstStatusMapBedLayoutDao {
  @Select
  MstStatusMapBedLayout selectByCd(String facilityCd, Integer layoutId);

  @Select
  List<MstStatusMapBedLayout> selectByFacilityCd(String facilityCd);

  @Insert(sqlFile = true)
  int insertRenew(MstStatusMapBedLayout param);

  @Insert
  int insert(MstStatusMapBedLayout param);

  @Delete
  int delete(MstStatusMapBedLayout param);

  @Update(sqlFile = true)
  int update(MstStatusMapBedLayout param);

  /**
   * @title NO6822 facilityCd、bedLayoutを用いて条件を調べてリストを取得する
   * @param facilityCd (施設コード)
   * @param machineNo (装置番号)
   * @return List<MstStatusMapBedLayout>
   * @author 崔fc
   * @Date 2021-12-10 12:09:30
   */
  @Select
  List<MstStatusMapBedLayout> selectByFacilityCdAndMachineNo(String facilityCd, String machineNo);

  /* add by chamaojia 2024-03-28 [10303、10304] add query interface --start */
  @Select
  List<Long> selectByFacilityCdAndLayoutIdToBedCd(String facilityCd, Long layoutId);
  /* add by chamaojia 2024-03-28 [10303、10304] add query interface --end */

  /**
   * @title NO6822 layout_idでbed_layoutフィールドを更新する
   * @param conditions
   * @author 崔fc
   * @Date 2021-12-10 12:09:30
   */
  @Update(sqlFile = true)
  int updateByLayoutId(Map<String, String> conditions);

  /**
   * @title NO6606 bed_cdを用いて条件を調べてリストを取得する
   * @param bedCd (ベッドコード)
   * @return List<MstStatusMapBedLayout>
   * @author 崔fc
   * @Date 2022-01-25 14:28:30
   */
  @Select
  List<MstStatusMapBedLayout> selectByBedCd(String bedCd);
}
