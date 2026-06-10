package jp.co.nikkiso.ntss.certificate_management.filter;

import jp.co.nikkiso.ntss.certificate_management.constant.ClientCertificateConstant;
import jp.co.nikkiso.ntss.certificate_management.security.NtssUser;
import jp.co.nikkiso.ntss.certificate_management.service.log.LogService;
import jp.co.nikkiso.ntss.core.exception.NtssException;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import javax.servlet.Filter;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.FilterChain;
import javax.servlet.http.HttpServletRequest;
import java.io.IOException;
import java.net.InetAddress;
import java.util.HashMap;
import java.util.Map;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import org.springframework.util.StringUtils;

@Component
public class LogHandleFilter implements Filter {

  /** クライアント証明書発行画面の「発行」ボタン */
  private static final String CL_DETAILS_INSERTCL_URL = "/cl-details/insertCl";
  /** クライアント証明書発行画面の「発行」ボタン */
  private static final String CL_DETAILS_UPDATECL_URL = "/cl-details/updateCl";
  /** クライアント証明書発行画面の「発行」ボタン */
  private static final String CL_FACILITY_UPDATEFACILITY_URL = "/cl-facility/updateFacility";
  /** クライアント証明書発行画面の「発行」ボタン */
  private static final String CL_FACILITY_INSERTFACILITY_URL = "/cl-facility/insertFacility";
  /** 施設一覧画面の「ロック解除」ボタン */
  private static final String CL_FACILITY_UPDATEATTEMPFAIL_URL = "/cl-facility/updateAttempFail";
  /** ユーザ一覧画面の「削除」ボタン */
  private static final String CL_USER_DELETEBYID_URL = "/cl-user/deleteById";
  /** ユーザー追加・編集画面の「OK」ボタン */
  private static final String CL_USER_UPDATEBYID_URL = "/cl-user/updateById";
  /** ユーザ一覧画面の「追加」ボタン */
  private static final String CL_USER_INSERTUSER_URL = "/cl-user/insertUser";
  /** ユーザ一覧画面の「ロック解除」ボタン */
  private static final String CL_USER_UPDATELOGINATTEMPT_URL = "/cl-user/updateLoginAttempt";
  /** CL証明書発行一覧画面の「失効」ボタン */
  private static final String CL_DETAILS_DELETECLDETAILS_URL = "/cl-details/deleteCl";
  /** ログメッセージフォーマット */
  private final static String LOG_MESSAGE = "ユーザー(%s)が%sの%sボタンを押下しました。";
  /** キー　ログメッセージ */
  private final static String LOG_MESSAGE_KEY = "LOG_MESSAGE_KEY";
  /** キー　画面名 */
  private final static String SCREEN_NAME_KEY = "SCREEN_NAME_KEY";
  /** キー　ログ出力フラグ */
  private final static String LOG_OUTPUT_FLG_KEY = "LOG_OUTPUT_FLG_KEY";

  // ロギングサービス
  @Autowired
  LogService logService;

  @Override
  public void init(FilterConfig filterConfig) throws ServletException {
  }

  @Override
  public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
    throws IOException, ServletException {
    try {
      HttpServletRequest httpServletRequest = (HttpServletRequest) request;
      String url = httpServletRequest.getServletPath();
      String userId = getUserId();
      Map info = getLogMessage(url, userId);
      if ((Boolean) info.get(LOG_OUTPUT_FLG_KEY)) {
        outputLog(info);
      }
    } catch (Exception e) {
      e.printStackTrace();
    }
    chain.doFilter(request, response);
  }

  /**
   * ユーザIDを取得する
   * @return ユーザID
   */
  private String getUserId() {
    String userId = "";
    if (SecurityContextHolder.getContext().getAuthentication() == null) {
      return userId;
    }
    Object object = SecurityContextHolder.getContext().getAuthentication().getPrincipal();
    if (object instanceof NtssUser) {
      NtssUser user = (NtssUser) object;
      if (user != null) {
        userId = user.getUsername();
      }
    }
    return userId;
  }

