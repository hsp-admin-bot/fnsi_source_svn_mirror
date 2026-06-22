package jp.co.nikkiso.ntss.certificate_download.security;

import org.springframework.http.HttpMethod;
import org.springframework.security.authentication.AuthenticationServiceException;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.util.Optional;

import static jp.co.nikkiso.ntss.certificate_download.security.NtssAuthenticationConstants.Params;

/**
 * NTSS認証フィルタークラス.
 */
public class NtssAuthenticationFilter extends UsernamePasswordAuthenticationFilter {

  /**
   * {@inheritDoc}
   */
  @Override
  public Authentication attemptAuthentication(
    HttpServletRequest request,
    HttpServletResponse response) throws AuthenticationException {

    if (!HttpMethod.POST.matches(request.getMethod())) {
      throw new AuthenticationServiceException("Authentication method not supported: " + request.getMethod());
    }

    String username = getUsername(request);
    String password = getPassword(request);
    boolean isUserLogin = isUserLogin(request);
    NtssAuthenticationToken authRequest =
      new NtssAuthenticationToken(username, password, isUserLogin);

    setDetails(request, authRequest);
    return this.getAuthenticationManager().authenticate(authRequest);
  }

  /**
   * 指定されたRequestよりユーザーIDを取得します.
   *
   * @param request Request
   * @return ユーザーID
   */
  private String getUsername(HttpServletRequest request) {
    return getAdjuestedValue(request.getParameter(Params.USERNAME)).trim();
  }

  /**
   * 指定されたRequestよりパスワードを取得します.
   *
   * @param request Request
   * @return パスワード
   */
  private String getPassword(HttpServletRequest request) {
    return getAdjuestedValue(request.getParameter(Params.PASSWORD));
  }

  /**
   * 指定されたリクエストからユーザーかどうかを確認します.
   *
   * @param request Request
   * @return boolean
   */
  private boolean isUserLogin(HttpServletRequest request) {
    return Boolean.parseBoolean(getAdjuestedValue(request.getParameter(Params.ISUSERLOGIN)));
  }

  /**
   * 指定された値が{@code null}である場合は空文字を、そうでない場合は指定された値を返却します.
   *
   * @param value 認証用パタメータ値
   * @return 変換された認証用パタメータ値
   */
  private String getAdjuestedValue(String value) {
    return Optional.ofNullable(value).orElse("");
  }
}
