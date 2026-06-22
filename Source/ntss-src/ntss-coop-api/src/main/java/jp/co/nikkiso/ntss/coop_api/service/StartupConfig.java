package jp.co.nikkiso.ntss.coop_api.service;


import jp.co.nikkiso.ntss.api.service.LogService;
import jp.co.nikkiso.ntss.api.service.RenderPoolService;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import jakarta.annotation.PostConstruct;

@Component
public class StartupConfig {

  @Autowired
  LogService logService;

  private final RenderPoolService pool;

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
