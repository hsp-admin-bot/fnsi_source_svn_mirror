package jp.co.nikkiso.ntss.certificate_management.filter;

import jp.co.nikkiso.ntss.certificate_management.security.NtssUser;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * クロスタブ・ユーザー不一致検出フィルター。
 *
 * フロントエンドはリクエスト時に X-Expected-User ヘッダーで
 * 「このタブでログインしたユーザーID」を送信する。
 * サーバー側の実際のセッションユーザーと一致しない場合は 401 を返し、
 * リクエストの処理を行わない。
 * これにより、別ユーザーが同一ブラウザの別タブでログインしてセッションが
 * 入れ替わった場合に、元のタブの操作が別ユーザーの権限で実行されることを防ぐ。
 */
@Component
public class CurrentUserHeaderFilter implements Filter {

  private static final String EXPECTED_USER_HEADER = "X-Expected-User";

  @Override
  public void init(FilterConfig filterConfig) throws ServletException {
  }

  @Override
  public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
      throws IOException, ServletException {
    HttpServletRequest httpRequest = (HttpServletRequest) request;
    HttpServletResponse httpResponse = (HttpServletResponse) response;

    // ★追加：クロスタブ・セッション乗っ取り対策
    // フロントエンドがログイン時にグローバル変数へ保存したユーザーIDを
    // X-Expected-User ヘッダーとして送信してくる。
    // ヘッダーが存在する場合のみ照合を行い、存在しない場合（未ログイン画面等）はスキップする。
    String expectedUser = httpRequest.getHeader(EXPECTED_USER_HEADER);
    if (!StringUtils.isEmpty(expectedUser)) {
      try {
        // Spring Security がすでにセッションから認証情報を復元済みのため、
        // ここで取得できる Authentication は JSESSIONID Cookie に紐づくユーザーを示す。
        // 別タブで別ユーザーがログインすると JSESSIONID が上書きされるため、
        // actualUser はそのタブ（B）のユーザーIDになる。
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth != null && auth.isAuthenticated() && auth.getPrincipal() instanceof NtssUser) {
          String actualUser = auth.getName();
          if (!expectedUser.equals(actualUser)) {
            // X-Expected-User（このタブでログインしたユーザー）と
            // 実際のセッションユーザーが不一致 → セッション乗っ取りと判断し、
            // リクエストを処理せず 401 を返す。
            // これにより A の操作が B の権限で実行されることを防ぐ。
            httpResponse.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            httpResponse.setContentType("application/json;charset=UTF-8");
            httpResponse.getWriter().write(
                "{\"message\":\"別のユーザーでセッションが更新されました。再度サインインしてください。\"}");
            return;
          }
        }
      } catch (Exception e) {
        // チェック失敗時はリクエスト処理を継続する（本来の処理を妨げない）
      }
    }

    chain.doFilter(request, response);
  }

  @Override
  public void destroy() {
  }
}
