package jp.co.nikkiso.ntss.coop_api.config;

import jp.co.nikkiso.ntss.coop_api.aspect.LogAspector;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * At the end of the request, clear the FacilityCdTL in ThreadLocal for current Thread
 */
@Component
public class LogAspectorFacilityClearInterceptor implements HandlerInterceptor {

  @Override
  public void afterCompletion (HttpServletRequest request, HttpServletResponse response, Object Handler, Exception ex) throws Exception {
    LogAspector.clearFacilityCdTL();
  }
}