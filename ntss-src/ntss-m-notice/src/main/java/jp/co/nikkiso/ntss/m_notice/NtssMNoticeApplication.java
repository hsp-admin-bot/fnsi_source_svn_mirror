package jp.co.nikkiso.ntss.m_notice;

import java.util.concurrent.Future;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.builder.SpringApplicationBuilder;
import org.springframework.boot.context.event.ApplicationReadyEvent;

import jp.co.nikkiso.ntss.core.constant.CoreConstant.NtssPackage;
import jp.co.nikkiso.ntss.m_notice.service.AsyncService;

import org.springframework.boot.web.servlet.support.SpringBootServletInitializer;
import org.springframework.context.event.ContextClosedEvent;
import org.springframework.context.event.EventListener;
import org.springframework.scheduling.annotation.EnableAsync;
import org.springframework.scheduling.annotation.EnableScheduling;

/**
 * NTSS緊急発報のアプリケーションクラス.
 */
@SpringBootApplication(scanBasePackages = {NtssPackage.CORE, NtssPackage.M_NOTICE})
@EnableAsync
@EnableScheduling
public class NtssMNoticeApplication extends SpringBootServletInitializer {

  @Autowired
  private AsyncService asyncService;

  private Future<Integer> checkTask;

  public static void main(String[] args) {
    SpringApplication.run(NtssMNoticeApplication.class, args);
  }

  @Override
  protected SpringApplicationBuilder configure(SpringApplicationBuilder application) {
      return application.sources(NtssMNoticeApplication.class);
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
