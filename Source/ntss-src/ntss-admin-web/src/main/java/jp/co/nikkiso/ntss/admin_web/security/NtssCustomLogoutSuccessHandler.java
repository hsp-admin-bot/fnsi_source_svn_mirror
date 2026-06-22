package jp.co.nikkiso.ntss.admin_web.security;

import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.logevent.ILogEventService;
import jp.co.nikkiso.ntss.core.logevent.LogServiceCore;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import org.springframework.http.HttpStatus;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.web.authentication.logout.LogoutSuccessHandler;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.MODULE_NAME;
import static jp.co.nikkiso.ntss.admin_web.security.NtssAuthenticationConstants.Params;

public class NtssCustomLogoutSuccessHandler implements LogoutSuccessHandler {

    //FNSI-修正 ログ対応 xiebzh add start
    /** ログメッセージフォーマット */
    private final static String LOG_MESSAGE = "%sが正常にサインアウトしました。";

    /**
     * ロガー生成コンポーネント
     */
    //@Autowired
    //private EventLoggerFactory eventLoggerFactory;

    @Autowired
    private LogServiceCore logServiceCore;

    @Autowired
    ILogEventService logEventService;
    //FNSI-修正 ログ対応 xiebzh add end

    @Override
    public void onLogoutSuccess(
      HttpServletRequest request,
      HttpServletResponse response,
      Authentication authentication
    ) throws IOException, ServletException {

      if (request.getParameter(Params.FACILITY_CD) != null) {
        // 成功時のログ
        //FNSI-修正 ログ対応 xiebzh add start
//        eventLoggerFactory.getLogger(request.getParameter(Params.FACILITY_CD)).info(
//          new EventLogMessage(
//            request.getParameter(Params.FACILITY_CD),
//            request.getParameter(Params.USERNAME),
//            request.getRemoteAddr(),
//            request.getRequestedSessionId(),
//            "",
//            "",
//            "",
//            "",
//            "",
//            MODULE_NAME.ADMIN_WEB + "," + SERVICE_NAME.FNSI,
//            "",
//            "",
//            "",
//            "正常にサインアウトしました。",
//            "",
//            this.getClass().getName()
//          )
//        );

        Long userId = null;
        String userName = "";
        if (authentication != null && authentication.getPrincipal() != null) {
          NtssUser user = (NtssUser) authentication.getPrincipal();
          userId = user.getUserId();
          userName = user.getUsername();
        }

        logServiceCore.log(
          LogLevel.INFO,
          new EventLogMessage(
            request.getParameter(Params.FACILITY_CD),
            request.getParameter(Params.USERNAME),
            request.getRemoteAddr(),
            request.getRequestedSessionId(),
            "",
            "",
            "",
            "",
            "",
            MODULE_NAME.ADMIN_WEB + "," + SERVICE_NAME.FNSI,
            "",
            "",
            "",
            String.format(LOG_MESSAGE, logEventService.getPersonalUserName(userId)),
            "",
            this.getClass().getName(),
            "サインアウト"
          ),
          null,
          LoggingConstant.MODULE_NAME.ADMIN_WEB,
          LoggingConstant.SERVICE_NAME.FNSI,
          null
          );
        //FNSI-修正 ログ対応 xiebzh add end
      }

      response.setStatus(HttpStatus.OK.value());
    }
}
