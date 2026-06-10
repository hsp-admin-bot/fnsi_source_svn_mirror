package jp.co.nikkiso.ntss.core.dao;

import org.seasar.doma.Dao;
import org.seasar.doma.Delete;
import org.seasar.doma.Insert;
import org.seasar.doma.Select;

import jp.co.nikkiso.ntss.core.config.ConfigAutowireableAuthDb;
import jp.co.nikkiso.ntss.core.entity.MstFacility;
import jp.co.nikkiso.ntss.core.entity.MstPatHash;

/**
 * 施設マスタハッシュのDaoインタフェース.
 */
@ConfigAutowireableAuthDb
@Dao
public interface MstPatHashDao {

  /**
   * ハッシュ値に紐付くレコードを取得.
   * @param hashValue ハッシュ値
   * @return 施設コードハッシュ情報
   */
  @Select
  MstPatHash selectByHashValue(String hashValue);

  /**
   * 施設コードに紐付くレコードを取得.
   * @param facilityCd 施設コード
   * @return 施設コードハッシュ情報
   */
  @Select
  MstPatHash selectByFacilityCd(String facilityCd);

  @Insert(sqlFile = true)
  int insert(MstFacility mstFacility);

  @Delete(sqlFile = true)
  int deleteByCd(String facilityCd);
  
}
