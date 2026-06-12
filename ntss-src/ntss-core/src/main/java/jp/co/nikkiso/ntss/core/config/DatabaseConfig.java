package jp.co.nikkiso.ntss.core.config;

import jp.co.nikkiso.ntss.core.constant.CoreConstant.DataSourceName;
import jp.co.nikkiso.ntss.core.constant.CoreConstant.TransactionManagerName;
import org.seasar.doma.boot.autoconfigure.DomaConfig;
import org.seasar.doma.boot.autoconfigure.DomaConfigBuilder;
import org.seasar.doma.boot.autoconfigure.DomaProperties;
import org.seasar.doma.jdbc.DuplicateColumnHandler;
import org.seasar.doma.jdbc.EntityListenerProvider;
import org.seasar.doma.jdbc.JdbcLogger;
import org.seasar.doma.jdbc.Naming;
import org.seasar.doma.jdbc.ScriptFileLoader;
import org.seasar.doma.jdbc.SqlBuilderSettings;
import org.seasar.doma.jdbc.SqlFileRepository;
import org.seasar.doma.jdbc.dialect.PostgresDialect;
import org.seasar.doma.jdbc.statistic.StatisticManager;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.boot.autoconfigure.EnableAutoConfiguration;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.boot.jdbc.DataSourceBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;
import org.springframework.data.transaction.ChainedTransactionManager;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.datasource.DataSourceTransactionManager;
import org.springframework.stereotype.Component;
import org.springframework.transaction.PlatformTransactionManager;

import javax.sql.DataSource;

/**
 * マルチデータベース設定クラス.
 */
@EnableAutoConfiguration
@Configuration
@Component
public class DatabaseConfig {

  /**
   * 認証DB用DataSourceを生成する.
   * @return 認証DB用DataSource
   */
//  @Bean(name = DataSourceName.AUTH, destroyMethod = "close")
  @Bean(name = DataSourceName.AUTH)
  @ConfigurationProperties("spring.datasource.auth")
  DataSource authDataSource() {
    return DataSourceBuilder.create().build();
  }

  @Bean
  JdbcTemplate jdbcTemplateAuth(@Qualifier(DataSourceName.AUTH) DataSource ds) {
    return new JdbcTemplate(ds);
  }

  /**
   * 医療情報DB用DataSourceを生成する.
   * @return 医療情報DB用DataSource
   */
//  @Bean(name = DataSourceName.DEFAULT, destroyMethod = "close")
  @Bean(name = DataSourceName.DEFAULT)
  @ConfigurationProperties("spring.datasource.default")
  @Primary
  DataSource defaultDataSource() {
    return DataSourceBuilder.create().build();
  }

  @Bean
  JdbcTemplate jdbcTemplate(@Qualifier(DataSourceName.DEFAULT) DataSource ds) {
    return new JdbcTemplate(ds);
  }

  /**
   * 個人情報DB用DataSourceを生成する.
   * @return 個人情報DB用DataSource
   */
//  @Bean(name = DataSourceName.PERSONAL, destroyMethod = "close")
  @Bean(name = DataSourceName.PERSONAL)
  @ConfigurationProperties("spring.datasource.personal")
  DataSource personalDataSource() {
    return DataSourceBuilder.create().build();
  }

  @Bean
  JdbcTemplate jdbcTemplatePersonal(@Qualifier(DataSourceName.PERSONAL) DataSource ds) {
    return new JdbcTemplate(ds);
  }

  /**
   * 認証DB用DomaConfigを生成する.
   * @param sqlFileRepository SqlFileRepository
   * @param naming Naming
   * @param provider EntityListenerProvider
   * @return 認証DB用DomaConfig
   */
  @Bean
  @AuthDb
  DomaConfig configAuthDb(
      SqlFileRepository sqlFileRepository, Naming naming, EntityListenerProvider provider, JdbcLogger jdbcLogger, DuplicateColumnHandler duplicateColumnHandler, ScriptFileLoader scriptFileLoader, SqlBuilderSettings sqlBuilderSettings, StatisticManager statisticManager) {
    DomaProperties domaProperties = new DomaProperties() {
      {
        setDataSourceName(DataSourceName.AUTH);
        setDialect(DialectType.POSTGRES);

      }
    };
    DomaConfigBuilder domaConfigBuilder = new DomaConfigBuilder(domaProperties)
        .dialect(new PostgresDialect())
        .jdbcLogger(jdbcLogger)
        .sqlFileRepository(sqlFileRepository)
        .naming(naming)
        .entityListenerProvider(provider)
        .duplicateColumnHandler(duplicateColumnHandler)
        .scriptFileLoader(scriptFileLoader)
        .sqlBuilderSettings(sqlBuilderSettings)
        .statisticManager(statisticManager)
        .dataSource(authDataSource());
    return domaConfigBuilder.build();
  }

