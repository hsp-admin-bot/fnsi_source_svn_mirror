package jp.co.nikkiso.ntss.core.dao;

import java.util.List;
import org.seasar.doma.Dao;
import org.seasar.doma.Insert;
import org.seasar.doma.Select;
import org.seasar.doma.Update;
import org.seasar.doma.boot.ConfigAutowireable;

import jp.co.nikkiso.ntss.core.entity.MntIfEdgeManage;

/**
 * 連携エッジ制御指示管理のDaoインタフェース.
 */
@ConfigAutowireable
@Dao
public interface MntIfEdgeManageDao {

  /**
   * 施設コード、応答ステータスを条件に連携エッジ制御指示管理を取得.
   * @param facilityCd 施設コード
   * @return 連携エッジ制御指示管理エンティティ
   */
  @Select
  MntIfEdgeManage selectByFacilityCdAndStatus(String facilityCd, Integer responseStatus);

  /**
   * 管理NOを条件に連携エッジ制御指示管理を取得.
   * @param ctlNo 管理NO
   * @return 連携エッジ制御指示管理エンティティ
   */
  @Select
  MntIfEdgeManage selectByCtlNo(Long ctlNo);

  /**
   * 連携エッジ制御指示管理登録
   * @param mntIfEdgeManage 連携エッジ制御指示管理エンティティ
   * @return 管理No
   */
  @Insert(sqlFile = true)
  int insert(MntIfEdgeManage mntIfEdgeManage);

  /**
   * 連携エッジ制御指示管理更新
   * @param mntIfEdgeManage 連携エッジ制御指示管理エンティティ
   * @return 更新件数
   */
  @Update(sqlFile = true)
  int update(MntIfEdgeManage mntIfEdgeManage);

  /**
   * 施設コード、応答ステータスを条件に連携エッジ制御指示管理の状態を更新
   * @param facilityCdList 施設コードリスト
   * @param currentResponseStatus 現在の状態
   * @param responseStatus 更新する状態
   * @return 更新件数
   */
  @Update(sqlFile = true)
  int updateStatusByFacilityCdsAndStatus(List<String> facilityCdList, Integer currentResponseStatus, Integer responseStatus);
}
