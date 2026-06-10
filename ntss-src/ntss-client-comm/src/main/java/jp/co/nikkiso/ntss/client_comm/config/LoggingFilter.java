package jp.co.nikkiso.ntss.client_comm.config;

import java.io.IOException;
import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

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

        HttpServletRequest sr = (HttpServletRequest)request ;
        String remoteip = sr.getRemoteAddr();
        StringBuffer url = sr.getRequestURL();
        String path = sr.getServletPath().toLowerCase();
        logger.info("API CALLED IP ：" + remoteip + ", URL :" + url + ", SERVLET PATH :" + path );

        boolean berr = true;

        //セキュリティ対策実施フラグチェック
        if (berr == true && "false".equals(this.environment.getProperty("securityporicy.accesskeycheck"))) {
            logger.info("NtssSecurityPoricy.doAccessKeyCheck-No Check!!");
            //次のフィルタにフォワード
            berr = false;
        }

        //アクセスキーチェック
        if (berr == true && true == NtssSecurityPoricy.doAccessKeyCheck(request, response, eventLoggerFactory)) {
            logger.info("call NtssSecurityPoricy.doAccessKeyCheck!!");
            //次のフィルタにフォワード
            berr = false;
        }

        // 特定のURL判定(WebSocket接続用)
        if(berr == true && path.equals(this.environment.getProperty("ntss.client-comm.websocket.path")) == true ) {
          logger.info("call WebSocket");

          //次のフィルタにフォワード
          berr = false;
        }

        // 特定のURL判定(ヘルスチェック用)
        if(berr == true && path.equals("/actuator/health") == true ) {
          logger.info("call HealthCheck");

          //次のフィルタにフォワード
          berr = false;
        }

        // セキュリティ判定
        if( berr == false ) {
            //次のフィルタにフォワード
            chain.doFilter(request, response);
        }
        else {
            //「not found」で返す
            HttpServletResponse res = (HttpServletResponse)response;
            res.sendError(HttpServletResponse.SC_NOT_FOUND);
            logger.error("NtssSecurityPoricy.doAccessKeyCheck-Return Not Found!!");
        }
    }

    @Override
    public void destroy() {
        logger.info("destroy!!");
    }
}




