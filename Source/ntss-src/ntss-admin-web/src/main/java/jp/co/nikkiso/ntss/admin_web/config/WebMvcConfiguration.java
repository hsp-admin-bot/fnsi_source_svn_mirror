package jp.co.nikkiso.ntss.admin_web.config;

import java.util.List;

import jp.co.nikkiso.ntss.admin_web.DownloadProperties;
import jp.co.nikkiso.ntss.admin_web.service.utils.MasterCacheHandlerInterceptor;
import jp.co.nikkiso.ntss.admin_web.service.utils.IndHistoryCleanupInterceptor;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.CacheControl;
import org.springframework.http.converter.HttpMessageConverter;
import org.springframework.http.converter.HttpMessageConverters;
import org.springframework.http.converter.StringHttpMessageConverter;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class WebMvcConfiguration implements WebMvcConfigurer {

  private final DownloadProperties downloadProperties;

  @Autowired
  private LogService logService;

  @Autowired
  private IndHistoryCleanupInterceptor indHistoryCleanupInterceptor;

  public WebMvcConfiguration(DownloadProperties downloadProperties) {
    this.downloadProperties = downloadProperties;
  }

  @Override
  public void configureMessageConverters(HttpMessageConverters.ServerBuilder builder) {
    builder.configureMessageConvertersList(converters -> {
      for (int i = 0; i < converters.size(); i++) {
        HttpMessageConverter<?> converter = converters.get(i);
        if (converter instanceof StringHttpMessageConverter) {
          converters.remove(i);
          converters.add(0, converter);
          break;
        }
      }
    });
  }

  @Override
  public void addResourceHandlers(ResourceHandlerRegistry registry) {
    registry.addResourceHandler("/*.msi")
            .addResourceLocations("file:" + downloadProperties.getApplicationDl().getFileLocation() + "/")
            .setCacheControl(CacheControl.noCache());
  }

  @Override
  public void addInterceptors(InterceptorRegistry registry) {
    try {
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("Adding interceptors...");
        logService.log(LogLevel.INFO, eventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
    } catch (Exception e) {
        // ログ出力に失敗した場合は無視
    }

    registry.addInterceptor(new MasterCacheHandlerInterceptor());
    registry.addInterceptor(indHistoryCleanupInterceptor);

    try {
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("IndHistoryCleanupInterceptor registered successfully");
        logService.log(LogLevel.INFO, eventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
    } catch (Exception e) {
        // ログ出力に失敗した場合は無視
    }
  } 
}