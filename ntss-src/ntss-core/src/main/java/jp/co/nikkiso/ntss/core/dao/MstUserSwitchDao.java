package jp.co.nikkiso.ntss.core.dao;


import jp.co.nikkiso.ntss.core.config.ConfigAutowireableAuthDb;
import jp.co.nikkiso.ntss.core.entity.MstUserSwitch;
import org.seasar.doma.*;

import java.util.List;

/**
 * 切换施舍
 */
@Dao
@ConfigAutowireableAuthDb
public interface MstUserSwitchDao {

  @Select()
  String selectGroupIdByUserId(long userId);

  @Delete(sqlFile = true)
  int deleteGroupIdByRefId(String groupId);

  @Select()
  List<Long> selectSwitchIdsByGroupId(String groupId);

  @Delete(sqlFile = true)
  int batchDeleteBySwitchId(List<Long> switchIdList);

  @Update(sqlFile = true)
  int batchUpdate(List<MstUserSwitch> entityList,long updateUserId);

  @Select()
  List<String> selectGroupIdListByUserIds(List<Long> list);

  @Insert(sqlFile = true)
  int batchInsertSwitchMapping(List<MstUserSwitch> entityList);

  @Insert(sqlFile = true)
  int insertUserSwitch(MstUserSwitch entity);

  @Update(sqlFile = true)
  int batchRefreshGroupId(List<String> groupIdList, String groupId,long updateUserId);
  @Select()
  Long selectSwitchIdByUserId(Long userId);

  @Select()
  List<MstUserSwitch> selectSwitchListByUserId(Long userId);

  @Update(sqlFile = true)
  int updateStatusByUserId(String status, long userId,long updateUserId);

  @Delete(sqlFile = true)
  int deleteSwitchByUserId(long userId);
}
