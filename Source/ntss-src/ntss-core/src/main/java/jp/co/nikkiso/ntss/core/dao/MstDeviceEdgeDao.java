package jp.co.nikkiso.ntss.core.dao;

import java.util.List;

import org.seasar.doma.Dao;
import org.seasar.doma.Delete;
import org.seasar.doma.Insert;
import org.seasar.doma.Select;
import org.seasar.doma.Update;
import org.seasar.doma.boot.ConfigAutowireable;

import jp.co.nikkiso.ntss.core.entity.MstDeviceEdge;
import jp.co.nikkiso.ntss.core.entity.custom.DeviceEdge;

/**
 * デバイスエッジマスタのDaoインタフェース
 */
@ConfigAutowireable
@Dao
public interface MstDeviceEdgeDao {
  
  @Select
  List<MstDeviceEdge> selectAll();
  
  @Select
  MstDeviceEdge selectByEdgeNoAndFacilityCd(Integer deviceEdgeNo, String facilityCd);
  
  /**
   * 施設コードに紐づくデバイスエッジ情報を取得.
   * 
   * @param facilityCds 施設コード
   * @return デバイスエッジ情報のリスト
   */
  @Select
  List<DeviceEdge> selectByFacilityCds(List<String> facilityCds);
  
  /**
   * 施設コードに紐づくデバイスエッジ情報を取得(1施設のみ).
   * 
   * @param facilityCd 施設コード
   * @return デバイスエッジ情報のリスト
   */
  @Select
  List<MstDeviceEdge> selectByFacilityCd(String facilityCd);

  @Insert(sqlFile = true)
  int insert(MstDeviceEdge mstDeviceEdge);

  // del #8403 【デグレ】デバイスエッジマスタで新規レコードが保存できない dou start
  //add by ShiHongda 2023-02-01 [Instead of Trigger: tg_sync_mst_device_edge] --start /
  // @Insert
  // int insertMntDeviceEdgeStateByODE(MstDeviceEdge mstDeviceEdge);
  //add by ShiHongda 2023-02-01 [Instead of Trigger: tg_sync_mst_device_edge] --end /
  // del #8403 【デグレ】デバイスエッジマスタで新規レコードが保存できない dou end

  @Update(sqlFile = true)
  int update(MstDeviceEdge mstDeviceEdge);
  
  @Delete(sqlFile = true)
  int deleteByCd(String serialNo);

  //add by ShiHongda 2023-02-01 [Instead of Trigger: tg_sync_mst_device_edge] --start /
  @Select
  MstDeviceEdge selectBySerialNoSN(String serialNo);

  // del #8403 【デグレ】デバイスエッジマスタで新規レコードが保存できない dou start
  // @Delete
  // int deleteMntDeviceEdgeStateByODE(MstDeviceEdge mstDeviceEdge);
  // del #8403 【デグレ】デバイスエッジマスタで新規レコードが保存できない dou end
  //add by ShiHongda 2023-02-01 [Instead of Trigger: tg_sync_mst_device_edge] --end /

  // add #11015 デバイスエッジマスタで項目を削除した際に関連マスタで表示不正 zkm start
  @Select
  List<MstDeviceEdge> selectAllByFacilityCd(String facilityCd);

  @Update(sqlFile = true)
  int updateDelByCd(String serialNo);
  // add #11015 デバイスエッジマスタで項目を削除した際に関連マスタで表示不正 zkm end
}
