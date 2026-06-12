package jp.co.nikkiso.ntss.admin_web.service.MstCodeListBatch;

import jp.co.nikkiso.ntss.core.dao.UnifiedByCodeListDao;
import jp.co.nikkiso.ntss.core.dto.MstCodeListBatch.request.MstCodeListBatchRequest;
import jp.co.nikkiso.ntss.core.dto.MstCodeListBatch.request.MstCodeListQuery;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationContext;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@Service
public class MstCodeListBatchServiceImpl implements MstCodeListBatchService {

  @Autowired
  private ApplicationContext applicationContext;

  @Override
  public Map<String, List<Map<String, Object>>> selectAllStatusByCodeListBatch(MstCodeListBatchRequest request) {
    if (request == null || request.getQueries() == null || request.getQueries().isEmpty()) {
      return Collections.emptyMap();
    }

    Map<String, List<Map<String, Object>>> result = new LinkedHashMap<>();

    for (MstCodeListQuery q : request.getQueries()) {
      if (q == null || q.getMstCode() == null || q.getMstCode().isBlank()) {
        continue;
      }
      String mstCode = q.getMstCode();

      List<Integer> codeList = toIntList(q.getCodeList());
      if (codeList.isEmpty()) {
        result.put(mstCode, Collections.emptyList());
        continue;
      }

      try {
        UnifiedByCodeListDao dao = applicationContext.getBean(mstCode, UnifiedByCodeListDao.class);
        if (dao == null) {
          result.put(mstCode, Collections.emptyList());
          continue;
        }
        result.put(mstCode, dao.selectAllStatusByCodeList(codeList));
      } catch (Exception ex) {
        result.put(mstCode, Collections.emptyList());
      }
    }

    return result;
  }

  private List<Integer> toIntList(List<String> raw) {
    if (raw == null || raw.isEmpty()) return Collections.emptyList();
    List<Integer> out = new ArrayList<>(raw.size());
    for (String s : raw) {
      if (s == null) continue;
      String t = s.trim();
      if (t.isEmpty()) continue;
      try {
        out.add(Integer.parseInt(t));
      } catch (NumberFormatException ignore) {
        // numeric-only contract: skip invalid entries
      }
    }
    return out;
  }
}

