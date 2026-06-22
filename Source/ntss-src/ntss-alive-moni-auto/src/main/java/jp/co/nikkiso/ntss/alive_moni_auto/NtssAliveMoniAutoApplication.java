package jp.co.nikkiso.ntss.alive_moni_auto;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.builder.SpringApplicationBuilder;
import org.springframework.boot.web.servlet.support.SpringBootServletInitializer;
import org.springframework.scheduling.annotation.EnableAsync;
import org.springframework.scheduling.annotation.EnableScheduling;

import jp.co.nikkiso.ntss.core.constant.CoreConstant.NtssPackage;


/**
 * 死活監視のアプリケーションクラス.
 */
@SpringBootApplication(scanBasePackages = { NtssPackage.CORE, NtssPackage.ALIVE_MONI_AUTO })
@EnableAsync
@EnableScheduling
public class NtssAliveMoniAutoApplication extends SpringBootServletInitializer {
  public static void main(String[] args) {
    SpringApplication.run(NtssAliveMoniAutoApplication.class, args);
  }

  @Override
  protected SpringApplicationBuilder configure(SpringApplicationBuilder application) {
    return application.sources(NtssAliveMoniAutoApplication.class);
  }
}
