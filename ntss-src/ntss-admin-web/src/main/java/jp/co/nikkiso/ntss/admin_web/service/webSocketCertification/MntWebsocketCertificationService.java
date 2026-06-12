package jp.co.nikkiso.ntss.admin_web.service.webSocketCertification;

import java.util.List;
import java.time.Clock;
import java.util.Map;

import jp.co.nikkiso.ntss.admin_web.request.webSocketCertification.WSCertificationDTO;
import jp.co.nikkiso.ntss.core.entity.MntWebsocketCertification;
import org.springframework.http.ResponseEntity;

import jakarta.servlet.http.HttpServletRequest;

/**
 * WebSocket認証コードサービス
 */
public interface MntWebsocketCertificationService {

  List<MntWebsocketCertification> findByCertification(String certificationCd);

  int insert(String certificationCd, String facilityCd);

  int delete(String certificationCd);

  int deleteAfterMinute(int addMinute);

  Clock getTime();

  /* add by renxiaohao  2023-2-01 CodeOptimization  start */
  ResponseEntity<String> getStringResponseEntity(HttpServletRequest request, WSCertificationDTO WSCertification);
  /* add by renxiaohao  2023-2-01 CodeOptimization  end */

  /* add by renxiaohao  2023-2-01 CodeOptimization  start */
  String getUrlString(HttpServletRequest request, String facilityCd);
  /* add by renxiaohao  2023-2-01 CodeOptimization  end */

  /* add by renxiaohao  2023-2-01 CodeOptimization  start */
  boolean isResponseRet(HttpServletRequest request, Map<String, Object> req);
  /* add by renxiaohao  2023-2-01 CodeOptimization  end */
}
