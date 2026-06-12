package jp.co.nikkiso.ntss.device_edge.config;
import com.mongodb.MongoClientSettings;
import com.mongodb.client.MongoClient;
import com.mongodb.connection.ServerMonitoringMode;
import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import jp.co.nikkiso.ntss.core.utils.MongoHealthCheckService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.ObjectProvider;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.autoconfigure.condition.ConditionalOnBean;
import org.springframework.boot.mongodb.autoconfigure.MongoClientFactory;
import org.springframework.boot.mongodb.autoconfigure.MongoClientSettingsBuilderCustomizer;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;
import org.springframework.scheduling.annotation.Scheduled;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Proxy;
import java.util.stream.Collectors;
import static java.util.concurrent.TimeUnit.MILLISECONDS;
import static java.util.concurrent.TimeUnit.SECONDS;

@Configuration
public class MongoDbConfig {

  private static final Logger log = LoggerFactory.getLogger(MongoDbConfig.class);

  @Autowired
  MongoHealthCheckService mongoHealthCheckService;

  @Bean
  @Primary
  @ConditionalOnBean(MongoClientSettings.class)
  public MongoClient mongo(ObjectProvider<MongoClientSettingsBuilderCustomizer> builderCustomizers,
                           MongoClientSettings settings) {
    MongoClientSettings mongoClientSettings = MongoClientSettings
      .builder(settings)
      .applyToSocketSettings(builder -> {
        builder.connectTimeout(CoreConstant.MongoDbConfig.CONNECT_TIME_OUT, MILLISECONDS);
        builder.readTimeout(CoreConstant.MongoDbConfig.CONNECT_TIME_OUT, MILLISECONDS);
      })
      .applyToClusterSettings(builder -> builder.serverSelectionTimeout(CoreConstant.MongoDbConfig.CONNECT_TIME_OUT, MILLISECONDS))
      .applyToServerSettings(builder -> builder
          .serverMonitoringMode(ServerMonitoringMode.POLL)
          .heartbeatFrequency(10, SECONDS))
      .build();
    MongoClient realClient = new MongoClientFactory(builderCustomizers.orderedStream().collect(Collectors.toList()))
      .createMongoClient(mongoClientSettings);
    return (MongoClient) Proxy.newProxyInstance(
        MongoClient.class.getClassLoader(), new Class<?>[]{MongoClient.class},
        (proxy, method, args) -> {
          if ("close".equals(method.getName())) {
            try { realClient.close(); } catch (Throwable t) { log.debug("Suppressed on MongoClient.close(): {}", t.getMessage()); }
            return null;
          }
          try { return method.invoke(realClient, args); } catch (InvocationTargetException e) { throw e.getCause(); }
        });
  }

//add 10248 mongodbの消息を設定して健康状態を定期的に検査する gjn start
  /**
   * mongodb健康診断は、nongodbサービスが利用できない場合にのみ40秒ごとに測定されます
   */
  @Scheduled(fixedRate = 1000*40)
  public void checkMongoHealth() {
    if (!MongoHealthCheckService.getMongoDBConnected()) {
      mongoHealthCheckService.outLogToSystem("mongodbアクセス失敗！");
      mongoHealthCheckService.checkMongoHealth();
    }
  }
  //add 10248 mongodbの消息を設定して健康状態を定期的に検査する gjn end
}