  /**
   * 医療情報DB用DomaConfigを生成する.
   * @param sqlFileRepository SqlFileRepository
   * @param naming Naming
   * @param provider EntityListenerProvider
   * @return 医療情報DB用DomaConfig
   */
  @Bean
  @DefaultDb
  @Primary
  DomaConfig configDefaultDb(
      SqlFileRepository sqlFileRepository, Naming naming, EntityListenerProvider provider, JdbcLogger jdbcLogger, DuplicateColumnHandler duplicateColumnHandler, ScriptFileLoader scriptFileLoader, SqlBuilderSettings sqlBuilderSettings, StatisticManager statisticManager) {

    DomaProperties domaProperties = new DomaProperties() {
      {
        setDataSourceName(DataSourceName.DEFAULT);
        setDialect(DialectType.POSTGRES);

      }
    };
    DomaConfigBuilder domaConfigBuilder = new DomaConfigBuilder(domaProperties)
        .dialect(new PostgresDialect())
        .jdbcLogger(jdbcLogger)
        .sqlFileRepository(sqlFileRepository)
        .naming(naming)
        .entityListenerProvider(provider)
        .duplicateColumnHandler(duplicateColumnHandler)
        .scriptFileLoader(scriptFileLoader)
        .sqlBuilderSettings(sqlBuilderSettings)
        .statisticManager(statisticManager)
        .dataSource(defaultDataSource());
    return domaConfigBuilder.build();
  }

  /**
   * 個人情報DB用DomaConfigを生成する.
   * @param sqlFileRepository SqlFileRepository
   * @param naming Naming
   * @param provider EntityListenerProvider
   * @return 個人情報DB用DomaConfig
   */
  @Bean
  @PersonalDb
  DomaConfig configPersonalDb(
      SqlFileRepository sqlFileRepository, Naming naming, EntityListenerProvider provider, JdbcLogger jdbcLogger, DuplicateColumnHandler duplicateColumnHandler, ScriptFileLoader scriptFileLoader, SqlBuilderSettings sqlBuilderSettings, StatisticManager statisticManager) {

    DomaProperties domaProperties = new DomaProperties() {
      {
        setDataSourceName(DataSourceName.PERSONAL);
        setDialect(DialectType.POSTGRES);

      }
    };
    DomaConfigBuilder domaConfigBuilder = new DomaConfigBuilder(domaProperties)
        .dialect(new PostgresDialect())
        .jdbcLogger(jdbcLogger)
        .sqlFileRepository(sqlFileRepository)
        .naming(naming)
        .entityListenerProvider(provider)
        .duplicateColumnHandler(duplicateColumnHandler)
        .scriptFileLoader(scriptFileLoader)
        .sqlBuilderSettings(sqlBuilderSettings)
        .statisticManager(statisticManager)
        .dataSource(personalDataSource());
    return domaConfigBuilder.build();
  }

  /**
   * 認証DB用TransactionManagerを生成する.
   * @return 認証DB用TransactionManager
   */
  @Bean(TransactionManagerName.AUTH)
  public DataSourceTransactionManager authTransactionManager() {
    return new DataSourceTransactionManager(authDataSource());
  }

  /**
   * 医療情報DB用TransactionManagerを生成する.
   * @return 医療情報DB用TransactionManager
   */
  @Bean(TransactionManagerName.DEFAULT)
  @Primary
  public DataSourceTransactionManager defaultTransactionManager() {
    return new DataSourceTransactionManager(defaultDataSource());
  }

  /**
   * 個人情報DB用TransactionManagerを生成する.
   * @return 個人情報DB用TransactionManager
   */
  @Bean(TransactionManagerName.PERSONAL)
  public DataSourceTransactionManager personalTransactionManager() {
    return new DataSourceTransactionManager(personalDataSource());
  }

  /**
   * 全DB用TransactionManagerを生成する.
   * @return 全DB用TransactionManager
   */
  @Bean(TransactionManagerName.ALL)
  public ChainedTransactionManager allTransactionManager(
      @Qualifier(TransactionManagerName.AUTH) PlatformTransactionManager authTm,
      @Qualifier(TransactionManagerName.DEFAULT) PlatformTransactionManager defaultTm,
      @Qualifier(TransactionManagerName.PERSONAL) PlatformTransactionManager personalTm) {
    return new ChainedTransactionManager(authTm, defaultTm, personalTm);
  }
}
