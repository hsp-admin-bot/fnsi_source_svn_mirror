package jp.co.nikkiso.ntss.admin_web.service.utils;

import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@Component
public class MasterCacheHandlerInterceptor implements HandlerInterceptor {

  @Override
  public void afterCompletion (HttpServletRequest request, HttpServletResponse response, Object Handler, Exception ex) throws Exception {
    /**
     * At the end of the request, clear the MasterCache in ThreadLocal for current Thread
     */
    MasterCacheHandler.clearCache();
  }
}