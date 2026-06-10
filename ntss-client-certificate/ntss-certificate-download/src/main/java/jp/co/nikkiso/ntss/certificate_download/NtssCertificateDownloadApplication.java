package jp.co.nikkiso.ntss.certificate_download;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.builder.SpringApplicationBuilder;
import org.springframework.boot.web.servlet.support.SpringBootServletInitializer;

import jp.co.nikkiso.ntss.core.constant.CoreConstant.NtssPackage;

@SpringBootApplication(scanBasePackages = {NtssPackage.CORE, NtssPackage.CERTIFICATE_DOWNLOAD})
public class NtssCertificateDownloadApplication extends SpringBootServletInitializer{

	public static void main(String[] args) {
		SpringApplication.run(NtssCertificateDownloadApplication.class, args);
	}

	 @Override
	  protected SpringApplicationBuilder configure(SpringApplicationBuilder application) {
	      return application.sources(NtssCertificateDownloadApplication.class);
	  }
}
