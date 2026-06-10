package jp.co.nikkiso.ntss.core.dao;

import org.seasar.doma.Dao;
import org.seasar.doma.Delete;
import org.seasar.doma.Insert;
import org.seasar.doma.Select;
import org.seasar.doma.Update;
import org.seasar.doma.boot.ConfigAutowireable;

import jp.co.nikkiso.ntss.core.entity.MntIfEdgeClientConnect;

import java.util.List;

/**
 * 連携エッジクライアント接続状態のDaoインタフェース.
 */
@ConfigAutowireable
@Dao
public interface MntIfEdgeClientConnectDao {

  /**
   * 施設コードを条件に連携エッジクライアント接続状態を取得.
   * @param facilityCd 施設コード
   * @return 連携エッジクライアント接続状態エンティティ
   */
  @Select
  MntIfEdgeClientConnect selectByFacilityCd(String facilityCd);
  /**
   * 施設コードを条件に連携エッジクライアント接続状態を取得.
   * @param facilityCd 施設コード
   * @return 連携エッジクライアント接続状態エンティティ
   */
  @Select
  List<MntIfEdgeClientConnect> selectListByIpAddress(String facilityCd,String ip_address);

  @Select
  List<MntIfEdgeClientConnect> selectListByIfEdgeType(String facilityCd,Integer ifEdgeType);
  /**
   * 連携エッジクライアント接続状態登録
   * @param mntIfEdgeClientConnect 連携エッジクライアント接続状態エンティティ
   * @return 登録件数
   */
  @Insert(sqlFile = true)
  int insert(MntIfEdgeClientConnect mntIfEdgeClientConnect);

  /**
   * 連携エッジクライアント接続状態更新
   * @param mntIfEdgeClientConnect 連携エッジクライアント接続状態エンティティ
   * @return 更新件数
   */
  @Update(sqlFile = true)
  int update(MntIfEdgeClientConnect mntIfEdgeClientConnect);

  /**
   * 連携エッジクライアント接続状態削除
   * @param mntIfEdgeClientConnect 連携エッジクライアント接続状態エンティティ
   * @return 登録件数
   */
  @Delete
  int delete(MntIfEdgeClientConnect mntIfEdgeClientConnect);

  @Delete(sqlFile = true)
  int deleteByIfEdgeType(String facilityCd,Integer ifEdgeType);
}
