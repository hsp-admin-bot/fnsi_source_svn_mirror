package jp.co.nikkiso.ntss.core.dao;

import java.util.List;

import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.Insert;
import org.seasar.doma.Update;
import org.seasar.doma.boot.ConfigAutowireable;

import jp.co.nikkiso.ntss.core.entity.MntIfEdgeHealthmon;
// add FNSI-連携情報を追加 李 start
import jp.co.nikkiso.ntss.core.entity.ConIntelligenceListmon;
// add FNSI-連携情報を追加 李 end

/**
 * 連携エッジヘルスモニタDao
 *
 */
@ConfigAutowireable
@Dao
public interface MntIfEdgeHealthmonDao {
  @Select
  List<MntIfEdgeHealthmon> selectByFacilityCd(String facilityCd);

  // add FNSI-連携情報を追加 李 start
  @Select
// mod 2023-01-04 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//  List<ConIntelligenceListmon> selectConIntelligenceListByFacilityCd(String facilityCd, String selectedPatId);
  List<ConIntelligenceListmon> selectConIntelligenceListByFacilityCd(String facilityCd, String coopVersion,
                                                                     String selectedPatId);
// mod 2023-01-04 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
  // add FNSI-連携情報を追加 李 end

  /**
   * 対象IFエッジのヘルスモニタ情報を取得します
   * @param facilityCd - 施設コード
   * @param coopVersion - 連携版番号
   * @param ifEdgeNo - IFエッジ番号
   * @return {@link MntIfEdgeHealthmon}
   */
  @Select
  /* modify by chamaojia 2024-10-11 [11140] 【mnt_if_edge_healthmon】 coop_version delete --start */
// mod 2023-01-04 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
  MntIfEdgeHealthmon selectByFacilityAndIfEdgeNo(String facilityCd, Integer ifEdgeNo);
//  List<MntIfEdgeHealthmon> selectByFacilityAndIfEdgeNo(String facilityCd, String coopVersion, Integer ifEdgeNo);
// mod 2023-01-04 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
  /* modify by chamaojia 2024-10-11 [11140] 【mnt_if_edge_healthmon】 coop_version delete --end */

  /**
   * 対象IFエッジのヘルスモニタを登録します
   * @param mntIfEdgeHealthmon 対象IFエッジのヘルスモニタエンティティ
   * @return 登録件数
   */
  @Insert(sqlFile = true)
  int insert(MntIfEdgeHealthmon mntIfEdgeHealthmon);

  /**
   * 対象IFエッジのヘルスモニタ情報を更新します
   * @param healthmon - {@link MntIfEdgeHealthmon}
   * @return 更新件数
   */
  @Update(sqlFile = true)
  int updateServerAndFacilityConn(MntIfEdgeHealthmon healthmon);

  /* modify by chamaojia 2024-10-11 [11140] change to a single query --start */
  /* add by chamaojia 2024-09-26 [10574] change to batch modification and return the dataset --start */
  /**
   * 対象IFエッジのヘルスモニタ情報を更新します
   * @param healthmonServerConn     サーバステータス
   * @param healthmonFacilityConn   エッジステータス
   * @param ctlNo               管理番号
   * @return {@link MntIfEdgeHealthmon}
   */
  @Select
  MntIfEdgeHealthmon updateServerAndFacilityConnByCtlNo(String healthmonServerConn, String healthmonFacilityConn
          , Long ctlNo);
  /* add by chamaojia 2024-09-26 [10574] change to batch modification and return the dataset --end */
  /* modify by chamaojia 2024-10-11 [11140] change to a single query --end */

  //#9490  add 電子カルテアイコンの連携先情報について 2024-07-19 卓 start
  /**
   * 対象IFエッジのヘルスモニタ情報を更新します
   * @param healthmon - {@link MntIfEdgeHealthmon}
   * @return 更新件数
   */
  @Update(sqlFile = true)
  int updateHealthmonFacilityConn(MntIfEdgeHealthmon healthmon);
  //#9490  add 電子カルテアイコンの連携先情報について 2024-07-19 卓 end

  /* add by chamaojia 2024-10-11 [11140] add and delete node interface --start */
  @Update(sqlFile = true)
  int delHealthmonFacilityConnItemToCoopCd(Long ctlNo, List<String> delHFCItemList);
  /* add by chamaojia 2024-10-11 [11140] add and delete node interface --end */
}
