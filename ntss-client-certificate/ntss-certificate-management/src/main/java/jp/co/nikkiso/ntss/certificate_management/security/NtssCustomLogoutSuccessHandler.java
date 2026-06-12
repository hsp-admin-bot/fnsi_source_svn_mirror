package jp.co.nikkiso.ntss.certificate_management.security;

import jp.co.nikkiso.ntss.certificate_management.constant.ClientCertificateConstant;
import jp.co.nikkiso.ntss.certificate_management.service.log.LogService;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.Authentication;
import org.springframework.security.web.authentication.logout.LogoutSuccessHandler;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

public class NtssCustomLogoutSuccessHandler implements LogoutSuccessHandler {
  /** ログメッセージフォーマット */
  private final static String LOG_MESSAGE = "ユーザー(%s)が(ID=%s)に正常にサインアウトしました。";

  @Autowired
  private LogService logService;

  @Override
  public void onLogoutSuccess(
    HttpServletRequest request,
    HttpServletResponse response,
    Authentication authentication
  ) throws IOException, ServletException {

    // ユーザーの情報をJSONで返す
    NtssUser ntssUser = (NtssUser) authentication.getPrincipal();
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage(String.format(LOG_MESSAGE, ntssUser.getUserFullname(), ntssUser.getUsername()));
    logService.log(LogLevel.INFO, eventLogMessage, null, ClientCertificateConstant.ScreenName.MANAGEMENT_LOGIN, null);
    response.setStatus(HttpStatus.OK.value());
  }
}
