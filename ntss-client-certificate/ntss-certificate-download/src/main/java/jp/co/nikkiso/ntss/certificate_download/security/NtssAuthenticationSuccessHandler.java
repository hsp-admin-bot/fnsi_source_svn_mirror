package jp.co.nikkiso.ntss.certificate_download.security;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jp.co.nikkiso.ntss.certificate_download.service.log.LogService;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpOutputMessage;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.converter.json.JacksonJsonHttpMessageConverter;
import org.springframework.http.server.ServletServerHttpResponse;
import org.springframework.security.core.Authentication;
import org.springframework.security.web.WebAttributes;
import org.springframework.security.web.authentication.AuthenticationSuccessHandler;

import jp.co.nikkiso.ntss.certificate_download.constant.ClientCertificateConstant.ScreenName;
import jp.co.nikkiso.ntss.certificate_download.response.LoginResponse;

/**
 * NTSS認証成功ハンドラー実装クラス.
 */
public class NtssAuthenticationSuccessHandler implements AuthenticationSuccessHandler {

  /** Boot 4 向け JSON 変換（旧 MappingJackson2HttpMessageConverter と同等）. */
  @Autowired
  JacksonJsonHttpMessageConverter httpMessageConverter;

  @Autowired
  private LogService logService;

  /**
   * サインイン後勝ち有効設定
   */
  @Value("${ntss.certificate.sign-in.restriction}")
  private Boolean signInRestriction;

  @Override
  public void onAuthenticationSuccess(HttpServletRequest request, HttpServletResponse response,
      Authentication authentication) throws IOException, ServletException {
    if (response.isCommitted()) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("Response has already been committed.");
      logService.log(LogLevel.INFO, eventLogMessage, null, ScreenName.MANAGEMENT_LOGIN, null);
      return;
    }
    // ユーザーの情報をJSONで返す
    NtssUser ntssUser = (NtssUser) authentication.getPrincipal();
    LoginResponse loginResponse = new LoginResponse(ntssUser.getUsername(), ntssUser.getUserRole(),
        ntssUser.getUserFullname(), signInRestriction);
    HttpOutputMessage outputMessage = new ServletServerHttpResponse(response);
    httpMessageConverter.write(loginResponse, MediaType.APPLICATION_JSON, outputMessage);
    request.getSession().setMaxInactiveInterval(30 * 60);
    response.setStatus(HttpStatus.OK.value());
    clearAuthenticationAttributes(request);
  }

  /**
   * 認証プロセス中にセッションに保存された一時的な認証関連データを削除します。
   */
  private void clearAuthenticationAttributes(HttpServletRequest request) {
    HttpSession session = request.getSession(false);

    if (session == null) {
      return;
    }
    session.removeAttribute(WebAttributes.AUTHENTICATION_EXCEPTION);
  }
}
