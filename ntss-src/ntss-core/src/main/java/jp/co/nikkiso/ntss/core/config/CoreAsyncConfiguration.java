package jp.co.nikkiso.ntss.core.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.annotation.EnableAsync;
import org.springframework.scheduling.concurrent.ThreadPoolTaskExecutor;

import java.util.concurrent.Executor;
import java.util.concurrent.ThreadPoolExecutor;


/**
 * @author 張
 * @Des
 * 非同期スレッドプール
 */
@Configuration
@EnableAsync
public class CoreAsyncConfiguration {

    @Bean("doSomethingExecutor")
    public Executor doSomethingExecutor() {
        ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
        // コアスレッド：スレッドプール作成時に初期化されるスレッド数
        executor.setCorePoolSize(Runtime.getRuntime().availableProcessors() + 1);
        // 最大スレッド数：プール内の最大スレッド数。コアスレッドを超えるスレッドは、バッファキューが一杯になった場合にのみ要求される。
        executor.setMaxPoolSize((Runtime.getRuntime().availableProcessors() + 1)*2);
        // バッファキュー：タスクの実行をバッファリングするためのキュー
        executor.setQueueCapacity(500);
        // スレッドアイドル時間60秒を許容：コアスレッドを超えるスレッドはアイドル時間に達すると破棄される
        executor.setKeepAliveSeconds(60);
        // スレッドプール名のプレフィックス: タスクが処理されているスレッドプールを簡単に見つけることができる。
        executor.setThreadNamePrefix("do-something-");
        // バッファキューが一杯になった場合の拒否ポリシー：呼び出し側のスレッド（通常はメインスレッド）で処理される
        executor.setRejectedExecutionHandler(new ThreadPoolExecutor.CallerRunsPolicy()); // modify shiyw 20230307 : DiscardPolicy --> CallerRunsPolicy
        executor.initialize();
        return executor;
    }

  @Bean("doUpdateLogExecutor")
  public Executor doUpdateLogExecutor() {
    ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
    // コアスレッド：スレッドプール作成時に初期化されるスレッド数
    executor.setCorePoolSize(Runtime.getRuntime().availableProcessors() + 1);
    // 最大スレッド数：プール内の最大スレッド数。コアスレッドを超えるスレッドは、バッファキューが一杯になった場合にのみ要求される。
    executor.setMaxPoolSize((Runtime.getRuntime().availableProcessors() + 1)*2);
    // バッファキュー：タスクの実行をバッファリングするためのキュー
    executor.setQueueCapacity(500);
    // スレッドアイドル時間60秒を許容：コアスレッドを超えるスレッドはアイドル時間に達すると破棄される
    executor.setKeepAliveSeconds(60);
    // スレッドプール名のプレフィックス: タスクが処理されているスレッドプールを簡単に見つけることができる。
    executor.setThreadNamePrefix("do-update-log-");
    // バッファキューが一杯になった場合の拒否ポリシー：呼び出し側のスレッド（通常はメインスレッド）で処理される
    executor.setRejectedExecutionHandler(new ThreadPoolExecutor.CallerRunsPolicy()); // modify shiyw 20230307 : DiscardPolicy --> CallerRunsPolicy
    executor.initialize();
    return executor;
  }

}
