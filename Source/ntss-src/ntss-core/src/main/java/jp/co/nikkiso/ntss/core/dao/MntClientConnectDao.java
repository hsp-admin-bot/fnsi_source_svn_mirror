package jp.co.nikkiso.ntss.core.dao;

import java.util.List;

import org.seasar.doma.Dao;
import org.seasar.doma.Delete;
import org.seasar.doma.Insert;
import org.seasar.doma.Select;
import org.seasar.doma.Update;
import org.seasar.doma.boot.ConfigAutowireable;

import jp.co.nikkiso.ntss.core.entity.MntClientConnect;

/**
 * WebSocketクライアント接続状態のDaoインタフェース
 */
@ConfigAutowireable
@Dao
public interface MntClientConnectDao {
  @Select
  List<MntClientConnect> selectByIpFacility(String ipAddress, String facilityCd);

  @Select
  List<MntClientConnect> selectByIp(String ipAddress);

  @Select
  List<MntClientConnect> selectByFacility(String facilityCd);

  @Select
  List<MntClientConnect> selectByFacilityList(List<String> facilityCdList, Integer serverType);

  @Select
  List<MntClientConnect> selectByServerType(String facilityCd, Integer serverType);

  @Insert(sqlFile = true)
  int insert(MntClientConnect mntClientConnect);

  @Update(sqlFile = true)
  int update(MntClientConnect mntClientConnect);

  @Delete(sqlFile = true)
  int delete(MntClientConnect mntClientConnect);
}
