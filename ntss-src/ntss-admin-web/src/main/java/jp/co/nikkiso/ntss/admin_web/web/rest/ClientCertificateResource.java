package jp.co.nikkiso.ntss.admin_web.web.rest;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import jp.co.nikkiso.ntss.admin_web.service.log.LogEventUtils;
import jp.co.nikkiso.ntss.core.dao.MstFacilityDao;
import jp.co.nikkiso.ntss.core.dao.SysSystemManagerDao;
import jp.co.nikkiso.ntss.core.entity.SysSystemManager;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.util.StringUtils;
import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Uri;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;

import javax.servlet.http.HttpServletRequest;

import jp.co.nikkiso.ntss.core.dao.MstFacilityHashDao;
import jp.co.nikkiso.ntss.core.entity.MstFacilityHash;

import java.util.Enumeration;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_ERROR;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.BEFORE_LOG_FLG_INFO;

@RestController
@RequestMapping(Uri.CLIENT_CERTIFICATE)
public class ClientCertificateResource {
  /**
   * 施設マスタハッシュDaoインタフェース.
   */
  @Autowired
  private MstFacilityHashDao mstFacilityHashDao;

  //add FNSI-【1006】最新の改修対象一覧.NO55を追加 周安寧 start
  /**
   * 施設マスタDaoインタフェース.
   */
  @Autowired
  private MstFacilityDao mstFacilityDao;
  //add FNSI-【1006】最新の改修対象一覧.NO55を追加 周安寧 end

  @Autowired
  private SysSystemManagerDao sysSystemManagerDao;

  /**
   * 証明書のチェックフラグ
   */
  @Value("${ntss.admin-web.certificate.enable}")
  private Boolean isEnableCer;

  @Autowired
  private LogService logService;

  // wp アプリケーションログの適正化 Add Start
  @Autowired
  LogEventUtils logEventUtils;
  // wp アプリケーションログの適正化 Add End

  @GetMapping("")
  public ResponseEntity<?> checkCertificateController(HttpServletRequest request, @RequestParam String facilityCd) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.CLIENT_CERTIFICATE;
    // modify 9696 kangjie 20240627 start
    MstFacilityHash mstFacilityHash = mstFacilityHashDao.selectByHashValue(facilityCd);
    if (mstFacilityHash == null) {
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), null,
        AFTER_LOG_FLG_ERROR, mappingUrl, null,
        "システムに存在しない施設ハッシュ値でのアクセスがありました。");
      return  new ResponseEntity<>(true, HttpStatus.OK);
    }
