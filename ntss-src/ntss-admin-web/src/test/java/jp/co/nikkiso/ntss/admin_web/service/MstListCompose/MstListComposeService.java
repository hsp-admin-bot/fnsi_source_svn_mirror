package jp.co.nikkiso.ntss.admin_web.service.MstListCompose;

import jp.co.nikkiso.ntss.core.dto.MstListCompose.request.MstListComposeRequest;
import jp.co.nikkiso.ntss.core.dto.MstListCompose.response.MstListComposeResponse;

public interface MstListComposeService {
  MstListComposeResponse selectMstListCompose(MstListComposeRequest request);
}
