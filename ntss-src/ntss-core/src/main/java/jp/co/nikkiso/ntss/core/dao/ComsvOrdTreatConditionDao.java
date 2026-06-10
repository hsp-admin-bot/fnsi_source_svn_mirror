package jp.co.nikkiso.ntss.core.dao;

import java.util.List;

import org.seasar.doma.Dao;
import org.seasar.doma.Insert;
import org.seasar.doma.Select;
import org.seasar.doma.Update;
import org.seasar.doma.boot.ConfigAutowireable;

//import jp.co.nikkiso.ntss.core.entity.custom.ComsvOrdMain;
import jp.co.nikkiso.ntss.core.entity.custom.ComsvOrdTreatCondition;

/**
 * 通信サーバ用設定値読み込み履歴のDaoインタフェース.
 */
@ConfigAutowireable
@Dao
public interface ComsvOrdTreatConditionDao {

  /**
   * 設定値読み込み履歴を抽出
   * @param ordNo オーダー番号
   * @param facilityCd 施設コード
   * @param machineNo 装置番号
   * @return 通信サーバ用設定値読み込み履歴Entity
   */
  @Select
  List<ComsvOrdTreatCondition> selectCondition(ComsvOrdTreatCondition param);

  /**
   * 設定値読み込み履歴を削除
   * @param ordNo オーダー番号
   * @param facilityCd 施設コード
   * @param machineNo 装置番号
   * @return
   */
  @Update(sqlFile = true)
  int deleteCondition(ComsvOrdTreatCondition param);

  /**
   * 設定値読み込み履歴を追加
   * @param ordNo オーダー番号
   * @param facilityCd 施設コード
   * @param machineNo 装置番号
   * @param receveDate 条件取得日時
   * @param treatCondition 治療条件
   * @return
   */
  @Insert(sqlFile = true)
  int insertCondition(ComsvOrdTreatCondition param);

}