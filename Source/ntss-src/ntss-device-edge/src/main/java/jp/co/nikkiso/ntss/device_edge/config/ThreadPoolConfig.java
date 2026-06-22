package jp.co.nikkiso.ntss.device_edge.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

//9480 排液済，検査計算 gjn start
@Configuration
public class ThreadPoolConfig {
  @Bean
  public ExecutorService crawlExecutorPool(){
    return Executors.newSingleThreadExecutor();
  }
}
//9480 排液済，検査計算 gjn end
