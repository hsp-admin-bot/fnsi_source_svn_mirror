package jp.co.nikkiso.ntss.certificate_download.security;

import jp.co.nikkiso.ntss.certificate_download.response.error.ErrorResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.converter.json.JacksonJsonHttpMessageConverter;
import org.springframework.http.server.ServletServerHttpResponse;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.web.AuthenticationEntryPoint;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

import static jp.co.nikkiso.ntss.certificate_download.constant.ClientCertificateMessage.Error.SESSION_TIMEOUT_ERROR;

/**
 * NTSS認証エントリーポイント実装クラス.
 */
public class NtssAuthenticationEntryPoint implements AuthenticationEntryPoint {

  /**
   * Response内容にJSONを書き込む.
   * Boot 4 向けに JacksonJsonHttpMessageConverter を使用（役割は旧 MappingJackson2HttpMessageConverter と同じ）.
   */
  @Autowired
  private JacksonJsonHttpMessageConverter httpMessageConverter;

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
        MediaType.APPLICATION_JSON,
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
