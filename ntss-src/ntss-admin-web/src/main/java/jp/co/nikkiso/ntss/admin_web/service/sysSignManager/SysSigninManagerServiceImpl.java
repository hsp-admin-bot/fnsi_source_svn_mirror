package jp.co.nikkiso.ntss.admin_web.service.sysSignManager;

import com.amazonaws.util.EC2MetadataUtils;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang start
import com.fasterxml.jackson.databind.ObjectMapper;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang end
import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant;
import jp.co.nikkiso.ntss.admin_web.response.LoginResponse;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.admin_web.service.webSocketNotify.WebSocketNotifyService;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.dao.MntClientConnectDao;
import jp.co.nikkiso.ntss.core.dao.MstFacilityHashDao;
import jp.co.nikkiso.ntss.core.dao.MstPersonalUserDao;
import jp.co.nikkiso.ntss.core.dao.MstUserAuthenticationDao;
import jp.co.nikkiso.ntss.core.dao.SysSigninManagerDao;
import jp.co.nikkiso.ntss.core.entity.MstFacilityHash;
import jp.co.nikkiso.ntss.core.entity.MstPersonalUser;
import jp.co.nikkiso.ntss.core.entity.MstUserAuthentication;
import jp.co.nikkiso.ntss.core.entity.SysSigninManager;
import jp.co.nikkiso.ntss.core.logevent.ILogEventService;
import jp.co.nikkiso.ntss.core.logevent.LogServiceCore;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang start
import jp.co.nikkiso.ntss.core.utils.LogAspectorToolsUtils;
import org.apache.commons.lang3.StringUtils;
import org.springframework.aop.framework.AopProxyUtils;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang end
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.MediaType;
import org.springframework.http.RequestEntity;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.session.SessionInformation;
import org.springframework.security.core.session.SessionRegistry;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.net.InetAddress;
import java.net.URI;
import java.net.UnknownHostException;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang start
import java.util.HashMap;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang end
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang start
import java.util.Objects;
import java.util.Set;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang end

import static jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Uri.SIGN_OUT;
import static jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Uri.SIGN_OUT_ANOTHER;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang start
import static jp.co.nikkiso.ntss.core.utils.LogAspectorToolsUtils.toJson;
import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang end
/**
 * サインイン管理のサービスの実装クラス.
 */
@Service
public class SysSigninManagerServiceImpl implements SysSigninManagerService {

  private static final String FORCE_SIGN_OUT_LOG_MESSAGE = "%sが%sにより強制サインアウトされました。";
  private static final String SIGN_OUT_FUNCTION_NAME = "サインアウト";

  // add #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dou start
  @Value("${server.port:#{8080}}")
  private String port;
  // add #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dou end

  /**
   * サインイン管理のDaoインタフェース
   */
  @Autowired
  private SysSigninManagerDao sysSigninManagerDao;

  /**
   * 利用者マスタ(認証DB)のDaoインタフェース
   */
  @Autowired
  private MstUserAuthenticationDao mstUserAuthenticationDao;

  /**
   * SessionRegistry (セッションの管理情報)
   */
  @Autowired
  private SessionRegistry sessionRegistry;

  // add #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dou start
  /**
   * WebSocketクライアント接続状態のDaoインタフェース
   */
  @Autowired
  private MntClientConnectDao mntClientConnectDao;

  /**
   * ログ出力サービスのインタフェース.
   */
  @Autowired
  private LogService logService;

  @Autowired
  private LogServiceCore logServiceCore;

  @Autowired
  private ILogEventService logEventService;

  @Autowired
  private WebSocketNotifyService webSocketNotifyService;
  // add #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dou end

  /* add by chamaojia 2025-03-18 [11587] add automatic logon --start */
  @Autowired
  private MstFacilityHashDao mstFacilityHashDao;

  @Autowired
  private MstPersonalUserDao personalUserDao;
  /* add chamaojia 2025-03-18 [11587] add automatic logon --end */

