package jp.co.nikkiso.ntss.data_gathering_auto;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.builder.SpringApplicationBuilder;
import org.springframework.boot.web.servlet.support.SpringBootServletInitializer;
import org.springframework.scheduling.annotation.EnableAsync;
import org.springframework.scheduling.annotation.EnableScheduling;

import jp.co.nikkiso.ntss.core.constant.CoreConstant.NtssPackage;


/**
 * データ収集のアプリケーションクラス.
 */
@SpringBootApplication(scanBasePackages = { NtssPackage.CORE, NtssPackage.DATA_GATHERING_AUTO })
@EnableAsync
@EnableScheduling
public class NtssDataGatheringAutoApplication extends SpringBootServletInitializer {
  public static void main(String[] args) {
    SpringApplication.run(NtssDataGatheringAutoApplication.class, args);
  }

  @Override
  protected SpringApplicationBuilder configure(SpringApplicationBuilder application) {
    return application.sources(NtssDataGatheringAutoApplication.class);
  }
}
