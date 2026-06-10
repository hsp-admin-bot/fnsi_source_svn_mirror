package jp.co.nikkiso.ntss.client_comm;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.web.servlet.support.SpringBootServletInitializer;
import org.springframework.scheduling.annotation.EnableScheduling;

import jp.co.nikkiso.ntss.core.constant.CoreConstant.NtssPackage;



@SpringBootApplication(scanBasePackages = {NtssPackage.CORE, NtssPackage.CLIENT_COMM})
@EnableScheduling   // 定期スケジュール処理のBean定義を有効化する
public class NtssApplication extends SpringBootServletInitializer{

  public static void main(String[] args) {
    SpringApplication.run(NtssApplication.class, args);
  }
}
