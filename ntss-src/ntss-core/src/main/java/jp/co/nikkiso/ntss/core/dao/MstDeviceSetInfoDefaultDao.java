package jp.co.nikkiso.ntss.core.dao;

import java.sql.Timestamp;
import java.util.List;

import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.Update;
import org.seasar.doma.boot.ConfigAutowireable;
import org.seasar.doma.BatchInsert;

import jp.co.nikkiso.ntss.core.entity.DeviceSetInfo;

@ConfigAutowireable
@Dao
public interface MstDeviceSetInfoDefaultDao {
  @Select
  String selectDeviceSetInfo(String facility_cd);

  // add #11166 予定が新規登録すると、device_set_infoの中で1001と1002のkeyが必要がない、取得SQLを新規する zkm start
  @Select
  String selectDeviceSetInfoWithoutTmpZero(String facility_cd);
  // add #11166 予定が新規登録すると、device_set_infoの中で1001と1002のkeyが必要がない、取得SQLを新規する zkm end

  @Update(sqlFile = true)
  int updateDeviceSetInfo(String facility_cd, String deviceSetInfo);

  @Select
  List<DeviceSetInfo> selectDeviceInfo(String facility_cd, String first_key, String second_key);

  @Select
  String selectHostNoticeByFacilityCd(String facility_cd);

  @Select
  List<DeviceSetInfo> selectTareAndOffWater(String facility_cd);


  /**
   * ホスト報知デフォルト設定を取得
   * @param facilityCd 施設コード
   * @return
   */
  @Select
  String selectHostNotificationInfo(String facilityCd);

  @Update(sqlFile = true)
  int updateDeviceInfo(String facilityCd, String deviceInfo);

  @Update(sqlFile = true)
  int updateTareAndOffWater(String facilityCd, String tareInfo, String offWaterInfo);

  @Update(sqlFile = true)
  int updateSysHostNotificationInfo(String facilityCd, String hostNotificationInfo, Timestamp upDate);

  @Update(sqlFile = true)
  int updateSysTareOffWaterInfo(String facilityCd, String tareInfo, String offWaterInfo, Timestamp upDate);

  /**
  * 対象施設の装置設定デフォルトマスタ情報を登録
  * @param facilityCdList 施設コード
  * @return 更新件数
  */
  @BatchInsert(sqlFile = true)
  int[] insertInitMstForFacility(List<String> facilityCdList);

  @Update(sqlFile = true)
  int deleteReplenisherFiltration(String facilityCd);

  @Update(sqlFile = true)
  int insertReplenisherFiltration(String facilityCd);


  @Update(sqlFile = true)
  int updateReplenisherFiltrationCode(String facilityCd);
}

