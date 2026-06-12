package jp.co.nikkiso.ntss.core.dao;

import java.util.Collections;
import java.util.List;
import java.util.Map;

public interface MasterDao<T> {
  default List<Map<String, Object>> selectAllStatus(Map<String, String> params) {
    throw new UnsupportedOperationException();
  }

  /**
   * mst-list-compose 用の単一入口。既定は {@link #selectAllStatus}。
   * 施設など、sqlParams により SQL を切り替える Dao は本メソッドを override する。
   */
  default List<Map<String, Object>> selectAllStatusForCompose(Map<String, String> params) {
    return selectAllStatus(params == null ? Collections.emptyMap() : params);
  }
}
