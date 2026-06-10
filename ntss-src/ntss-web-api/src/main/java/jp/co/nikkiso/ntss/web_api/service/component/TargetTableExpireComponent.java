package jp.co.nikkiso.ntss.web_api.service.component;

import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.STAT_KEY_DB_CLASS;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.STAT_KEY_TABLE_NAME;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.STAT_KEY_TIME_COLUMN_NAME;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import jp.co.nikkiso.ntss.core.entity.MntFacilityCancelStat;
import jp.co.nikkiso.ntss.web_api.config.FacilityCancelConfig;

/**
 * 期間外削除対象テーブルを取得するコンポーネント。
 */
@Component
public class TargetTableExpireComponent implements TargetTableComponent {

  @Autowired
  private FacilityCancelConfig config;

  /**
   * 期間外削除対象テーブルを取得する。
   * @param facilityCd 施設コード
   * @return 期間外削除対象（データベース名、テーブル名）のリスト
   */
  @Override
  public List<MntFacilityCancelStat> getTargetTableList(String facilityCd) {
    // 期間外削除対象テーブルを取得
    // sys_system_defineの管理番号:31で管理
    List<Map<String, Object>> targetList = config.getTargetTableExpire();

    List<MntFacilityCancelStat> list = new ArrayList<>();
    targetList.forEach(r -> {
      // 期間外対象テーブルの設定を追加
      list.add(new MntFacilityCancelStat(
          config.getDbName((Integer) r.get(STAT_KEY_DB_CLASS))
          , (Integer) r.get(STAT_KEY_DB_CLASS)
          , (String) r.get(STAT_KEY_TABLE_NAME)
          , null
          , (String) r.get(STAT_KEY_TIME_COLUMN_NAME)));
    });

    return list;
  }

  /**
   * 期間外削除対象テーブルを取得する。
   * @param facilityCd 施設コード
   * @return 期間外削除対象（データベース名、テーブル名）のリスト
   */
  @Override
  public List<MntFacilityCancelStat> getTargetTableList(String facilityCd, String procClass) {
    // 期間外削除対象テーブルを取得
    // sys_system_defineの管理番号:31で管理
    List<Map<String, Object>> targetList = config.getTargetTableExpire();

    List<MntFacilityCancelStat> list = new ArrayList<>();
    targetList.forEach(r -> {
      // 期間外対象テーブルの設定を追加
      list.add(new MntFacilityCancelStat(
          config.getDbName((Integer) r.get(STAT_KEY_DB_CLASS))
          , (Integer) r.get(STAT_KEY_DB_CLASS)
          , (String) r.get(STAT_KEY_TABLE_NAME)
          , null
          , (String) r.get(STAT_KEY_TIME_COLUMN_NAME)));
    });

    return list;
  }
}