  /**
   * ログメッセージを取得する
   * @param url url
   * @param userId ユーザID
   * @return urlを含むかどうか
   */
  private Map getLogMessage(String url, String userId) {
    Map info = new HashMap();
    // クライアント証明書発行画面の「発行」ボタン
    if (url.contains(CL_DETAILS_INSERTCL_URL) ||
        url.contains(CL_DETAILS_UPDATECL_URL) ||
        url.contains(CL_FACILITY_UPDATEFACILITY_URL) ||
        url.contains(CL_FACILITY_INSERTFACILITY_URL)) {
      String logMessage = String.format(LOG_MESSAGE, userId,
        ClientCertificateConstant.ScreenName.MANAGEMENT_CL_ISSUE, "発行");
      String screenName = ClientCertificateConstant.ScreenName.MANAGEMENT_CL_ISSUE;
      info.put(LOG_MESSAGE_KEY, logMessage);
      info.put(SCREEN_NAME_KEY, screenName);
      info.put(LOG_OUTPUT_FLG_KEY, true);
      return info;
    }
    // 施設一覧画面の「ロック解除」ボタン
    if (url.contains(CL_FACILITY_UPDATEATTEMPFAIL_URL)) {
      String logMessage = String.format(LOG_MESSAGE, userId,
        ClientCertificateConstant.ScreenName.MANAGEMENT_FACILITY_LIST, "ロック解除");
      String screenName = ClientCertificateConstant.ScreenName.MANAGEMENT_FACILITY_LIST;
      info.put(LOG_MESSAGE_KEY, logMessage);
      info.put(SCREEN_NAME_KEY, screenName);
      info.put(LOG_OUTPUT_FLG_KEY, true);
      return info;
    }

    // ユーザ一覧画面の「削除」ボタン
    if (url.contains(CL_USER_DELETEBYID_URL)) {
      String logMessage = String.format(LOG_MESSAGE,
        userId, ClientCertificateConstant.ScreenName.MANAGEMENT_USER_LIST, "削除");
      String screenName = ClientCertificateConstant.ScreenName.MANAGEMENT_USER_LIST;
      info.put(LOG_MESSAGE_KEY, logMessage);
      info.put(SCREEN_NAME_KEY, screenName);
      info.put(LOG_OUTPUT_FLG_KEY, true);
      return info;
    }

    // ユーザー追加・編集画面の「OK」ボタン
    if (url.contains(CL_USER_UPDATEBYID_URL) || url.contains(CL_USER_INSERTUSER_URL)) {
      String logMessage = String.format(LOG_MESSAGE, userId,
        ClientCertificateConstant.ScreenName.MANAGEMENT_USER_EDIT_SCREEN, "OK");
      String screenName = ClientCertificateConstant.ScreenName.MANAGEMENT_USER_EDIT_SCREEN;
      info.put(LOG_MESSAGE_KEY, logMessage);
      info.put(SCREEN_NAME_KEY, screenName);
      info.put(LOG_OUTPUT_FLG_KEY, true);
      return info;
    }

    // ユーザ一覧画面の「ロック解除」ボタン
    if (url.contains(CL_USER_UPDATELOGINATTEMPT_URL)) {
      String logMessage = String.format(LOG_MESSAGE, userId,
        ClientCertificateConstant.ScreenName.MANAGEMENT_USER_LIST, "ロック解除");
      String screenName = ClientCertificateConstant.ScreenName.MANAGEMENT_USER_LIST;
      info.put(LOG_MESSAGE_KEY, logMessage);
      info.put(SCREEN_NAME_KEY, screenName);
      info.put(LOG_OUTPUT_FLG_KEY, true);
      return info;
    }

    /** CL証明書発行一覧画面の「失効」ボタン */
    if (url.contains(CL_DETAILS_DELETECLDETAILS_URL)) {
      String logMessage = String.format(LOG_MESSAGE, userId,
        ClientCertificateConstant.ScreenName.MANAGEMENT_SHOW, "失効");
      String screenName = ClientCertificateConstant.ScreenName.MANAGEMENT_SHOW;
      info.put(LOG_MESSAGE_KEY, logMessage);
      info.put(SCREEN_NAME_KEY, screenName);
      info.put(LOG_OUTPUT_FLG_KEY, true);
      return info;
    }
    info.put(LOG_OUTPUT_FLG_KEY, false);
    return info;
  }

  /**
   * ログ出力する
   * @param info 出力メッセージ
   */
  private void outputLog(Map info) {
    if (StringUtils.isEmpty(info.get(LOG_MESSAGE_KEY))) {
      return;
    }
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setEc2Identification(getHostAddress());
    eventLogMessage.setLogMessage(convertString(info.get(LOG_MESSAGE_KEY)));
    logService.log(LogLevel.INFO, eventLogMessage, "", convertString(info.get(SCREEN_NAME_KEY)), null);
  }

  /**
   * 文字列変換
   * @param obj
   * @return
   */
  private String convertString(Object obj) {
    if (obj == null) {
      return "";
    }
    return obj.toString();
  }

  /**
   * Javaアプリケーションを実行しているマシンのIPアドレスを取得する.
   * 例外が発生した場合、{@link NtssException} をスローする.
   *
   * @return IPアドレス
   * @throws NtssException IPアドレス取得に失敗した場合
   */
  private String getHostAddress() throws NtssException {
    try {
      return InetAddress.getLocalHost().getHostAddress();
    } catch (Exception e) {
      e.printStackTrace();
      throw new NtssException("アプリケーションを実行しているマシンのIPアドレスの取得に失敗しました.", e.getCause());
    }
  }

  @Override
  public void destroy() {
  }
}
