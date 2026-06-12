package jp.co.nikkiso.ntss.admin_web.web.rest;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant;
import jp.co.nikkiso.ntss.admin_web.service.MstCodeListBatch.MstCodeListBatchService;
import jp.co.nikkiso.ntss.core.dto.MstCodeListBatch.request.MstCodeListBatchRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping(AdminWebConstant.Uri.MASTER_MAINTENANCE)
public class MstCodeListBatchResource {

  @Autowired
  private MstCodeListBatchService mstCodeListBatchService;

  @PostMapping("/mst-code-list-batch")
  public Map<String, List<Map<String, Object>>> selectAllStatusByCodeListBatch(
    @RequestBody MstCodeListBatchRequest request
  ) {
    return mstCodeListBatchService.selectAllStatusByCodeListBatch(request);
  }
}

