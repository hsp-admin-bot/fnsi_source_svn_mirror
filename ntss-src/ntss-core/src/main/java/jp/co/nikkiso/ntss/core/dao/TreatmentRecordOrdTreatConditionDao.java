package jp.co.nikkiso.ntss.core.dao;

import java.util.List;

import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;

import jp.co.nikkiso.ntss.core.entity.TreatmentRecordSetting;

/**
 * 治療記録用設定値読み込み履歴のDaoインタフェース.
 */
@Dao
@ConfigAutowireable
public interface TreatmentRecordOrdTreatConditionDao {

  /**
   * オーダ番号に紐づく設定値読み込み履歴を取得.
   * @param ordNo オーダ番号
   * @return 設定値読み込み履歴のリスト
   */
  @Select
  List<TreatmentRecordSetting> selectTreatmentRecordSettingsByOrdNo(Long ordNo);
}
