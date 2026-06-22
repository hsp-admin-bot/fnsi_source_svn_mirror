package jp.co.nikkiso.ntss.alive_moni.config;

import java.io.IOException;
import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.http.HttpServletResponse;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.env.Environment;
import org.springframework.stereotype.Component;

import jp.co.nikkiso.ntss.core.config.NtssSecurityPoricy;
import jp.co.nikkiso.ntss.core.logger.EventLoggerFactory;


@Component
public class LoggingFilter implements Filter {

  private static Logger logger = LoggerFactory.getLogger(LoggingFilter.class);

  @Autowired
  private Environment environment;

  /**
   * ロガー生成コンポーネント
   */
  @Autowired
  private EventLoggerFactory eventLoggerFactory;

  @Override
  public void init(FilterConfig filterConfig) throws ServletException {
    logger.info("start filtering!!");
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
    logger.info("call NtssSecurityPoricy.doAccessKeyCheck!!");
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
