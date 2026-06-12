package jp.co.nikkiso.ntss.web_api.config;

import java.io.IOException;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.env.Environment;
import org.springframework.stereotype.Component;

import jp.co.nikkiso.ntss.core.logger.LogLevel;
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
    log("start filtering!!", LogLevel.INFO);
  }

  @Override
  public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
      throws IOException, ServletException {

    HttpServletRequest sr = (HttpServletRequest) request;
    String remoteip = sr.getRemoteAddr();
    StringBuffer url = sr.getRequestURL();
    String path = sr.getServletPath().toLowerCase();
    log("API CALLED IP ：" + remoteip + ", URL :" + url, LogLevel.INFO);
    boolean berr = true;

    // セキュリティ対策実施フラグチェック
    if (berr == true && "false".equals(this.environment.getProperty("securityporicy.accesskeycheck"))) {
      log("NtssSecurityPoricy.doAccessKeyCheck-No Check!!", LogLevel.INFO);
      // 次のフィルタにフォワード
      berr = false;
    }

    // アクセスキーチェック
    if (berr == true && true == NtssSecurityPoricy.doAccessKeyCheck(request, response, eventLoggerFactory)) {
      log("call NtssSecurityPoricy.doAccessKeyCheck!!", LogLevel.INFO);
      // 次のフィルタにフォワード
      berr = false;
    }

    // 特定のURL判定(WebSocket接続用)
    if (path.equals(this.environment.getProperty("ntss.client-comm.websocket.path")) == true) {
      log("call WebSocket", LogLevel.INFO);
      // 次のフィルタにフォワード
      berr = false;
    }

    // セキュリティ判定
    if (berr == false) {
      // 次のフィルタにフォワード
      chain.doFilter(request, response);
    } else {
      // 「not found」で返す
      HttpServletResponse res = (HttpServletResponse) response;
      res.sendError(HttpServletResponse.SC_NOT_FOUND);
      log("NtssSecurityPoricy.doAccessKeyCheck-Return Not Found!!", LogLevel.ERROR);
    }
  }

  @Override
  public void destroy() {
    log("destroy!!", LogLevel.INFO);
  }

  private void log(String content, LogLevel level) {
//    EventLogMessage eventLogMessage = new EventLogMessage();
//    eventLogMessage.setLogMessage(content);
//    logService.log(level, eventLogMessage, null, SERVICE_NAME.FNSI, null);
  }
}
