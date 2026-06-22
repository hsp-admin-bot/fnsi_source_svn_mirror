package jp.co.nikkiso.ntss.coop_api.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class WebMvcConfiguration implements WebMvcConfigurer {
  /*  @Autowired private DeleteDumpFileHandlerInterceptor deleteDumpFileHandlerInterceptor;*/

  @Override
  public void addInterceptors(InterceptorRegistry registry) {
    /* /journal/delivery の後処理でファイル削除を行う
     * registry.addInterceptor(deleteDumpFileHandlerInterceptor)
     *            .addPathPatterns("/journal/delivery");
     */
    // At the end of the request, clear the FacilityCdTL in ThreadLocal for current Thread
    registry.addInterceptor(new LogAspectorFacilityClearInterceptor());
  }
}