//    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), null,
//    BEFORE_LOG_FLG_INFO, mappingUrl, facilityCd,
//      null);
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), null,
      BEFORE_LOG_FLG_INFO, mappingUrl, mstFacilityHash.getFacilityCd(),
    null);
    // modify 9696 kangjie 20240627 end

    // wp アプリケーションログの適正化 Add End
    try {
      Boolean result = true;
      //add FNSI-【1006】最新の改修対象一覧.NO55を追加 周安寧 start
      Boolean vpnFlag = false;

      // del redmine 証明書チェック条件変更(urlだけ判断) xie start
//      if (!StringUtils.isEmpty(facilityCd)){
//        MstFacilityHash mstFacilityHash = mstFacilityHashDao.selectByHashValue(facilityCd);
//        if (mstFacilityHash != null){
//          MstFacility mstFacility = mstFacilityDao.selectByCd(mstFacilityHash.getFacilityCd());
//          if ("1".equals(mstFacility.getVpnSet())) {
//            vpnFlag = true;
//          }
//        }
//      }
      // del redmine 証明書チェック条件変更(urlだけ判断) xie end
      //add FNSI-【1006】最新の改修対象一覧.NO55を追加 周安寧 end

      // add redmine 証明書チェック条件変更(urlだけ判断) xie start
      String serverName = request.getServerName();
      if (hasVpn(serverName)) {
        vpnFlag = true;
      }
      // add redmine 証明書チェック条件変更(urlだけ判断) xie end

      //mod FNSI-【1006】最新の改修対象一覧.NO55を追加 周安寧 start
      //if (isEnableCer) {
      if (isEnableCer && !vpnFlag) {
      //mod FNSI-【1006】最新の改修対象一覧.NO55を追加 周安寧 end
        result = checkCertificate(request, facilityCd);
      }

      // wp アプリケーションログの適正化 Add
      // modify 9696 by kangjie 20240627 start
//      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), null,
//      AFTER_LOG_FLG_INFO, mappingUrl, facilityCd,
//        null);
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), null,
        AFTER_LOG_FLG_INFO, mappingUrl, mstFacilityHash.getFacilityCd(),
        null);
      // modify 9696 by kangjie 20240627 end
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(result, HttpStatus.OK);
    } catch (Exception e) {
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage(e.getMessage());
//      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);

      // wp アプリケーションログの適正化 Add Start
      // modify 9696 by kangjie 20240806 start
//      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), null, AFTER_LOG_FLG_ERROR, mappingUrl, facilityCd, e.getMessage());
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), null, AFTER_LOG_FLG_ERROR, mappingUrl, mstFacilityHash.getFacilityCd(), e.getMessage());
      // modify 9696 by kangjie 20240806 end
      // wp アプリケーションログの適正化 Add End

      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * 証明書をチェック
   *
   * @param request Request
   * @param facilityCd 施設コード
   */
  private Boolean checkCertificate(HttpServletRequest request, String facilityCd) {
    String subject = null;
    Map<String, String> listHeader = getHeadersInfo(request);

    if (listHeader.get("ssl-client-subject-dn") == null) {
      return false;
    } else {
      subject = listHeader.get("ssl-client-subject-dn");
    }

    String cerFacility = null;
    String[] result = subject.split(",");
    for (String item: result) {
      if (item.length() >= 3) {
        if (item.substring(0, 3).equals("CN=")) {
          cerFacility = item.split("=")[1];
          break;
        }
      }
    }
    if (cerFacility != null && !StringUtils.isEmpty(facilityCd)) {
      MstFacilityHash mstFacilityHash = mstFacilityHashDao.selectByHashValue(facilityCd);
      // add redmain #6393 xiebzh start
      //if (!mstFacilityHash.getFacilityCd().equals(cerFacility)) {
      if (StringUtils.isEmpty(cerFacility) || cerFacility.indexOf(mstFacilityHash.getFacilityCd()) < 0) {
      // add redmain #6393 xiebzh end
        return false;
      } else {
        return true;
      }
    } else {
      return false;
    }
  }

  /**
   * リクエストヘッダ情報取得
   *
   * @param request Request
   * @return ヘッダー情報
   */
  private Map<String, String> getHeadersInfo(HttpServletRequest request) {
    Map<String, String> headers = new HashMap<String, String>();

    Enumeration<String> headerNames = request.getHeaderNames();
    while (headerNames.hasMoreElements()) {
      String key = (String) headerNames.nextElement();
      String value = request.getHeader(key);
      headers.put(key, value);
    }
    return headers;
  }

  /**
   * クラス名取得
   */
  private String getClassName() {
    return this.getClass().getName();
  }

  /**
   * メソッド名取得
   */
  private String getMethodName() {
    return Thread.currentThread().getStackTrace()[2].getMethodName();
  }

  // del redmine 証明書チェック条件変更(urlだけ判断) xie start
  /**
   * urlにvpnを含むかどうかを判断する
   * @param serverName
   * @return
   */
  private boolean hasVpn(String serverName) {
    String[] vpnkeys = getVpnKey();
    if (vpnkeys == null) {
      return false;
    }
    for (String key : vpnkeys) {
      if (serverName.indexOf(key) >= 0) {
        return true;
      }
    }

    return false;
  }

  /**
   * VPNキーを取得する
   * @return
   */
  private String[] getVpnKey() {
    try {
      List<SysSystemManager> systemDefine = sysSystemManagerDao.selectByCtlNo(1);
      if (systemDefine == null || systemDefine.size() <= 0) {
        return null;
      }
      ObjectMapper objectMapper = new ObjectMapper();
      Map<String, String[]> infoLogger = objectMapper.readValue(systemDefine.get(0).getValue(), new TypeReference<Map<String, String[]>>() {});
      String[] vpnKeys = infoLogger.get("url");
      return vpnKeys;
    } catch (Exception e) {
      return null;
    }
  }
  // del redmine 証明書チェック条件変更(urlだけ判断) xie end
}
