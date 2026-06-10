package jp.co.nikkiso.ntss.core.dao;

import java.util.List;

import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.Update;
import org.seasar.doma.Insert;
import org.seasar.doma.Delete;
import org.seasar.doma.boot.ConfigAutowireable;

import jp.co.nikkiso.ntss.core.entity.MstCoopApilink;

/**
 * 連携API関連付けマスタのDaoインタフェース.
 */
@ConfigAutowireable
@Dao
public interface MstCoopApilinkDao {

  /**
   * 指定のジャーナルAPIに対応した連携API関連付けデータを取得する。
   *
   * @param mstCoopApilink 連携API関連付けマスタエンティティ
   * @return 連携API関連付けマスタエンティティ
   */
  @Select
  List<MstCoopApilink> selectRelation(MstCoopApilink mstCoopApilink);

  /**
   * 施設コードによる連携API関連付けデータを取得する。
   *
   * @param facilityCd 施設コード
   * @return 連携API関連付けマスタエンティティ
   */
  @Select
  List<MstCoopApilink> selectByFacility(String facilityCd);

  /**
   * 管理番号よる連携API関連付けデータを取得する。
   *
   * @param ctlNo 管理番号
   * @return 連携API関連付けマスタエンティティ
   */
  @Select
  MstCoopApilink selectByCtlNo(Long ctlNo);

  /**
   * 施設コードによる連携API関連付けデータを更新する
   * 
   * @param mca 連携API関連付けマスタエンティティ
   * @return 0または1
   */
  @Update(sqlFile = true)
  int update(MstCoopApilink mca);

  /**
   * 施設コードによる連携API関連付けデータを登録する
   * 
   * @param mca 連携API関連付けマスタエンティティ
   * @return 0または1
   */
  @Insert(sqlFile = true)
  int insert(MstCoopApilink mca);

  /**
   * 施設コードで連携API関連付けデータを削除
   * @param facilityCd 施設コード
   * @return
   */
  @Delete(sqlFile = true)
  int deleteByFacilityCd(String facilityCd);
}
