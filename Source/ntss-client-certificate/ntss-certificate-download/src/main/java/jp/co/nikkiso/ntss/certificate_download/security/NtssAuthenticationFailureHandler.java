package jp.co.nikkiso.ntss.certificate_download.security;

import jp.co.nikkiso.ntss.certificate_download.constant.ClientCertificateConstant.ScreenName;
import jp.co.nikkiso.ntss.certificate_download.exception.DataSourceInconsistencyAuthenticationException;
import jp.co.nikkiso.ntss.certificate_download.response.error.ErrorResponse;
import jp.co.nikkiso.ntss.certificate_download.service.log.LogService;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.converter.json.JacksonJsonHttpMessageConverter;
import org.springframework.http.server.ServletServerHttpResponse;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.web.authentication.AuthenticationFailureHandler;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

import static jp.co.nikkiso.ntss.certificate_download.constant.ClientCertificateMessage.Error.DB_INCONSISTENCY;

/**
 * NTSS認証失敗ハンドラー実装クラス.
 */
public class NtssAuthenticationFailureHandler implements AuthenticationFailureHandler {

  /**
   * Response内容にJSONを書き込む.
   * Boot 4 向けに JacksonJsonHttpMessageConverter を使用（役割は旧 MappingJackson2HttpMessageConverter と同じ）.
   */
  @Autowired
  private JacksonJsonHttpMessageConverter httpMessageConverter;

  @Autowired
  private LogService logService;

  /**
   * {@inheritDoc}
   */
  @Override
  public void onAuthenticationFailure(HttpServletRequest request,
                                      HttpServletResponse response,
                                      AuthenticationException exception) throws IOException, ServletException {
    if (exception instanceof DataSourceInconsistencyAuthenticationException) {
      // データソース間不整合の場合は500を返す
      response.setStatus(DB_INCONSISTENCY.getHttpStatus().value());

      // ReponseにJSON書込
      httpMessageConverter.write(
        new ErrorResponse(DB_INCONSISTENCY.getMessage()),
        MediaType.APPLICATION_JSON,
        new ServletServerHttpResponse(response));
    }
    else {
      EventLogMessage eventLogMessage = new EventLogMessage();
      String errMsg = exception.getMessage();
      if (errMsg == null) {
        errMsg = exception.toString() + " " + exception.getStackTrace()[0];
      }
      eventLogMessage.setLogMessage("REST to authenticate failure: " + errMsg);
      logService.log(LogLevel.ERROR, eventLogMessage, null, ScreenName.MANAGEMENT_LOGIN, null);
      response.sendError(HttpStatus.UNAUTHORIZED.value(), errMsg);
    }
  }
}
