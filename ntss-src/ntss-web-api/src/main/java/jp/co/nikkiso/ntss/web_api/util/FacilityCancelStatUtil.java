package jp.co.nikkiso.ntss.web_api.util;

import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.STAT_KEY_AMOUNT;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.STAT_KEY_DB_NAME;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.STAT_KEY_DELETED;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.STAT_KEY_END;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.STAT_KEY_START;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.STAT_KEY_TABLE_NAME;

import java.util.List;
import java.util.Map;

/**
 * 統計情報操作のためのユーティリティクラス。
 */
public class FacilityCancelStatUtil {

  /**
   * 統計情報を更新する。（mst_user_authentication、mst_facility_hash用）
   *
   * @param stat 統計情報
   * @param count 削除件数
   * @param start 開始日時
   * @param end 終了日時
   */
  public static void updateStat(Map<String, Object> stat, Integer count, String start, String end) {
    if (stat == null) {
      return;
    }

    stat.put(STAT_KEY_START, start);
    stat.put(STAT_KEY_END, end);
    stat.put(STAT_KEY_AMOUNT, count);
    stat.put(STAT_KEY_DELETED, count);
  }

  /**
   * 統計情報のリストから統計情報1件を取得する。
   *
   * @param statList 統計情報のリスト
   * @param dbName データベース名（db4, db5, db6）
   * @param tableName テーブル名
   * @return 統計情報
   */
  public static Map<String, Object> findStat(List<Map<String, Object>> statList, String dbName, String tableName) {
    return statList.stream()
        .filter(
            s -> ((String) s.get(STAT_KEY_DB_NAME)).endsWith(dbName) &&
                tableName.equals(s.get(STAT_KEY_TABLE_NAME)))
        .findFirst().orElse(null);
  }
}
