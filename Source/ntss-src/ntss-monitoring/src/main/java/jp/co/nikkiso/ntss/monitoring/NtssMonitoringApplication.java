package jp.co.nikkiso.ntss.monitoring;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.web.servlet.support.SpringBootServletInitializer;

import jp.co.nikkiso.ntss.core.constant.CoreConstant.NtssPackage;

@SpringBootApplication(scanBasePackages = {NtssPackage.CORE, NtssPackage.MONITORING})
public class NtssMonitoringApplication extends SpringBootServletInitializer{

  public static void main(String[] args) {
    SpringApplication.run(NtssMonitoringApplication.class, args);
  }
}
