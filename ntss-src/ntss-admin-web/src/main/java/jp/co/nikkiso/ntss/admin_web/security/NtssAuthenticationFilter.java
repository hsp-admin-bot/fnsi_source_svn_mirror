package jp.co.nikkiso.ntss.admin_web.security;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.dao.MstFacilityDao;
import jp.co.nikkiso.ntss.core.dao.MstFacilityHashDao;
import jp.co.nikkiso.ntss.core.dao.MstUserDao;
import jp.co.nikkiso.ntss.core.dao.SysSystemManagerDao;
import jp.co.nikkiso.ntss.core.entity.MstFacilityHash;
import jp.co.nikkiso.ntss.core.entity.SysSystemManager;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.EventLogger;
import jp.co.nikkiso.ntss.core.logger.EventLoggerFactory;
import jp.co.nikkiso.ntss.core.logger.LogClass;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.logger.LogObjectUtils;
import org.springframework.http.HttpMethod;
import org.springframework.security.authentication.AuthenticationServiceException;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.util.StringUtils;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import java.util.Enumeration;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

import static jp.co.nikkiso.ntss.admin_web.security.NtssAuthenticationConstants.Params;
import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

/**
 * NTSS認証フィルタークラス.
 */
public class NtssAuthenticationFilter extends UsernamePasswordAuthenticationFilter {
  /**
   * 施設マスタハッシュDaoインタフェース.
   */
  @Autowired
  private MstFacilityHashDao mstFacilityHashDao;

  // FNSI-修正 VPN場合証明書チェックしないの対応 xiebzh add start
  @Autowired
  MstUserDao mstUserDao;

  @Autowired
  private SysSystemManagerDao sysSystemManagerDao;
  // FNSI-修正 VPN場合証明書チェックしないの対応 xiebzh add end

  /**
   * 証明書のチェックフラグ
   */
  @Value("${ntss.admin-web.certificate.enable}")
  private Boolean isEnableCer;
  //add FNSI-【1006】最新の改修対象一覧.NO55を追加 周安寧 start
  /**
   * 施設マスタDaoインタフェース.
   */
  @Autowired
  private MstFacilityDao mstFacilityDao;
  //add FNSI-【1006】最新の改修対象一覧.NO55を追加 周安寧 end

  /**
   * ロガー生成コンポーネント
   */
  @Autowired
  private EventLoggerFactory eventLoggerFactory;

  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
  @Autowired
  private LogService logService;
  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
  /**
   * {@inheritDoc}
   */
  @Override
  public Authentication attemptAuthentication(
    HttpServletRequest request,
    HttpServletResponse response) throws AuthenticationException {

    if (!HttpMethod.POST.equals(HttpMethod.resolve(request.getMethod()))) {
      throw new AuthenticationServiceException("Authentication method not supported: " + request.getMethod());
    }

    try {
      logServerName(request);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end

      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
    }
    String username = getUsername(request);
    String password = getPassword(request);
    String facilityCd = getFacilityCd(request);
    String funcCd = getFuncCd(request);
    String cardCd = getCardCd(request);
    String userIdOnly = getUserIdOnly(request);
    String mode = getMode(request);
	// mod #12587 スタッフ切替 start
    String switchStatus = getSwitchStatus(request);
    NtssAuthenticationToken authRequest =
      new NtssAuthenticationToken(username, password, facilityCd, funcCd, cardCd, userIdOnly, mode,switchStatus);
	// mod #12587 スタッフ切替 end
    setDetails(request, authRequest);
    Authentication authentication = this.getAuthenticationManager().authenticate(authRequest);

    //add FNSI-【1006】最新の改修対象一覧.NO55を追加 周安寧 start
    Boolean vpnFlag = false;

    // del redmine 証明書チェック条件変更(urlだけ判断) xie start
//    if (!StringUtils.isEmpty(facilityCd)){
//      MstFacilityHash mstFacilityHash = mstFacilityHashDao.selectByHashValue(facilityCd);
//      if (mstFacilityHash != null){
//        MstFacility mstFacility = mstFacilityDao.selectByCd(mstFacilityHash.getFacilityCd());
//        if ("1".equals(mstFacility.getVpnSet())) {
//          vpnFlag = isVpn(authentication, request);
//        }
//      }
//    }
    // del redmine 証明書チェック条件変更(urlだけ判断) xie end
    // add redmine 証明書チェック条件変更(urlだけ判断) xie start
    String serverName = request.getServerName();
    if (hasVpn(serverName)) {
      vpnFlag = true;
    }
    // add redmine 証明書チェック条件変更(urlだけ判断) xie end

    //add FNSI-【1006】最新の改修対象一覧.NO55を追加 周安寧 end
    //mod FNSI-【1006】最新の改修対象一覧.NO55を追加 周安寧 start
    //if (isEnableCer) {
    if (isEnableCer && !vpnFlag) {
    //if (isEnableCer) {
      checkCertificate(request, facilityCd);
    }

    return authentication;
  }
  // add #12587 スタッフ切替 start
  private String getSwitchStatus(HttpServletRequest request) {
    return getAdjustedValue(request.getParameter(Params.switchStatus)).trim();
  }
  // add #12587 スタッフ切替 end
  // FNSI-修正 VPN場合証明書チェックしないの対応 xiebzh add start
//  /**
//   * VPNかどうかを判断
//   * @param authentication
//   * @param request
//   * @return
//   */
//  private boolean isVpn(Authentication authentication, HttpServletRequest request) {
//    try {
//      // ユーザーの情報をJSONで返す
//      NtssUser ntssUser = (NtssUser) authentication.getPrincipal();
//      MstUser user = mstUserDao.selectById(ntssUser.getUserId());
//      String loginMethod = user.getLoginMethod();
//      if (StringUtils.isEmpty(loginMethod)) {
//        return false;
//      }
//
//      String serverName = request.getServerName();
//      logServerName(request);
//      // 0:非VPN、1：VPN、2：非VPN/VPN
//      switch (loginMethod) {
//        case "0":
//          return false;
//        case "1":
//          return true;
//        case "2":
//          String[] vpnkeys = getVpnKey();
//          if (vpnkeys == null) {
//            return false;
//          }
//          for (String key : vpnkeys) {
//            if (serverName.indexOf(key) >= 0) {
//              return true;
//            }
//          }
//          break;
//        default:
//          return false;
//      }
//
//      return false;
//    } catch (Exception e) {
//      return false;
//    }
//  }

