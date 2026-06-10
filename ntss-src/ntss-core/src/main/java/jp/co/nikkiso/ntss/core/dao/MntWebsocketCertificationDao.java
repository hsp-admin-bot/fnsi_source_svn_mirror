package jp.co.nikkiso.ntss.core.dao;

import java.util.List;

import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.Delete;
import org.seasar.doma.Insert;

import jp.co.nikkiso.ntss.core.config.ConfigAutowireableAuthDb;
import jp.co.nikkiso.ntss.core.entity.MntWebsocketCertification;

/**
 * WebSocket認証コードのDaoインタフェース
 */
@ConfigAutowireableAuthDb
@Dao
public interface MntWebsocketCertificationDao {

  @Select
  List<MntWebsocketCertification> selectByCertification(String certificationCd);

  @Select
  int selectCountByRegDate(MntWebsocketCertification mntWebsocketCertification);

  @Insert(sqlFile = true)
  int insert(MntWebsocketCertification mntWebsocketCertification);

  @Delete(sqlFile = true)
  int delete(MntWebsocketCertification mntWebsocketCertification);

  @Delete(sqlFile = true)
  int deleteRegDate(MntWebsocketCertification mntWebsocketCertification);
}
