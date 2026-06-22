package jp.co.nikkiso.ntss.admin_web;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.builder.SpringApplicationBuilder;

import jp.co.nikkiso.ntss.core.constant.CoreConstant.NtssPackage;
import org.springframework.boot.web.servlet.support.SpringBootServletInitializer;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication(scanBasePackages = {NtssPackage.CORE, NtssPackage.ADMIN_WEB, NtssPackage.API})
@EnableScheduling
public class NtssAdminWebApplication extends SpringBootServletInitializer {

  public static void main(String[] args) {
    SpringApplication.run(NtssAdminWebApplication.class, args);
  }

  @Override
  protected SpringApplicationBuilder configure(SpringApplicationBuilder application) {
      return application.sources(NtssAdminWebApplication.class);
  }
}
