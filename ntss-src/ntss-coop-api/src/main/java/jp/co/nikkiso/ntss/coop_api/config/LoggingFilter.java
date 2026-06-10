package jp.co.nikkiso.ntss.coop_api.config;

import jp.co.nikkiso.ntss.core.dao.MstIfEdgeDao;
import jp.co.nikkiso.ntss.core.entity.MstIfEdge;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.env.Environment;
import org.springframework.stereotype.Component;
import org.springframework.util.ObjectUtils;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@Component
public class LoggingFilter implements Filter {
  private final String ACCESS_KEY = "SSECCAYEK";
  private final String WEB_KEY_VALUE = "NTSS-NKK-ESM-TDC-YSK";
  private final String NODE_KEY_VALUE = "NTSS-NKK-ESM-TDC-YSK-NODE";

  @Autowired
  private Environment environment;

  @Autowired
  private MstIfEdgeDao mstIfEdgeDao;

  @Override
  public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
          throws IOException, ServletException {
    HttpServletRequest sr = (HttpServletRequest)request;
    String path = sr.getServletPath().toLowerCase();

    boolean berr = true;

    // websocket接続用
    if ("websocket".equals(sr.getHeader("upgrade"))) {
      berr = false;
    }

    //セキュリティ対策実施フラグチェック
    if (berr && "false".equals(this.environment.getProperty("securityporicy.accesskeycheck"))) {
      //次のフィルタにフォワード
      berr = false;
    }

    //アクセスキーチェック
    if (berr && doHeaderInfoCheck(sr)) {
      //次のフィルタにフォワード
      berr = false;
    }

    //　特定のURL判定
    if( path.equals("/") == true || path.equals("/index.html") == true || path.startsWith("/static/") == true) {
      //次のフィルタにフォワード
      berr = false;
    }

    if (!berr) {
      chain.doFilter(request, response);
    } else {
      //「not found」で返す
      HttpServletResponse res = (HttpServletResponse)response;
      res.sendError(HttpServletResponse.SC_NOT_FOUND);
    }
  }

  /**
   * アクセスキーチェック関数
   * @param request
   * @return
   */
  public boolean doHeaderInfoCheck(HttpServletRequest request) {

    String headerStr = request.getHeader(ACCESS_KEY);
    if (headerStr != null) {
      if ((WEB_KEY_VALUE).equals(headerStr)) {
        return true;
      } else if ((NODE_KEY_VALUE).equals(headerStr)) {
        String facilityCd = request.getHeader("FACILITYCD");
        String serialNo = request.getHeader("SERIALNO");
        if (ObjectUtils.isEmpty(facilityCd) || ObjectUtils.isEmpty(serialNo)) {
          return false;
        } else {
          MstIfEdge mstIfEdge = mstIfEdgeDao.selectByFacilityCdSerialNo(facilityCd, serialNo);
          if (mstIfEdge == null) {
            return false;
          } else {
            return true;
          }
        }
      } else {
        return false;
      }
    } else {
      return false;
    }
  }
}
