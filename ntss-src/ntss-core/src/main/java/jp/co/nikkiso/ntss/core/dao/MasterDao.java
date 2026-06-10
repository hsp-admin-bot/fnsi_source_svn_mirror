package jp.co.nikkiso.ntss.core.dao;

import java.util.List;
import java.util.Map;

public interface MasterDao<T> {
  default List<Map<String, Object>> selectAllStatus(Map<String, String> params) {
    throw new UnsupportedOperationException();
  }
}
