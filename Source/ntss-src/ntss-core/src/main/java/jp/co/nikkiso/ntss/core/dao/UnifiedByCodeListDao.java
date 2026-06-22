package jp.co.nikkiso.ntss.core.dao;

import java.util.List;
import java.util.Map;

public interface UnifiedByCodeListDao {
  default List<Map<String, Object>> selectAllStatusByCodeList(List<Integer> codeList) {
    throw new UnsupportedOperationException();
  }
}

