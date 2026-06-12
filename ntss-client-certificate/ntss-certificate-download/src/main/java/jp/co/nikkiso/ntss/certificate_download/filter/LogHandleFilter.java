package jp.co.nikkiso.ntss.certificate_download.filter;

import jp.co.nikkiso.ntss.certificate_download.constant.ClientCertificateConstant;
import jp.co.nikkiso.ntss.certificate_download.security.NtssUser;
import jp.co.nikkiso.ntss.certificate_download.service.log.LogService;
import jp.co.nikkiso.ntss.core.exception.NtssException;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import jakarta.servlet.Filter;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.FilterChain;
import jakarta.servlet.http.HttpServletRequest;
import java.io.IOException;
import java.net.InetAddress;
import java.util.HashMap;
import java.util.Map;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import org.springframework.util.StringUtils;

@Component
public class LogHandleFilter implements Filter {

  /** ダウンロード画面の「ダウンロード」ボタン */
  private static final String CL_DOWNLOAD_DOWNLOADCERTIFICATE = "/cl-download/downloadCertificate";
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
    // ダウンロード画面の「ダウンロード」ボタン
    if (url.contains(CL_DOWNLOAD_DOWNLOADCERTIFICATE)) {
      String logMessage = String.format(LOG_MESSAGE, userId,
        ClientCertificateConstant.ScreenName.DOWNLOAD_SCREEN, "ダウンロード");
      String screenName = ClientCertificateConstant.ScreenName.DOWNLOAD_SCREEN;
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
