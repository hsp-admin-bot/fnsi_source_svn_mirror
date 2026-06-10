package jp.co.nikkiso.ntss.device_edge;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.web.servlet.support.SpringBootServletInitializer;
import org.springframework.scheduling.annotation.EnableScheduling;

import jp.co.nikkiso.ntss.core.constant.CoreConstant.NtssPackage;

@SpringBootApplication(scanBasePackages = { NtssPackage.CORE, NtssPackage.DEVICE_EDGE, NtssPackage.API })
@EnableScheduling
public class NtssDeviceEdgeApplication extends SpringBootServletInitializer {

  public static void main(String[] args) {
    SpringApplication.run(NtssDeviceEdgeApplication.class, args);
  }
}
