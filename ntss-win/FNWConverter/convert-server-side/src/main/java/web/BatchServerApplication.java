package web;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.builder.SpringApplicationBuilder;
import org.springframework.boot.web.servlet.support.SpringBootServletInitializer;
import org.springframework.retry.annotation.EnableRetry;
import org.springframework.scheduling.annotation.EnableScheduling;


/**
 * Webサーバとして起動する際のアプリケーションのエントリポイント
 */
@EnableScheduling
@EnableRetry
@SpringBootApplication(scanBasePackages = {"web,batch,utils"})
public class BatchServerApplication extends SpringBootServletInitializer {

	//use to build war file.
	@Override
	   protected SpringApplicationBuilder configure(SpringApplicationBuilder application) {
	      return application.sources(BatchServerApplication.class);
	   }
	
	public static void main(final String[] args) {
		SpringApplication.run(BatchServerApplication.class);
	}

}
