package jp.co.nikkiso.ntss.core.dao;

import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.Update;
import org.seasar.doma.boot.ConfigAutowireable;

import jp.co.nikkiso.ntss.core.entity.custom.ComsvPatRelated;

/**
 * 通信サーバ用患者情報関連のDaoインタフェース.
 */
@ConfigAutowireable
@Dao
public interface ComsvPatRelatedDao {

  /**
   * 治療情報を抽出
   *
   * @param ordNo オーダ番号
   * @return 通信サーバ用治療情報Entity
   */
  @Select
  ComsvPatRelated selectDialCount(Long patId);

  /**
   * 患者基本情報（治療進捗状態）を更新
   * @param patId システムで管理する一意な患者ID
   * @param acceptanceStatusInfo 治療進捗状態
   * @return
   */
  @Update(sqlFile = true)
  int updateDialStatus(ComsvPatRelated param);

  /**
   * 患者基本情報（共通診療情報：透析回数）を更新
   * @param patId システムで管理する一意な患者ID
   * @return
   */
  @Update(sqlFile = true)
  int updateDialCount(ComsvPatRelated param);

}