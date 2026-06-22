package jp.co.nikkiso.ntss.certificate_download.security;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.security.web.csrf.CsrfToken;
import org.springframework.security.web.csrf.CsrfTokenRequestAttributeHandler;
import org.springframework.security.web.csrf.CsrfTokenRequestHandler;
import org.springframework.security.web.csrf.XorCsrfTokenRequestAttributeHandler;
import org.springframework.util.StringUtils;

import java.util.function.Supplier;

/**
 * SPA（Vue + Axios）向け CSRF ハンドラ.
 * <p>
 * Spring Security 6 以降は認証成功時に CSRF トークン Cookie がクリアされ、deferred token により
 * GET 応答だけでは Cookie が更新されない場合がある。Axios が Cookie から X-XSRF-TOKEN を
 * 送る従来（Boot 2）の挙動を維持しつつ、各リクエストで新しい Cookie を返す。
 * </p>
 *
 * @see <a href="https://docs.spring.io/spring-security/reference/servlet/exploits/csrf.html#csrf-integration-javascript-spa">Spring Security CSRF SPA integration</a>
 */
public class SpaCsrfTokenRequestHandler implements CsrfTokenRequestHandler {

  private final CsrfTokenRequestHandler plain = new CsrfTokenRequestAttributeHandler();
  private final CsrfTokenRequestHandler xor = new XorCsrfTokenRequestAttributeHandler();

  @Override
  public void handle(HttpServletRequest request, HttpServletResponse response, Supplier<CsrfToken> csrfToken) {
    this.xor.handle(request, response, csrfToken);
    // deferred token を読み込み、認証後など Cookie 再発行が必要な場合に応答へ書き込む
    csrfToken.get();
  }

  @Override
  public String resolveCsrfTokenValue(HttpServletRequest request, CsrfToken csrfToken) {
    String headerValue = request.getHeader(csrfToken.getHeaderName());
    if (StringUtils.hasText(headerValue)) {
      return plain.resolveCsrfTokenValue(request, csrfToken);
    }
    return xor.resolveCsrfTokenValue(request, csrfToken);
  }
}
