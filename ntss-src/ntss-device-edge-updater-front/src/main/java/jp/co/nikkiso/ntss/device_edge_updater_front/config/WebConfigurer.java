package jp.co.nikkiso.ntss.device_edge_updater_front.config;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.web.server.MimeMappings;
import org.springframework.boot.web.server.WebServerFactoryCustomizer;
import org.springframework.boot.web.servlet.ServletContextInitializer;
import org.springframework.boot.web.servlet.server.ConfigurableServletWebServerFactory;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.env.Environment;

import java.io.File;
import java.nio.file.Paths;
import jp.co.nikkiso.ntss.device_edge_updater_front.service.LogService;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;

/**
 * Configuration of web application with Servlet 3.0 APIs.
 */
@Configuration
public class WebConfigurer implements ServletContextInitializer, WebServerFactoryCustomizer<ConfigurableServletWebServerFactory> {

  @Autowired
  private LogService logService;

  private final Environment env;

  public WebConfigurer(Environment env) {
      this.env = env;
  }

  @Override
  public void onStartup(ServletContext servletContext) throws ServletException {
    EventLogMessage eventLogMessage = new EventLogMessage();
      if (env.getActiveProfiles().length != 0) {
          eventLogMessage.setLogMessage("Web application configuration, using profiles: {}");
          logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
      }
      eventLogMessage.setLogMessage("Web application fully configured");
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
  }

  /**
   * Customize the Servlet engine: Mime types, the document root, the cache.
   */
  @Override
  public void customize(ConfigurableServletWebServerFactory container) {
      MimeMappings mappings = new MimeMappings(MimeMappings.DEFAULT);
      // IE issue, see https://github.com/jhipster/generator-jhipster/pull/711
      mappings.add("html", "text/html;charset=utf-8");
      // CloudFoundry issue, see https://github.com/cloudfoundry/gorouter/issues/64
      mappings.add("json", "text/html;charset=utf-8");
      container.setMimeMappings(mappings);
      // When running in an IDE or with ./gradlew bootRun, set location of the static web assets.
      setLocationForStaticAssets(container);
  }

  private void setLocationForStaticAssets(ConfigurableServletWebServerFactory container) {
      File root;
      String prefixPath = resolvePathPrefix();
      root = new File(prefixPath + "build/www/");
      if (root.exists() && root.isDirectory()) {
          container.setDocumentRoot(root);
      }
  }

  /**
   *  Resolve path prefix to static resources.
   */
  private String resolvePathPrefix() {
      String fullExecutablePath = this.getClass().getResource("").getPath();
      String rootPath = Paths.get(".").toUri().normalize().getPath();
      String extractedPath = fullExecutablePath.replace(rootPath, "");
      int extractionEndIndex = extractedPath.indexOf("build/");
      if(extractionEndIndex <= 0) {
          return "";
      }
      return extractedPath.substring(0, extractionEndIndex);
  }

}
