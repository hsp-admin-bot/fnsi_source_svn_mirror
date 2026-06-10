package jp.co.nikkiso.ntss.admin_web.web;

import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.admin_web.service.sysSignManager.SysSigninManagerService.ForceSignOutReason;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.logevent.ILogEventService;
import jp.co.nikkiso.ntss.core.logevent.LogServiceCore;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContext;
import org.springframework.security.web.context.HttpSessionSecurityContextRepository;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import java.io.IOException;

/**
 * A self-made session timeout management filter.
 * Some requests are invoked by background process, we don't want to update session last access time for these requests.
 * So we need to check if the request is invoked by background process, if so, we don't update session last access time.
 * At the same time, we need to check session last access time, if it's timeout, we need to invalidate the session.
 * @author HandsoemLin
 */
public class SessionTimeoutManageFilter implements Filter {

  private static final String BACKGROUND_CALL_PARAM = "__background_call__";
  private static final String LAST_ACCESS_TIME_ATTR = SessionTimeoutManageFilter.class.getSimpleName() + ".lastAccessTime";
  private static final String FORCE_SIGN_OUT_LOG_MESSAGE = "%sが%sにより強制サインアウトされました。";
  private static final String SIGN_OUT_FUNCTION_NAME = "サインアウト";

  private LogService logService;
  private LogServiceCore logServiceCore;
  private ILogEventService logEventService;

  @Autowired
  public void setLogService(LogService logService) {
    this.logService = logService;
  }

  @Autowired
  public void setLogServiceCore(LogServiceCore logServiceCore) {
    this.logServiceCore = logServiceCore;
  }

  @Autowired
  public void setLogEventService(ILogEventService logEventService) {
    this.logEventService = logEventService;
  }

  @Override
  public void init(FilterConfig filterConfig) throws ServletException {
  }

  @Override
  public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws IOException, ServletException {
    if (!(request instanceof HttpServletRequest)) {
      chain.doFilter(request, response);
      return;
    }
    HttpServletRequest httpServletRequest = (HttpServletRequest) request;
    HttpSession session = httpServletRequest.getSession(false);
    boolean sessionInvalidated = false;
    if (session != null) {
      Object lastAccessedTime = session.getAttribute(LAST_ACCESS_TIME_ATTR);
      if (lastAccessedTime instanceof Long) {
        Long lastAccessedTimeLong = (Long) lastAccessedTime;
        /* mod #9314  by zhangruixue 2023-08-10 --start */
        if (session.getMaxInactiveInterval() > 0 &&
          System.currentTimeMillis() - lastAccessedTimeLong > session.getMaxInactiveInterval() * 1000L) {
        /* mod #9314  by zhangruixue 2023-08-10 --end */
          outputSessionTimeoutLog(httpServletRequest, session);
          session.invalidate();
          sessionInvalidated = true;
        }
      }
    }
    try {
      chain.doFilter(request, response);
    } finally {
      if (session != null && !sessionInvalidated) {
        if (!Boolean.parseBoolean(httpServletRequest.getParameter(BACKGROUND_CALL_PARAM))) {
          try {
            session.setAttribute(LAST_ACCESS_TIME_ATTR, System.currentTimeMillis());
          } catch (Exception e) {
            EventLogMessage eventLogMessage = new EventLogMessage();
            eventLogMessage.setLogMessage("Update session last access time failed.");
            logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI,
              null);
          }
        }
      }
    }
  }

  @Override
  public void destroy() {

  }

  private void outputSessionTimeoutLog(HttpServletRequest request, HttpSession session) {
    if (logServiceCore == null || logEventService == null) {
      return;
    }

    try {
      Object securityContextObj = session.getAttribute(HttpSessionSecurityContextRepository.SPRING_SECURITY_CONTEXT_KEY);
      if (!(securityContextObj instanceof SecurityContext)) {
        return;
      }
      Authentication authentication = ((SecurityContext) securityContextObj).getAuthentication();
      if (authentication == null || !(authentication.getPrincipal() instanceof NtssUser)) {
        return;
      }
      NtssUser userDetails = (NtssUser) authentication.getPrincipal();
      String userName = logEventService.getPersonalUserName(userDetails.getUserId());
      if (userName == null || userName.isEmpty()) {
        userName = userDetails.getUsername();
      }
      String clientIp = userDetails.getClientIpAddress();
      if (clientIp == null || clientIp.isEmpty()) {
        clientIp = request.getRemoteAddr();
      }

      logServiceCore.log(
        LogLevel.INFO,
        new EventLogMessage(
          userDetails.getFacilityCd(),
          userDetails.getUsername(),
          clientIp,
          session.getId(),
          "",
          "",
          "",
          "",
          "",
          LoggingConstant.MODULE_NAME.ADMIN_WEB + "," + LoggingConstant.SERVICE_NAME.FNSI,
          "",
          "",
          "",
          String.format(FORCE_SIGN_OUT_LOG_MESSAGE, userName, ForceSignOutReason.SESSION_TIMEOUT.getLogReason()),
          "",
          this.getClass().getName(),
          SIGN_OUT_FUNCTION_NAME
        ),
        null,
        LoggingConstant.MODULE_NAME.ADMIN_WEB,
        LoggingConstant.SERVICE_NAME.FNSI,
        null
      );
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("Output session timeout sign-out log failed.");
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
    }
  }
}
