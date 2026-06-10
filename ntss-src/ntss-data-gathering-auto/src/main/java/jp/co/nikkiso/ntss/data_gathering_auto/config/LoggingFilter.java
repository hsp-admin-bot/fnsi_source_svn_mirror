package jp.co.nikkiso.ntss.data_gathering_auto.config;

import java.io.IOException;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.env.Environment;
import org.springframework.stereotype.Component;
import jp.co.nikkiso.ntss.core.config.NtssSecurityPoricy;
import jp.co.nikkiso.ntss.core.logger.EventLoggerFactory;

@Component
public class LoggingFilter implements Filter {

  @Autowired
  private Environment environment;

  /**
   * ロガー生成コンポーネント
   */
  @Autowired
  private EventLoggerFactory eventLoggerFactory;

  @Override
  public void init(FilterConfig filterConfig) throws ServletException {
  }

  @Override
  public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
      throws IOException, ServletException {

    // セキュリティ対策実施フラグチェック
    if ("false".equals(this.environment.getProperty("securityporicy.accesskeycheck"))) {
      // 次のフィルタにフォワード
      chain.doFilter(request, response);
      return;
    }

    // アクセスキーチェック
    if (true == NtssSecurityPoricy.doAccessKeyCheck(request, response, eventLoggerFactory)) {
      // 次のフィルタにフォワード
      chain.doFilter(request, response);
    } else {
      // 「not found」で返す
      HttpServletResponse res = (HttpServletResponse) response;
      res.sendError(HttpServletResponse.SC_NOT_FOUND);

    }
  }

  @Override
  public void destroy() {

  }
}
