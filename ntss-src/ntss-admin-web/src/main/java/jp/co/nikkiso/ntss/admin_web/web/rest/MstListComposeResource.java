package jp.co.nikkiso.ntss.admin_web.web.rest;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant;
import jp.co.nikkiso.ntss.admin_web.service.MstListCompose.MstListComposeService;
import jp.co.nikkiso.ntss.core.dto.MstListCompose.request.MstListComposeRequest;
import jp.co.nikkiso.ntss.core.dto.MstListCompose.response.MstListComposeResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping(AdminWebConstant.Uri.MASTER_MAINTENANCE)
public class MstListComposeResource {

  @Autowired
  MstListComposeService mstListComposeService;

  @PostMapping("/mst-list-compose")
  public MstListComposeResponse selectMstListCompose(
    @RequestBody MstListComposeRequest request) {
    return mstListComposeService.selectMstListCompose(request);
  }
}
