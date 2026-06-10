package jp.co.nikkiso.ntss.web_api;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.builder.SpringApplicationBuilder;
import org.springframework.boot.web.servlet.support.SpringBootServletInitializer;
import org.springframework.scheduling.annotation.EnableAsync;
import org.springframework.scheduling.annotation.EnableScheduling;
import jp.co.nikkiso.ntss.core.constant.CoreConstant.NtssPackage;

// mod 11454 時間外加算自動処理が機能していない zkm start
//@SpringBootApplication(scanBasePackages = { NtssPackage.CORE, NtssPackage.WEB_API })
@SpringBootApplication(scanBasePackages = { NtssPackage.CORE, NtssPackage.WEB_API, NtssPackage.API })
// mod 11454 時間外加算自動処理が機能していない zkm end
@EnableScheduling
@EnableAsync
public class NtssWebApiApplication extends SpringBootServletInitializer {

  public static void main(String[] args) {
    SpringApplication.run(NtssWebApiApplication.class, args);
  }

  @Override
  protected SpringApplicationBuilder configure(SpringApplicationBuilder application) {
    return application.sources(NtssWebApiApplication.class);
  }
}
