package jp.co.nikkiso.ntss.admin_web.service.MstCodeListBatch;

import jp.co.nikkiso.ntss.core.dto.MstCodeListBatch.request.MstCodeListBatchRequest;

import java.util.List;
import java.util.Map;

public interface MstCodeListBatchService {
  Map<String, List<Map<String, Object>>> selectAllStatusByCodeListBatch(MstCodeListBatchRequest request);
}

