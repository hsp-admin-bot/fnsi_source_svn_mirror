package com.fnsi.cloudconverter.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.concurrent.ThreadPoolTaskExecutor;

import java.util.concurrent.ThreadPoolExecutor.CallerRunsPolicy;

@Configuration
public class ThreadPoolConfig {

    @Bean("refreshJsonExecutor")
    public ThreadPoolTaskExecutor fkRefreshExecutor() {
        ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
        int cpu = Runtime.getRuntime().availableProcessors();
        executor.setCorePoolSize(cpu * 4);
        executor.setMaxPoolSize(cpu * 8);
        executor.setQueueCapacity(50);
        executor.setKeepAliveSeconds(7200);
        executor.setAllowCoreThreadTimeOut(false);
        executor.setThreadNamePrefix("fk-refresh-");
        executor.setRejectedExecutionHandler(new CallerRunsPolicy());
        executor.initialize();
        return executor;
    }
}
