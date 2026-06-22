package jp.co.nikkiso.ntss.core.dao;

import org.seasar.doma.Dao;
import org.seasar.doma.Update;
import org.seasar.doma.boot.ConfigAutowireable;

import jp.co.nikkiso.ntss.core.entity.custom.ComsvOrdWeightScale;

/**
 * 通信サーバ用体重計測定実績のDaoインタフェース.
 */
@ConfigAutowireable
@Dao
public interface ComsvOrdWeightScaleDao {

  /**
   * 体重計測定実績（ステータス、メッセージ）を更新
   * @param weightScaleNo 測定管理番号
   * @param weightScaleStatus 体重測定状況
   * @param message メッセージ
   * @return
   */
  @Update(sqlFile = true)
  int updateStatus(ComsvOrdWeightScale param);

}