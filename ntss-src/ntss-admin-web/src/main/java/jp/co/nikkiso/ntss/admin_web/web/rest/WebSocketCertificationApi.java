package jp.co.nikkiso.ntss.admin_web.web.rest;

import java.net.URISyntaxException;
import java.util.Map;

import jakarta.servlet.http.HttpServletRequest;

import jp.co.nikkiso.ntss.core.dao.MstFacilityDao;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import jp.co.nikkiso.ntss.admin_web.WebSocketNotifyProperties;
import jp.co.nikkiso.ntss.admin_web.constant.AdminWebMessage;
import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Uri;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.dao.MstFacilityHashDao;
import jp.co.nikkiso.ntss.admin_web.request.webSocketCertification.WSCertificationDTO;
import jp.co.nikkiso.ntss.admin_web.response.masterMaintenance.MasterUpdateResponse;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.admin_web.service.webSocketCertification.MntWebsocketCertificationService;
import jp.co.nikkiso.ntss.admin_web.service.webSocketNotify.WebSocketNotifyService;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.utils.InvestigateLogUtils;



@RestController
@RequestMapping(Uri.WEBSOCKET_CERT)
public class WebSocketCertificationApi {

  @Autowired
  private MntWebsocketCertificationService mntWebsocketCertificationService;

  @Autowired
  private WebSocketNotifyProperties webSocketNotifyProperties;

  /**
   * 施設設定Daoインターフェース.
   */
  @Autowired
  private MstFacilityHashDao mstFacilityHashDao;

  /**
   * WebSocket通知Service.
   */
  @Autowired
  private WebSocketNotifyService webSocketNofityService;

  @Autowired
  LogService logService;

  @Autowired
  private MstFacilityDao mstFacilityDao;
  /**
   * 接続先URLの取得
   * @return URL
   */
  @GetMapping("/target_url")
  //Mod VPN_URL対応 解 Start
  //public ResponseEntity<?> getWSConnectTargetUrl() {
  public ResponseEntity<?> getWSConnectTargetUrl(HttpServletRequest request,
      @RequestParam(name = "facilityCd", required = true) String facilityCd,
      @AuthenticationPrincipal NtssUser ntssUser) {
    // #11205 mod 20260421 start
    if (!hasFacilityAccess(ntssUser, facilityCd)) {
      String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + facilityCd + " " + "remoteAddr=" + request.getRemoteAddr() + " ";
      InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
      return new ResponseEntity<>(HttpStatus.FORBIDDEN);
    }
    // #11205 mod 20260421 end
    //return new ResponseEntity<>(webSocketNotifyProperties.getAppConnectUrl(), HttpStatus.OK);

    /* del by renxiaohao  2023-02-01 CodeOptimization  start */
    //    String tmpFacilityCd = "";
    //    String facilityCdRequest = getAdjustedValue(request.getParameter(NtssAuthenticationConstants.Params.FACILITY_CD)).trim();
    //    if (!StringUtils.isEmpty(facilityCdRequest)) {
    //      tmpFacilityCd = facilityCdRequest;
    //    } else {
    //      tmpFacilityCd = facilityCd;
    //    }
    //    String url = webSocketNotifyProperties.getAppConnectUrl();
    //    // vpnを利用する場合
    //    if (getVpnFlg(tmpFacilityCd)) {
    //      url = webSocketNotifyProperties.getVpnAppConnectUrl();
    //    }
    //    // add ログ改善対応 劉 start
    //    StringBuilder sb = new StringBuilder();
    //    sb.append("getWSConnectTargetUrl : /target_url " + request.getRemoteAddr() +
    //      "facilityCd: " + tmpFacilityCd + "url: " + url);
    //    EventLogMessage eventLogMessage = new EventLogMessage();
    //    eventLogMessage.setLogMessage(sb.toString());
    //    logService.log(LogLevel.INFO, eventLogMessage,"",SERVICE_NAME.FNSI, null);
    /* del by renxiaohao  2023-02-01 CodeOptimization  end */

    // add ログ改善対応 劉 end

    return new ResponseEntity<>(mntWebsocketCertificationService.getUrlString(request, facilityCd), HttpStatus.OK);
    // Mod VPN_URL対応 解 End
  }



