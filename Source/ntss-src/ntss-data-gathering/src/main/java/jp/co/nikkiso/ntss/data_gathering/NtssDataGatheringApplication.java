package jp.co.nikkiso.ntss.data_gathering;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.builder.SpringApplicationBuilder;
import org.springframework.boot.web.servlet.support.SpringBootServletInitializer;
import org.springframework.scheduling.annotation.EnableScheduling;

import jp.co.nikkiso.ntss.core.constant.CoreConstant.NtssPackage;

/**
 * データ収集App起動
 * 
 */
@SpringBootApplication(scanBasePackages = { NtssPackage.CORE, NtssPackage.DATA_GATHERING })
@EnableScheduling
public class NtssDataGatheringApplication extends SpringBootServletInitializer {
  public static void main(String[] args) {
    SpringApplication.run(NtssDataGatheringApplication.class, args);
  }

  @Override
  protected SpringApplicationBuilder configure(SpringApplicationBuilder application) {
    return application.sources(NtssDataGatheringApplication.class);
  }
}
