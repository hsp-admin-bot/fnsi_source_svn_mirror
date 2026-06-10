package jp.co.nikkiso.ntss.core.dao;

import java.util.List;

import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;

import jp.co.nikkiso.ntss.core.entity.custom.LargeDispMonitorData;
import jp.co.nikkiso.ntss.core.entity.custom.LargeDispPatList;

/**
 * 通信サーバ用治療情報のDaoインタフェース.
 */
@ConfigAutowireable
@Dao
public interface LargeDispListDao {

  /**
   * 透析前患者(条件送信～運転開始)リスト取得
   *
   * @param facilityCd 施設番号
   * @param treatDate 透析日
   * @param treatState 治療状況
   * @return
   */
  @Select
  List<LargeDispPatList> selectTreatPatList(String facilityCd);

  @Select
  // mod #6264 2022-08-04 治療状況リスト・マップの表示項目の参照先がmni_monitor→mnt_machine_state.monitor_dataに変更されていない。 dou start
//  List<LargeDispMonitorData> selectMonitorDataForEntry(List<Long> ordNoList);
  List<LargeDispMonitorData> selectMonitorDataForEntry(List<Long> ordNoList, String facilityCd);
  // mod #6264 2022-08-04 治療状況リスト・マップの表示項目の参照先がmni_monitor→mnt_machine_state.monitor_dataに変更されていない。 dou end
}
