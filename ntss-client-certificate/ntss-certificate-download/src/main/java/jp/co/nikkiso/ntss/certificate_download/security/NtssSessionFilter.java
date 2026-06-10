package jp.co.nikkiso.ntss.certificate_download.security;

import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.session.SessionInformation;
import org.springframework.security.core.session.SessionRegistry;
import org.springframework.security.web.authentication.logout.CompositeLogoutHandler;
import org.springframework.security.web.authentication.logout.LogoutHandler;
import org.springframework.security.web.authentication.logout.SecurityContextLogoutHandler;
import org.springframework.util.Assert;
import org.springframework.web.filter.GenericFilterBean;

import javax.servlet.FilterChain;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

/**
 * {@inheritDoc}
 */
public class NtssSessionFilter extends GenericFilterBean {

  /**
   * SessionRegistry.
   */
  private final SessionRegistry sessionRegistry;

  /**
   * LogoutHandler.
   */
  private LogoutHandler handlers = new CompositeLogoutHandler(new SecurityContextLogoutHandler());

  /**
   *コンストラクタ.
   *  @param sessionRegistry SessionRegistry
   */
  public NtssSessionFilter(SessionRegistry sessionRegistry) {
    Assert.notNull(sessionRegistry, "SessionRegistry required");
    this.sessionRegistry = sessionRegistry;
  }

  /**
   * Filtering処理.
   *
   * @param req ServletRequest
   * @param res ServletResponse
   * @param chain FilterChain
   * @throws IOException IO例外
   * @throws ServletException Servlet例外
   */
  public void doFilter(
    ServletRequest req,
    ServletResponse res,
    FilterChain chain) throws IOException, ServletException {

    HttpServletRequest request = (HttpServletRequest) req;
    HttpServletResponse response = (HttpServletResponse) res;
    HttpSession session = request.getSession(false);

    if (isExpired(session)) {
      // 無効な場合、後続処理は行わない
      refuse(request, response);
      return;
    }

    chain.doFilter(request, response);
  }

  /**
   * Sessionが無効化されているかどうか.
   *
   * @param session HttpSession
   * @return {@code true}の場合、無効化されている
   */
  private boolean isExpired(HttpSession session) {
    if (session == null) {
      return false;
    }

    SessionInformation s = sessionRegistry.getSessionInformation(session.getId());
    if (s != null && !s.isExpired()) {
      // 有効である場合、時刻を最新化する
      sessionRegistry.refreshLastRequest(s.getSessionId());
      return false;
    }

    return true;
  }

  /**
   * アクセス拒否処理.
   *
   * @param request HttpServletRequest
   * @param response HttpServletResponse
   * @throws IOException IO例外
   */
  private void refuse(
    HttpServletRequest request,
    HttpServletResponse response) throws IOException {

    // ログアウト処理
    Authentication auth = SecurityContextHolder.getContext().getAuthentication();
    this.handlers.logout(request, response, auth);

    // Forbidden
    response.sendError(
      HttpServletResponse.SC_FORBIDDEN,
      "This session has been expired (possibly due to multiple concurrent logins being attempted as the same user).");
  }

}
