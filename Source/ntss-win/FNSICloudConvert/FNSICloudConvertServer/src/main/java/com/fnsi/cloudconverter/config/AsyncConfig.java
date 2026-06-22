package com.fnsi.cloudconverter.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.annotation.AsyncConfigurer;
import org.springframework.scheduling.concurrent.ThreadPoolTaskExecutor;

import java.util.concurrent.Executor;

/**
 * 非同期 Task 実行スレッドプール設定
 * Migration Task の非同期実行に使用
 */
@Configuration
public class AsyncConfig implements AsyncConfigurer {

    @Bean(name = "migrationTaskExecutor")
    public Executor migrationTaskExecutor() {
        ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
        executor.setCorePoolSize(8);
        executor.setMaxPoolSize(16);
        executor.setQueueCapacity(100);
        executor.setThreadNamePrefix("migration-task-");
        executor.setWaitForTasksToCompleteOnShutdown(true);
        executor.setAwaitTerminationSeconds(60);
        executor.initialize();
        return executor;
    }

    @Override
    public Executor getAsyncExecutor() {
        return migrationTaskExecutor();
    }
}
