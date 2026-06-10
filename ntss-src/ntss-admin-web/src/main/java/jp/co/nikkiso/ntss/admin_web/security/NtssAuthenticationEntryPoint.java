package jp.co.nikkiso.ntss.admin_web.security;

import jp.co.nikkiso.ntss.admin_web.response.error.ErrorResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.converter.json.MappingJackson2HttpMessageConverter;
import org.springframework.http.server.ServletServerHttpResponse;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.web.AuthenticationEntryPoint;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

import static jp.co.nikkiso.ntss.admin_web.constant.AdminWebMessage.Error.SESSION_TIMEOUT_ERROR;

/**
 * NTSS認証エントリーポイント実装クラス.
 */
public class NtssAuthenticationEntryPoint implements AuthenticationEntryPoint {

  /**
   * Response内容にJSONを書き込む.
   */
  @Autowired
  private MappingJackson2HttpMessageConverter httpMessageConverter;

  /**
   * {@inheritDoc}
   */
  @Override
  public void commence(
      HttpServletRequest request,
      HttpServletResponse response,
      AuthenticationException authException) throws IOException, ServletException {

    if (isRequestedSessionInvalid(request)) {
      // SessionTimeoutの場合は401を返す
      response.setStatus(SESSION_TIMEOUT_ERROR.getHttpStatus().value());

      // ReponseにJSON書込
      httpMessageConverter.write(
        new ErrorResponse(SESSION_TIMEOUT_ERROR.getMessage()),
        MediaType.APPLICATION_JSON_UTF8,
        new ServletServerHttpResponse(response));

      return;
    }
    response.sendError(HttpStatus.UNAUTHORIZED.value(), HttpStatus.UNAUTHORIZED.getReasonPhrase());
  }

  /**
   * SessionTimeoutが発生しているかどうかを判定する.
   * @param request Requestオブジェクト
   * @return {@code true}の場合、SessionTimeoutが発生している
   */
  private boolean isRequestedSessionInvalid(HttpServletRequest request) {
    return request.getRequestedSessionId() != null && !request.isRequestedSessionIdValid();
  }
}