  /**
   * urlに、vpnを含むかどうかを判断する
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
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
      return null;
    }
  }

  private void logServerName(HttpServletRequest request) {
    try {
      // 成功時のログ
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("request serverName: " + request.getServerName() + " url:" + request.getRequestURL());
      eventLogMessage.setEc2Identification(LogObjectUtils.getHostAddress());
      eventLogMessage.setServiceName(LoggingConstant.SERVICE_NAME.FNSI);
      EventLogger logger = eventLoggerFactory.getLogger("system", LogClass.APP);
      logger.info(eventLogMessage);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
      //      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end

      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
    }
  }
  // FNSI-修正 VPN場合証明書チェックしないの対応 xiebzh add end

  /**
   * 証明書をチェック
   *
   * @param request Request
   * @param facilityCd 施設コード
   */
  private void checkCertificate(HttpServletRequest request, String facilityCd) {
    String subject = null;
    Map<String, String> listHeader = getHeadersInfo(request);

    if (listHeader.get("ssl-client-subject-dn") == null) {
      throw new AuthenticationServiceException("クライアント証明書が見つかりません。");
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
      //FNSI-修正 4450対応 xiebzh add start
      //if (!mstFacilityHash.getFacilityCd().equals(cerFacility)) {
      //  throw new AuthenticationServiceException("クライアント証明書が不正です。");
      //}

      if (cerFacility.indexOf(mstFacilityHash.getFacilityCd()) < 0) {
        throw new AuthenticationServiceException("クライアント証明書が不正です。");
      }
      //FNSI-修正 4450対応 xiebzh add end
    } else {
      throw new AuthenticationServiceException("クライアント証明書が施設と一致しません。");
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
   * 指定されたRequestよりユーザーIDを取得します.
   *
   * @param request Request
   * @return ユーザーID
   */
  private String getUsername(HttpServletRequest request) {
    return getAdjustedValue(request.getParameter(Params.USERNAME)).trim();
  }

  /**
   * 指定されたRequestよりパスワードを取得します.
   *
   * @param request Request
   * @return パスワード
   */
  private String getPassword(HttpServletRequest request) {
    return getAdjustedValue(request.getParameter(Params.PASSWORD));
  }

  /**
   * 指定されたRequestより施設コードを取得します.
   *
   * @param request Request
   * @return 施設コード
   */
  private String getFacilityCd(HttpServletRequest request) {
    return getAdjustedValue(request.getParameter(Params.FACILITY_CD)).trim();
  }

  /**
   * 指定されたRequestより機能コードを取得します.
   *
   * @param request Request
   * @return 機能コード
   */
  private String getFuncCd(HttpServletRequest request) {
    return getAdjustedValue(request.getParameter(Params.FUNC_CD)).trim();
  }

  private String getCardCd(HttpServletRequest request) {
    return getAdjustedValue(request.getParameter(Params.CARD_CD)).trim();
  }

  /**
   * 指定されたRequestよりIDのみでサインインするフラグを取得します.
   *
   * @param request Request
   * @return IDのみでサインインするフラグ
   */
  private String getUserIdOnly(HttpServletRequest request) {
    return getAdjustedValue(request.getParameter(Params.USER_ID_ONLY)).trim();
  }

  /**
   * 指定されたRequestよりモードを取得します.
   *
   * @param request Request
   * @return モード
   */
  private String getMode(HttpServletRequest request) {
    return getAdjustedValue(request.getParameter(Params.MODE)).trim();
  }

  /**
   * 指定された値が{@code null}である場合は空文字を、そうでない場合は指定された値を返却します.
   *
   * @param value 認証用パタメータ値
   * @return 変換された認証用パタメータ値
   */
  private String getAdjustedValue(String value) {
    return Optional.ofNullable(value).orElse("");
  }
}
