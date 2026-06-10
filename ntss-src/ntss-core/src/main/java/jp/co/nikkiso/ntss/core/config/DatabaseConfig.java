package jp.co.nikkiso.ntss.core.config;

import jp.co.nikkiso.ntss.core.constant.CoreConstant.DataSourceName;
import jp.co.nikkiso.ntss.core.constant.CoreConstant.TransactionManagerName;
import org.seasar.doma.boot.autoconfigure.DomaConfig;
import org.seasar.doma.boot.autoconfigure.DomaConfigBuilder;
import org.seasar.doma.boot.autoconfigure.DomaProperties;
import org.seasar.doma.jdbc.EntityListenerProvider;
import org.seasar.doma.jdbc.Naming;
import org.seasar.doma.jdbc.SqlFileRepository;
import org.seasar.doma.jdbc.dialect.PostgresDialect;
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
      SqlFileRepository sqlFileRepository, Naming naming, EntityListenerProvider provider) {
    DomaConfigBuilder domaConfigBuilder = new DomaConfigBuilder()
        .dialect(new PostgresDialect())
        .sqlFileRepository(sqlFileRepository)
        .naming(naming)
        .entityListenerProvider(provider)
        .dataSource(authDataSource());

    DomaProperties domaProperties = new DomaProperties() {
      {
        setDataSourceName(DataSourceName.AUTH);
        setDialect(DialectType.POSTGRES);

      }
    };
    return new DomaConfig(domaConfigBuilder, domaProperties);
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
      SqlFileRepository sqlFileRepository, Naming naming, EntityListenerProvider provider) {

    DomaConfigBuilder domaConfigBuilder = new DomaConfigBuilder()
        .dialect(new PostgresDialect())
        .sqlFileRepository(sqlFileRepository)
        .naming(naming)
        .entityListenerProvider(provider)
        .dataSource(defaultDataSource());

    DomaProperties domaProperties = new DomaProperties() {
      {
        setDataSourceName(DataSourceName.DEFAULT);
        setDialect(DialectType.POSTGRES);

      }
    };
    return new DomaConfig(domaConfigBuilder, domaProperties);
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
      SqlFileRepository sqlFileRepository, Naming naming, EntityListenerProvider provider) {

    DomaConfigBuilder domaConfigBuilder = new DomaConfigBuilder()
        .dialect(new PostgresDialect())
        .sqlFileRepository(sqlFileRepository)
        .naming(naming)
        .entityListenerProvider(provider)
        .dataSource(personalDataSource());

    DomaProperties domaProperties = new DomaProperties() {
      {
        setDataSourceName(DataSourceName.PERSONAL);
        setDialect(DialectType.POSTGRES);

      }
    };
    return new DomaConfig(domaConfigBuilder, domaProperties);
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
