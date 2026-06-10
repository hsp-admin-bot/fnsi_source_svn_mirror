package jp.co.nikkiso.ntss.certificate_management.config;

import jp.co.nikkiso.ntss.core.config.CertificateDb;
import jp.co.nikkiso.ntss.core.config.DefaultDb;
import jp.co.nikkiso.ntss.core.constant.CoreConstant.DataSourceName;
import jp.co.nikkiso.ntss.core.constant.CoreConstant.TransactionManagerName;
import org.seasar.doma.boot.autoconfigure.DomaConfig;
import org.seasar.doma.boot.autoconfigure.DomaConfigBuilder;
import org.seasar.doma.boot.autoconfigure.DomaProperties;
import org.seasar.doma.jdbc.EntityListenerProvider;
import org.seasar.doma.jdbc.Naming;
import org.seasar.doma.jdbc.SqlFileRepository;
import org.seasar.doma.jdbc.dialect.PostgresDialect;
import org.springframework.boot.autoconfigure.EnableAutoConfiguration;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.boot.jdbc.DataSourceBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;
import org.springframework.jdbc.datasource.DataSourceTransactionManager;
import org.springframework.stereotype.Component;

import javax.sql.DataSource;

/**
 * マルチデータベース設定クラス.
 */
@EnableAutoConfiguration
@Configuration
@Component
public class DatabaseConfig {

  /**
   * 医療情報DB用DataSourceを生成する.
   * @return 医療情報DB用DataSource
   */
  @Bean(name = DataSourceName.DEFAULT, destroyMethod = "close")
  @ConfigurationProperties("spring.datasource.default")
  @Primary
  DataSource defaultDataSource() {
    return DataSourceBuilder.create().build();
  }

  /**
   * 証明書DB用DataSourceを生成する.
   * @return 証明書DB用DataSource
   */
  @Bean(name = DataSourceName.CERTIFICATE, destroyMethod = "close")
  @ConfigurationProperties("spring.datasource.certificate")
  DataSource certificateDataSource() {
    return DataSourceBuilder.create().build();
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
   * 証明書DB用DomaConfigを生成する.
   * @param sqlFileRepository SqlFileRepository
   * @param naming Naming
   * @param provider EntityListenerProvider
   * @return 証明書DB用DomaConfig
   */
  @Bean
  @CertificateDb
  DomaConfig configCertificateDb(
      SqlFileRepository sqlFileRepository, Naming naming, EntityListenerProvider provider) {
    DomaConfigBuilder domaConfigBuilder = new DomaConfigBuilder()
        .dialect(new PostgresDialect())
        .sqlFileRepository(sqlFileRepository)
        .naming(naming)
        .entityListenerProvider(provider)
        .dataSource(certificateDataSource());

    DomaProperties domaProperties = new DomaProperties() {
      {
        setDataSourceName(DataSourceName.CERTIFICATE);
        setDialect(DialectType.POSTGRES);

      }
    };
    return new DomaConfig(domaConfigBuilder, domaProperties);
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
   * 証明書DB用TransactionManagerを生成する.
   * @return 証明書DB用TransactionManager
   */
  @Bean(TransactionManagerName.CERTIFICATE)
  public DataSourceTransactionManager certificateTransactionManager() {
    return new DataSourceTransactionManager(certificateDataSource());
  }
}