  /**
   * {@inheritDoc}
   */
  @Override
  public List<SysSigninManager> getAll() {
    return sysSigninManagerDao.selectAll();
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public int insertSysSigninManager(SysSigninManager sysSigninManager) {
    // 登録データが既に存在していないかをチェック
    List<SysSigninManager> target = getByParam(sysSigninManager);
    if (!target.isEmpty()) {
      // 既に登録済
      return 0;
    }
    // add 11587 by kangjie 20250226 start
    String ip;
    try {
      ip = InetAddress.getLocalHost().getHostAddress();
    } catch (UnknownHostException e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (sysSigninManager != null && !StringUtils.isEmpty(sysSigninManager.getFacilityCd())) {
        eventLogMessage.setFacilityCd(sysSigninManager.getFacilityCd());
      }
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
      ip = EC2MetadataUtils.getInstanceInfo().getPrivateIp();
    }
    sysSigninManager.setServerIp(ip);
    // add 11587 by kangjie 20250226 end
    return sysSigninManagerDao.insert(sysSigninManager);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public List<SysSigninManager> getByParam(SysSigninManager sysSigninManager) {
    // 取得した結果をもとに詳細情報を取得する.
    List<SysSigninManager> result = sysSigninManagerDao.selectByParam(sysSigninManager);
    // 必要な情報を取得する
    result.forEach(s -> {
      Long userId = s.getUserId();
      MstUserAuthentication mstUserAuthentication = mstUserAuthenticationDao.selectById(userId);
      if (mstUserAuthentication == null) {
        return;
      }
      s.setDispUserId(mstUserAuthentication.getDispUserId());
    });
    return result;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public int deleteByParam(SysSigninManager sysSigninManager) {
    return sysSigninManagerDao.deleteByParam(sysSigninManager);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public int deleteByUserId(Long userId, String terminalUniqueString) {
    return sysSigninManagerDao.deleteByUserId(userId, terminalUniqueString);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public void signOutUser(Long userId) {
    signOutUser(userId, ForceSignOutReason.USER_AUTHORITY_CHANGED);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public void signOutUser(Long userId, ForceSignOutReason reason) {
    for (Object principal : sessionRegistry.getAllPrincipals()) {
      if (principal instanceof NtssUser) {
        NtssUser userDetails = (NtssUser) principal;
        // 指定IDに該当する場合
        if (userDetails.getUserId().equals(userId)) {
          List<SessionInformation> sessions = sessionRegistry.getAllSessions(principal, false);
          sessions.forEach(session -> {
            outputForceSignOutLog(userDetails, session.getSessionId(), reason);
            // セッションをタイムアウトさせる
            session.expireNow();
          });
        }
      }
    }
    // サインイン管理情報の削除(DBに残っている可能性があるので必ず実施)
    SysSigninManager sysSigninManager = new SysSigninManager();
    sysSigninManager.setUserId(userId);
    sysSigninManagerDao.deleteByParam(sysSigninManager);
  }

  // add #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dou start
  /**
   * サインアウト
   *
   * @param facilityCd
   * @param userId
   */
  @Override
  public void signOutUserForMultiServer(String facilityCd, Long userId) {
    signOutUserForMultiServer(facilityCd, userId, ForceSignOutReason.USER_AUTHORITY_CHANGED);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public void signOutUserForMultiServer(String facilityCd, Long userId, ForceSignOutReason reason) {
    if (reason == null) {
      reason = ForceSignOutReason.USER_AUTHORITY_CHANGED;
    }
    StringBuilder commApiUri = new StringBuilder();
    URI uri;
    String apiUri = "/ntss-admin-web" + SIGN_OUT;
    // IPアドレスを取得
    // modify 11587 by kangjie 20250226 start
//    List<MntClientConnect> mntClientConnectList = mntClientConnectDao.selectByServerType(facilityCd, 1);
    List<SysSigninManager> sysSigninManagers = sysSigninManagerDao.selectByUserId(String.valueOf(userId));
    Set<String> targetServerIps = new LinkedHashSet<>();
    for (SysSigninManager sysSigninManager : sysSigninManagers) {
      if (StringUtils.isNotEmpty(sysSigninManager.getServerIp())) {
        targetServerIps.add(sysSigninManager.getServerIp());
      }
    }

    // セッション無効化前に、対象利用者の全ブラウザへ強制サインアウトを通知する
    if (!sysSigninManagers.isEmpty()) {
      webSocketNotifyService.sendMsg(
        WebSocketNotifyService.SendTarget.browser,
        facilityCd,
        null,
        AdminWebConstant.WebSocketTopic.FORCE_SIGNOUT,
        userId.toString()
      );
    }
//    for (MntClientConnect item : mntClientConnectList) {
    // 同一サーバーへの通知は一度だけにする
    for (String serverIp : targetServerIps) {
      // modify 11587 by kangjie 20250226 end
      commApiUri.setLength(0);
      commApiUri
        .append("http://")
        // modify 11587 by kangjie 20250226 start
        // .append(item.getIpAddress())
        .append(serverIp)
        // modify 11587 by kangjie 20250226 end
        .append(":")
        .append(this.port)
        .append(apiUri);
      try {
        uri = new URI(commApiUri.toString());
        RestTemplate rt = new RestTemplate();
        RequestEntity<String> request = RequestEntity
          .post(uri)
          .contentType(MediaType.APPLICATION_JSON)
          .header("SSECCAYEK", "NTSS-NKK-ESM-TDC-YSK")
          .header("ForceSignOutReason", reason.name())
          .body(userId.toString());
// #9698 アプリケーションログの内容修正 20260328 mod yangxuewang start
        long start = System.currentTimeMillis();
        ResponseEntity<Object> response = rt.exchange(request, Object.class);
        long cost = System.currentTimeMillis() - start;
        Map<String, Object> map = new HashMap<>();
        map.put("logType", "RESTTEMPLATE-LOG");
        map.put("className", "jp.co.nikkiso.ntss.admin_web.service.sysSignManager.SysSigninManagerServiceImpl");
        map.put("methodName", "signOutUserForMultiServer");
        map.put("method", request.getMethod());
        map.put("url", uri.getPath());
        map.put("headers", request.getHeaders());
        map.put("requestParameter", request.getBody());
        map.put("status",response.getStatusCode());
        map.put("cost", cost);
        map.put("result",response.getBody());
        EventLogMessage restTemplateEventLogMessage = new EventLogMessage();
        restTemplateEventLogMessage.setLogMessage(toJson(map));
        restTemplateEventLogMessage.setFacilityCd(facilityCd);
        logService.log(LogLevel.INFO, restTemplateEventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
// #9698 アプリケーションログの内容修正 20260328 mod yangxuewang end
      } catch (Exception e) {
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("signOutUserForMultiServerに失敗" + e);
        logService.log(LogLevel.ERROR, eventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI,
          null);
      }
    }
  }
  // add #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dou end
  // add #10160 複数端末同時サインイン無効時の強制サインアウトが動作しない。 dou start
  /**
   * 自分自身以外のセッションを無効化（タイムアウト）する.
   *
   * @param params
   */
  @Override
  public void signOutAnotherForMultiServer(Map<String, String> params) {
    signOutAnotherForMultiServer(params, ForceSignOutReason.MULTI_BROWSER_SIGN_IN_PROHIBITED);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public void signOutAnotherForMultiServer(Map<String, String> params, ForceSignOutReason reason) {
    if (reason == null) {
      reason = ForceSignOutReason.MULTI_BROWSER_SIGN_IN_PROHIBITED;
    }
    StringBuilder commApiUri = new StringBuilder();
    URI uri;
    String apiUri = "/ntss-admin-web" + SIGN_OUT_ANOTHER;
    // IPアドレスを取得
    // modify 11587 by kangjie 20250226 start
    params.put("forceSignOutReason", reason.name());
    String userId = params.get("userId");
    String facilityCd = Objects.toString(params.get("facilityCd"), null);
    String currentTerminalUniqueString = params.get("terminalUniqueString");
    List<SysSigninManager> sysSigninManagers = sysSigninManagerDao.selectByUserId(userId);
    Set<String> targetTerminalUniqueStrings = new LinkedHashSet<>();
    Set<String> targetServerIps = new LinkedHashSet<>();
    for (SysSigninManager sysSigninManager : sysSigninManagers) {
      String terminalUniqueString = sysSigninManager.getTerminalUniqueString();
      if (StringUtils.isNotEmpty(terminalUniqueString)
        && !terminalUniqueString.equals(currentTerminalUniqueString)) {
        targetTerminalUniqueStrings.add(terminalUniqueString);
      }
      if (StringUtils.isNotEmpty(sysSigninManager.getServerIp())) {
        targetServerIps.add(sysSigninManager.getServerIp());
      }
    }

    // 旧ブラウザへ先に強制サインアウト通知し、即座にログイン画面へ遷移させる
    for (String terminalUniqueString : targetTerminalUniqueStrings) {
      webSocketNotifyService.sendMsg(
        WebSocketNotifyService.SendTarget.browser,
        facilityCd,
        null,
        AdminWebConstant.WebSocketTopic.FORCE_SIGNOUT,
        userId + ":" + terminalUniqueString
      );
    }
//    List<MntClientConnect> mntClientConnectList = mntClientConnectDao.selectByServerType(params.get("facilityCd"), 1);
//    for (MntClientConnect item : mntClientConnectList) {
    // 同一サーバーへの通知は一度だけにする
    for (String serverIp : targetServerIps) {
      commApiUri.setLength(0);
      commApiUri
        .append("http://")
        // modify 11587 by kangjie 20250226 start
        // .append(item.getIpAddress())
        .append(serverIp)
        // modify 11587 by kangjie 20250226 end
        .append(":")
        .append(this.port)
        .append(apiUri);
      try {
        uri = new URI(commApiUri.toString());
        RestTemplate rt = new RestTemplate();
        RequestEntity<Map<String, String>> request = RequestEntity
          .post(uri)
          .contentType(MediaType.APPLICATION_JSON)
          .header("SSECCAYEK", "NTSS-NKK-ESM-TDC-YSK")
          .body(params);
// #9698 アプリケーションログの内容修正 20260328 mod yangxuewang start
        long start = System.currentTimeMillis();
        ResponseEntity<Object> response = rt.exchange(request, Object.class);
        long cost = System.currentTimeMillis() - start;
        Map<String, Object> map = new HashMap<>();
        map.put("logType", "RESTTEMPLATE-LOG");
        map.put("className", "jp.co.nikkiso.ntss.admin_web.service.sysSignManager.SysSigninManagerServiceImpl");
        map.put("methodName", "signOutAnotherForMultiServer");
        map.put("method", request.getMethod());
        map.put("url", uri.getPath());
        map.put("headers", request.getHeaders());
        map.put("requestParameter", request.getBody());
        map.put("status",response.getStatusCode());
        map.put("cost", cost);
        map.put("result",response.getBody());
        EventLogMessage restTemplateEventLogMessage = new EventLogMessage();
        restTemplateEventLogMessage.setLogMessage(toJson(map));
        if (params != null ) {
          if (!org.springframework.util.StringUtils.isEmpty(facilityCd)) {
            restTemplateEventLogMessage.setFacilityCd(facilityCd);
          }
        }
        logService.log(LogLevel.INFO, restTemplateEventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
// #9698 アプリケーションログの内容修正 20260328 mod yangxuewang end
      } catch (Exception e) {
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("signOutUserForMultiServerに失敗" + e);
        logService.log(LogLevel.ERROR, eventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI,
          null);
      }
    }
  }
  // add #10160 複数端末同時サインイン無効時の強制サインアウトが動作しない。 dou end

  private void outputForceSignOutLog(NtssUser userDetails, String sessionId, ForceSignOutReason reason) {
    if (userDetails == null || reason == null) {
      return;
    }

    String userName = logEventService.getPersonalUserName(userDetails.getUserId());
    if (StringUtils.isEmpty(userName)) {
      userName = userDetails.getUsername();
    }

    logServiceCore.log(
      LogLevel.INFO,
      new EventLogMessage(
        userDetails.getFacilityCd(),
        userDetails.getUsername(),
        userDetails.getClientIpAddress(),
        sessionId,
        "",
        "",
        "",
        "",
        "",
        LoggingConstant.MODULE_NAME.ADMIN_WEB + "," + LoggingConstant.SERVICE_NAME.FNSI,
        "",
        "",
        "",
        String.format(FORCE_SIGN_OUT_LOG_MESSAGE, userName, reason.getLogReason()),
        "",
        this.getClass().getName(),
        SIGN_OUT_FUNCTION_NAME
      ),
      null,
      LoggingConstant.MODULE_NAME.ADMIN_WEB,
      LoggingConstant.SERVICE_NAME.FNSI,
      null
    );
  }

  /* add by chamaojia 2025-03-18 [11587] add automatic logon --start */
  @Override
  public LoginResponse getAutoLoginInfo(String userId, String facilityCd) {
    MstFacilityHash mstFacilityHash = mstFacilityHashDao.selectByHashValue(facilityCd);
    MstUserAuthentication mstUser = mstUserAuthenticationDao.selectForLogin(userId, mstFacilityHash.getFacilityCd());
    MstPersonalUser mstPersonalUser = personalUserDao.selectById(mstUser.getUserId());
    return new LoginResponse(mstFacilityHash.getFacilityCd(), mstUser.getUserId(),
            mstPersonalUser.getUserType());
  }
  /* add by chamaojia 2025-03-18 [11587] add automatic logon --end */
}
