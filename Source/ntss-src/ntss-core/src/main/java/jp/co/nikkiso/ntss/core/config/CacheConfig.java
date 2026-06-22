package jp.co.nikkiso.ntss.core.config;
// add 10601 eventLog共通処理 gjn start
import org.springframework.cache.CacheManager;
import org.springframework.cache.annotation.EnableCaching;
import org.springframework.cache.concurrent.ConcurrentMapCache;
import org.springframework.cache.support.SimpleCacheManager;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.Arrays;

/**
 * キャッシュマネージャの構成
 */
@Configuration
@EnableCaching
public class CacheConfig {

  @Bean
  public CacheManager cacheManager() {
    SimpleCacheManager cacheManager = new SimpleCacheManager();
    cacheManager.setCaches(Arrays.asList(new ConcurrentMapCache("tableFlagCache")));
    return cacheManager;
  }

}
// add 10601 eventLog共通処理 gjn end