  @PostMapping("")
  public ResponseEntity<String> getWSCertification (
      HttpServletRequest request,@RequestBody WSCertificationDTO WSCertification,
      @AuthenticationPrincipal NtssUser ntssUser) throws URISyntaxException {
    // #11205 mod 20260421 start
    if (!hasFacilityAccess(ntssUser, WSCertification == null ? null : WSCertification.getFacilityCd())) {
      String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + WSCertification.getFacilityCd() + " " + "remoteAddr=" + request.getRemoteAddr() + " ";
      InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
      return new ResponseEntity<>(HttpStatus.FORBIDDEN);
    }
    // #11205 mod 20260421 end
    /* del by renxiaohao  2023-02-01 CodeOptimization  start */
    // 施設コード取得
    //    String facilityCd = WSCertification.getFacilityCd();
    //
    //    StringBuilder sb = new StringBuilder();
    //    sb.append("API websocketcertification CALLED IP : " + request.getRemoteAddr());
    //    sb.append(", facility_cd : " + facilityCd);
    //    EventLogMessage eventLogMessage = new EventLogMessage();
    //    eventLogMessage.setLogMessage(sb.toString());
    //    logService.log(LogLevel.INFO, eventLogMessage,"", LoggingConstant.SERVICE_NAME.FNSI, null);
    //
    //    // 作成日時が現在日時より2分以前の認証情報を削除する
    //    int cnt = mntWebsocketCertificationService.deleteAfterMinute( -2 );
    //
    //
    //    ResponseEntity<String> ret;
    //    String key = "";
    //
    //    //　UUID(認証キー)が重複した場合の対応
    //    UUID uuid;
    //    String uuid_str = "";
    //    for( int intlop = 0; intlop < 100; intlop++ ) {
    //
    //      //　UUIDキー生成(ハイフン除去)
    //      uuid = UUID.randomUUID();
    //      uuid_str = uuid.toString().replaceAll("-", "");
    //
    //      // UUIDキーの存在チェック
    //      List<MntWebsocketCertification> list = mntWebsocketCertificationService.findByCertification(uuid_str);
    //      if(list.isEmpty()) {
    //        // 該当情報なし
    //
    //        // 認証情報(UUIDと施設コード)を登録
    //        if( 0 < mntWebsocketCertificationService.insert(uuid_str, facilityCd)) {
    //
    //          // 登録成功時
    //          key = uuid_str;
    //
    //          break;
    //        }
    //      }
    //    }
    //
    //
    //    // 結果判定
    //    if(0 < key.length()) {
    //      // 成功
    //      ret = new ResponseEntity<>(key, HttpStatus.OK);
    //    } else {
    //      //　失敗
    //      ret = new ResponseEntity<>("", HttpStatus.BAD_REQUEST);
    //    }
    //
    //    //
    //    sb.setLength(0);
    //    sb.append("API websocketcertification CALLED IP : " + request.getRemoteAddr());
    //    sb.append(", facility_cd : " + facilityCd);
    //    sb.append(", key : " + key);
    //    sb.append(", status : " + ret.getStatusCode());
    //    eventLogMessage.setLogMessage(sb.toString());
    //    logService.log(LogLevel.INFO, eventLogMessage,"", LoggingConstant.SERVICE_NAME.FNSI, null);
    //    return ret;
    /* del by renxiaohao  2023-02-01 CodeOptimization  end */
    return mntWebsocketCertificationService.getStringResponseEntity(request, WSCertification);
  }


  /**
   * クライアント生存確認 (空メッセージを送信し、現在の接続状態を確認)
   * @return connectedFlag
   */
  @GetMapping("/websocket_connect_status")
  public ResponseEntity<?> getWebSocketConnectStatus(
      HttpServletRequest request, @RequestParam Map<String, Object > req) {

    try {
      /* del by renxiaohao  2023-02-01 CodeOptimization  start */
      //      String hashValue = req.get("hashValue").toString();
      //      String localHashValue = req.get("localHashValue").toString();
      //      List<String> hashList = new ArrayList<String>();
      //      hashList.add(hashValue);
      //      if (!StringUtils.isEmpty(localHashValue) && !hashValue.equals(localHashValue) ) {
      //        // 別の施設にアクセスした場合は、その施設と、以前開いていた施設にチェック処理を行う必要がある
      //        hashList.add(localHashValue);
      //      }
      //      List<String> facilityCdList = mstFacilityHashDao.findByHashValueList(hashList);
      //      String terminalUniqueString = req.get("terminalUniqueString").toString();
      //
      //      StringBuilder sb = new StringBuilder();
      //      sb.append("API websocketcertification CALLED IP : " + request.getRemoteAddr());
      //      for (String facilityCd : facilityCdList) {
      //        sb.append(", facility_cd : " + facilityCd);
      //      }
      //      sb.append(", terminalUniqueString : " + terminalUniqueString);
      //      EventLogMessage eventLogMessage = new EventLogMessage();
      //      eventLogMessage.setLogMessage(sb.toString());
      //      logService.log(LogLevel.INFO, eventLogMessage,"",SERVICE_NAME.FNSI, null);
      //
      //      boolean ret = webSocketNofityService.chkClientConnect(facilityCdList, terminalUniqueString);
      /* del by renxiaohao  2023-02-01 CodeOptimization  end */
      return new ResponseEntity<>(mntWebsocketCertificationService.isResponseRet(request, req), HttpStatus.OK);
    } catch (Exception e) {
      // マスタ定義が取得できなかった場合
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage( "Exception message : "+ e.getMessage());
      logService.log(LogLevel.DEBUG, eventLogMessage, "", SERVICE_NAME.FNSI, null);
      return new ResponseEntity<>(new MasterUpdateResponse(AdminWebMessage.Error.MASTER_RECORD_ERROR.getMessage()),
          HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  private boolean hasFacilityAccess(NtssUser ntssUser, String facilityCd) {
    return ntssUser == null
      || ntssUser.isNkkAdminUser()
      || facilityCd == null
      || facilityCd.equals(ntssUser.getFacilityCd());
  }
}
