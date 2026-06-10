package jp.co.nikkiso.ntss.coop_api;

import java.util.concurrent.Future;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.builder.SpringApplicationBuilder;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.boot.web.servlet.support.SpringBootServletInitializer;
import org.springframework.context.event.ContextClosedEvent;
import org.springframework.context.event.EventListener;
import org.springframework.scheduling.annotation.EnableAsync;

import jp.co.nikkiso.ntss.coop_api.service.AsyncService;
import jp.co.nikkiso.ntss.core.constant.CoreConstant.NtssPackage;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication(scanBasePackages = { NtssPackage.CORE, NtssPackage.COOP_API, NtssPackage.API })
@EnableAsync
@EnableScheduling
public class NtssCoopApiApplication extends SpringBootServletInitializer {

  @Autowired
  private AsyncService asyncService;

  private Future<Integer> checkTask;

  public static void main(String[] args) {
    SpringApplication.run(NtssCoopApiApplication.class, args);
  }

  @Override
  protected SpringApplicationBuilder configure(SpringApplicationBuilder application) {
    return application.sources(NtssCoopApiApplication.class);
  }

  @EventListener(ApplicationReadyEvent.class)
  public void onStartup() {
    // 起動時に、起動中ログを出力する定期実行処理を発火する
    checkTask = asyncService.operationCheckLog();
  }

  @EventListener(ContextClosedEvent.class)
  public void onShutdown() {
    // 停止時に、起動中ログを出力する定期実行処理を停止する
    asyncService.stopLog();
    checkTask.cancel(true);
  }
}
