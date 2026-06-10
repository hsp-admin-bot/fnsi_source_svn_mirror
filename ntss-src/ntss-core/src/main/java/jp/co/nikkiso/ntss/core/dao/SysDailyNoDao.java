package jp.co.nikkiso.ntss.core.dao;

import org.seasar.doma.Dao;
import org.seasar.doma.Insert;
import org.seasar.doma.Select;
import org.seasar.doma.Update;
import org.seasar.doma.boot.ConfigAutowireable;

import jp.co.nikkiso.ntss.core.entity.SysDailyNo;

import java.sql.Timestamp;

/**
 * 受付番号採番情報のDaoインタフェース.
 */
@ConfigAutowireable
@Dao
public interface SysDailyNoDao {

  /**
   * 施設コード、採番種別を条件に受付番号採番情報を取得.
   * @param facilityCd 施設コード
   * @param numberingCd 採番種別
   * @return 受付番号採番情報エンティティ
   */
  @Select
  SysDailyNo selectDateList(String facilityCd, String numberingCd);

  /**
   * 受付番号採番情報登録
   * @param sysDailyNo 受付番号採番情報エンティティ
   * @return 登録件数
   */
  @Insert(sqlFile = true)
  int insert(SysDailyNo sysDailyNo);

  /**
   * 受付番号採番情報更新
   * @param sysDailyNo 受付番号採番情報エンティティ
   * @param checkUpDate チェック更新日時
   * @return 更新件数
   */
  @Update(sqlFile = true)
  // mod 2021-04-12 redmine #3961:accept_noの付番が正しくない 孫 start
//  int updateByCtlNo(SysDailyNo sysDailyNo);
  int updateByCtlNo(SysDailyNo sysDailyNo, Timestamp checkUpDate);
  // mod 2021-04-12 redmine #3961:accept_noの付番が正しくない 孫 end
}
