package jp.co.nikkiso.ntss.alive_moni;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.builder.SpringApplicationBuilder;
import org.springframework.boot.web.servlet.support.SpringBootServletInitializer;
import org.springframework.scheduling.annotation.EnableScheduling;

import jp.co.nikkiso.ntss.core.constant.CoreConstant.NtssPackage;


@SpringBootApplication(scanBasePackages = { NtssPackage.CORE, NtssPackage.ALIVE_MONI })
@EnableScheduling
public class NtssAliveMoniApplication extends SpringBootServletInitializer {
  public static void main(String[] args) {
    SpringApplication.run(NtssAliveMoniApplication.class, args);
  }

  @Override
  protected SpringApplicationBuilder configure(SpringApplicationBuilder application) {
    return application.sources(NtssAliveMoniApplication.class);
  }
}
