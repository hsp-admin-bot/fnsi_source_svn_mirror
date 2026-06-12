package jp.co.nikkiso.ntss.certificate_management;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.builder.SpringApplicationBuilder;
import org.springframework.boot.jackson.autoconfigure.JacksonAutoConfiguration;
import org.springframework.boot.web.servlet.support.SpringBootServletInitializer;

import jp.co.nikkiso.ntss.core.constant.CoreConstant.NtssPackage;

// Boot 4: application.yml の spring.jackson.serialization は Jackson 3 でバインド不可のため自動構成を除外（日付出力方針は Jackson 3 デフォルトで従来の false と同義）
@SpringBootApplication(
    scanBasePackages = {NtssPackage.CORE, NtssPackage.CERTIFICATE_MANAGEMENT},
    exclude = JacksonAutoConfiguration.class)
public class NtssCertificateManagementApplication extends SpringBootServletInitializer{

	public static void main(String[] args) {
		SpringApplication.run(NtssCertificateManagementApplication.class, args);
	}

	 @Override
	  protected SpringApplicationBuilder configure(SpringApplicationBuilder application) {
	      return application.sources(NtssCertificateManagementApplication.class);
	  }
}
