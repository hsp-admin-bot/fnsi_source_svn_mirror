package jp.co.nikkiso.ntss.admin_web.service;


import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.api.service.RenderPoolService;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import javax.annotation.PostConstruct;

@Component
public class StartupConfig {

  private final RenderPoolService pool;

  @Autowired
  LogService logService;

  public StartupConfig(RenderPoolService pool) {
    this.pool = pool;
  }

  @PostConstruct
  public void initPool() {
    pool.init();
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("PlaywrightWorker pool init");
    logService.log(LogLevel.INFO, eventLogMessage,null,LoggingConstant.SERVICE_NAME.FNSI,null);
  }
}
