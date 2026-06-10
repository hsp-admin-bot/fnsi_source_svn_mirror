package jp.co.nikkiso.ntss.certificate_management.security;

import jp.co.nikkiso.ntss.certificate_management.constant.ClientCertificateConstant.ScreenName;
import jp.co.nikkiso.ntss.certificate_management.exception.DataSourceInconsistencyAuthenticationException;
import jp.co.nikkiso.ntss.certificate_management.response.error.ErrorResponse;
import jp.co.nikkiso.ntss.certificate_management.service.log.LogService;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.converter.json.MappingJackson2HttpMessageConverter;
import org.springframework.http.server.ServletServerHttpResponse;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.web.authentication.AuthenticationFailureHandler;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

import static jp.co.nikkiso.ntss.certificate_management.constant.ClientCertificateMessage.Error.DB_INCONSISTENCY;

/**
 * NTSS認証失敗ハンドラー実装クラス.
 */
public class NtssAuthenticationFailureHandler implements AuthenticationFailureHandler {

  // mod FNSI-【1006】最新の改修対象一覧.NO45を追加 周安寧 start
  private final static String LOG_MESSAGE = "ユーザー(%s)サインインに失敗しました。";
  // mod FNSI-【1006】最新の改修対象一覧.NO45を追加 周安寧 end
  /**
   * Response内容にJSONを書き込む.
   */
  @Autowired
  private MappingJackson2HttpMessageConverter httpMessageConverter;

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
        MediaType.APPLICATION_JSON_UTF8,
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

      //mod FNSI-【1006】最新の改修対象一覧.NO45を追加 周安寧 start
      EventLogMessage message = new EventLogMessage();
      message.setLogMessage(String.format(LOG_MESSAGE, request.getParameter("userId")));
      logService.log(LogLevel.INFO, message, null, ScreenName.MANAGEMENT_LOGIN, null);
      //mod FNSI-【1006】最新の改修対象一覧.NO45を追加 周安寧 end

      response.sendError(HttpStatus.FORBIDDEN.value(), errMsg);
    }
  }
}
