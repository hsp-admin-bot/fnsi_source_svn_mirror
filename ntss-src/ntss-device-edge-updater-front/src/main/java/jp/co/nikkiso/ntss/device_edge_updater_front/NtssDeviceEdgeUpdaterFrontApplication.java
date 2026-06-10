package jp.co.nikkiso.ntss.device_edge_updater_front;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.web.servlet.support.SpringBootServletInitializer;

import jp.co.nikkiso.ntss.core.constant.CoreConstant.NtssPackage;

@SpringBootApplication(scanBasePackages = {NtssPackage.CORE, NtssPackage.DEVICE_EDGE_UPDATER_F})
public class NtssDeviceEdgeUpdaterFrontApplication extends SpringBootServletInitializer{

  public static void main(String[] args) {
    SpringApplication.run(NtssDeviceEdgeUpdaterFrontApplication.class, args);
  }
}
