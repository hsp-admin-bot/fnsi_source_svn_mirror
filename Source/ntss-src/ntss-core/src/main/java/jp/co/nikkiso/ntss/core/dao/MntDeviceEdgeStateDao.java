package jp.co.nikkiso.ntss.core.dao;

import java.util.List;

import org.seasar.doma.Dao;
import org.seasar.doma.Delete;
import org.seasar.doma.Insert;
import org.seasar.doma.Select;
import org.seasar.doma.Update;
import org.seasar.doma.boot.ConfigAutowireable;

import jp.co.nikkiso.ntss.core.entity.MntDeviceEdgeState;
import jp.co.nikkiso.ntss.core.entity.custom.DeviceEdgeStateWithManage;

@ConfigAutowireable
@Dao
public interface MntDeviceEdgeStateDao {

  /**
   * 全件取得
   * @return
   */
  @Select
  List<MntDeviceEdgeState> selectAll();

  /**
   * 施設内のデータを取得
   * @param facilityCd
   * @param deviceEdgeNo (-1で施設内の全件取得)
   * @return
   */
  @Select
  List<MntDeviceEdgeState> selectByFacilityDeviceEdgeNo(String facilityCd, int deviceEdgeNo);

  @Update(sqlFile = true)
  int updateAliveMoni(MntDeviceEdgeState param);

  @Update
  int update(MntDeviceEdgeState param);

  @Insert(sqlFile = true)
  int insertAliveMoni(MntDeviceEdgeState deviceEdgeState);

  @Update(sqlFile = true)
  int updateAliveMoniStatus(MntDeviceEdgeState deviceEdgeState);

  /**
   * 死活監視メール送信状況更新
   * @param deviceEdgeState
   * @return
   */
  @Update(sqlFile = true)
  int updateSendMailStatus(MntDeviceEdgeState deviceEdgeState);

  /**
   * DE更新予約情報の更新
   * @param deviceEdgeState
   * @return
   */
  @Update(sqlFile = true)
  int updatePlan(MntDeviceEdgeState deviceEdgeState);

  /**
   * DE状態と紐づく遠隔管理命令情報を取得
   * @param facilityCd 施設コード（nullで全施設）
   * @param deviceEdgeNo デバイスエッジ番号（施設コードnull時は無視）
   * @return
   */
  @Select
  List<DeviceEdgeStateWithManage> selectStateWithManage(String facilityCd, Integer deviceEdgeNo);

  /* add by quzhinan  2023-02-01 [Trigger]  start */
  @Delete(sqlFile = true)
  int deleteByFacilityDeviceEdge(String facilityCd, Integer deviceEdgeNo);

  @Insert(sqlFile = true)
  int insertFacilityDeviceEdge(String facilityCd, Integer deviceEdgeNo);
  /* add by quzhinan  2023-02-01 [Trigger]  end */
}
