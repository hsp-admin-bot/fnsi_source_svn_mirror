package batch.config;

import batch.ApplicationConst;
import com.zaxxer.hikari.HikariDataSource;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.boot.jdbc.DataSourceBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.jdbc.datasource.DataSourceTransactionManager;

import javax.sql.DataSource;
import java.util.concurrent.TimeUnit;

/**
 * ymlファイルからJDBC接続情報を取得し保存するクラス
 */
@Configuration
public class DataSourceConfig {
    @ConfigurationProperties(prefix = "datasource.nkk4")
    @Bean(name=ApplicationConst.DbType.NKK4)
    public DataSource dataSourceNkk4(){
    	// Modified by Zhou.tao 2023-04-24 START
    	HikariDataSource nkk4DS = (HikariDataSource) DataSourceBuilder.create().build();
    	nkk4DS.setMaximumPoolSize(5);
		nkk4DS.setMinimumIdle(2);
		nkk4DS.setMaxLifetime(TimeUnit.MINUTES.toMillis(5));
		nkk4DS.setIdleTimeout(TimeUnit.SECONDS.toMillis(50));	// postregSQL wal_receiver_timeout:60000ms
    	return nkk4DS;
		// Modified by Zhou.tao 2023-04-24 END
    }

    @ConfigurationProperties(prefix = "datasource.nkk5")
    @Bean(name=ApplicationConst.DbType.NKK5)
    public DataSource dataSourceNkk5(){
		// Modified by Zhou.tao 2023-04-24 START
		HikariDataSource nkk5DS = (HikariDataSource) DataSourceBuilder.create().build();
		nkk5DS.setMaximumPoolSize(5);
		nkk5DS.setMinimumIdle(2);
		nkk5DS.setMaxLifetime(TimeUnit.MINUTES.toMillis(5));
		nkk5DS.setIdleTimeout(TimeUnit.SECONDS.toMillis(50));	// postregSQL wal_receiver_timeout:60000ms
		return nkk5DS;
		// Modified by Zhou.tao 2023-04-24 END
    }

    @ConfigurationProperties(prefix = "datasource.nkk6")
    @Bean(name=ApplicationConst.DbType.NKK6)
    public DataSource dataSourceNkk6(){
		// Modified by Zhou.tao 2023-04-24 START
		HikariDataSource nkk6DS = (HikariDataSource) DataSourceBuilder.create().build();
		nkk6DS.setMaximumPoolSize(5);
		nkk6DS.setMinimumIdle(2);
		nkk6DS.setMaxLifetime(TimeUnit.MINUTES.toMillis(5));
		nkk6DS.setIdleTimeout(TimeUnit.SECONDS.toMillis(50));	// postregSQL wal_receiver_timeout:60000ms
		return nkk6DS;
		// Modified by Zhou.tao 2023-04-24 END
    }

    @ConfigurationProperties(prefix = "datasource.convert")
    @Bean(name=ApplicationConst.DbType.CONVERT)
    @Primary
    public DataSource dataSourceConvert(){
		// Modified by Zhou.tao 2023-04-24 START
		HikariDataSource convertDS = (HikariDataSource) DataSourceBuilder.create().build();
		convertDS.setMaximumPoolSize(5);
		convertDS.setMinimumIdle(2);
		convertDS.setIdleTimeout(TimeUnit.SECONDS.toMillis(50));	// postregSQL wal_receiver_timeout:60000ms
		convertDS.setMaxLifetime(TimeUnit.MINUTES.toMillis(5));
		return convertDS;
		// Modified by Zhou.tao 2023-04-24 END
    }


    /** NKK4への接続名称 */
    public static final String DB_NAME_NKK4 = "nkk4";
    /** NKK5への接続名称 */
    public static final String DB_NAME_NKK5 = "nkk5";
    /** NKK6への接続名称 */
    public static final String DB_NAME_NKK6 = "nkk6";
    /** CONVERTへの接続名称 */
    public static final String DB_NAME_CONVERT = "convert";
	/** TransactionBeanの接頭語 */
	public static final String BEANNAME_TRANSACTION = "batch.transactionManager.DB=";

	/**
	 * トランザクション管理Bean(Primary)
	 * @param dataSource Primaryのデータソース
	 * @return トランザクション管理インスタンス
	 */
	@Bean(name = BEANNAME_TRANSACTION)
	@Primary
	public DataSourceTransactionManager transactionManager(final DataSource dataSource) {
		DataSourceTransactionManager transactionManager = new DataSourceTransactionManager(dataSource);
		transactionManager.setRollbackOnCommitFailure(true);
		transactionManager.afterPropertiesSet();
		return transactionManager;
	}
	/**
	 * トランザクション管理Bean(NKK4)
	 * @param dataSource NKK4のデータソース
	 * @return トランザクション管理インスタンス(NKK4用)
	 */
	@Bean(name = BEANNAME_TRANSACTION + DB_NAME_NKK4)
	public DataSourceTransactionManager transactionManagerNkk4(
			final @Autowired @Qualifier(DB_NAME_NKK4) DataSource dataSource) {
		DataSourceTransactionManager transactionManager = new DataSourceTransactionManager(dataSource);
		transactionManager.setRollbackOnCommitFailure(true);
		transactionManager.afterPropertiesSet();
		return transactionManager;
    }
    /**
	 * トランザクション管理Bean(NKK5)
	 * @param dataSource NKK5のデータソース
	 * @return トランザクション管理インスタンス(NKK5用)
	 */
	@Bean(name = BEANNAME_TRANSACTION + DB_NAME_NKK5)
	public DataSourceTransactionManager transactionManagerNkk5(
			final @Autowired @Qualifier(DB_NAME_NKK5) DataSource dataSource) {
		DataSourceTransactionManager transactionManager = new DataSourceTransactionManager(dataSource);
		transactionManager.setRollbackOnCommitFailure(true);
		transactionManager.afterPropertiesSet();
		return transactionManager;
    }
    /**
	 * トランザクション管理Bean(NKK6)
	 * @param dataSource NKK6のデータソース
	 * @return トランザクション管理インスタンス(NKK6用)
	 */
	@Bean(name = BEANNAME_TRANSACTION + DB_NAME_NKK6)
	public DataSourceTransactionManager transactionManagerNkk6(
			final @Autowired @Qualifier(DB_NAME_NKK6) DataSource dataSource) {
		DataSourceTransactionManager transactionManager = new DataSourceTransactionManager(dataSource);
		transactionManager.setRollbackOnCommitFailure(true);
		transactionManager.afterPropertiesSet();
		return transactionManager;
    }
    /**
	 * トランザクション管理Bean(CONVERT)
	 * @param dataSource CONVERTのデータソース
	 * @return トランザクション管理インスタンス(CONVERT用)
	 */
	@Bean(name = BEANNAME_TRANSACTION + DB_NAME_CONVERT)
	public DataSourceTransactionManager transactionManagerConvert(
			final @Autowired @Qualifier(DB_NAME_CONVERT) DataSource dataSource) {
		DataSourceTransactionManager transactionManager = new DataSourceTransactionManager(dataSource);
		transactionManager.setRollbackOnCommitFailure(true);
		transactionManager.afterPropertiesSet();
		return transactionManager;
	}

	// 各 DataSource の JdbcTemplate は、各所で new() するのではなく、Spring コンテナで管理する。--start
	/**
	 * NamedParameterJdbcTemplate （プライマリ）
	 * @param dataSource
	 * @return
	 */
	@Bean
	@Primary
	public NamedParameterJdbcTemplate namedParameterJdbcTemplate(final DataSource dataSource) {
		return new NamedParameterJdbcTemplate(dataSource);
	}

	/**
	 * NamedParameterJdbcTemplate （Nkk4）
	 * @return
	 */
	@Bean
	public NamedParameterJdbcTemplate namedParameterJdbcTemplateNkk4() {
		return new NamedParameterJdbcTemplate(dataSourceNkk4());
	}

	/**
	 * NamedParameterJdbcTemplate （Nkk5）
	 * @return
	 */
	@Bean
	public NamedParameterJdbcTemplate namedParameterJdbcTemplateNkk5(
			@Qualifier(ApplicationConst.DbType.NKK5) DataSource dataSourceNkk5) {
		return new NamedParameterJdbcTemplate(dataSourceNkk5);
	}

	/**
	 * NamedParameterJdbcTemplate （Nkk6）
	 * @return
	 */
	@Bean
	public NamedParameterJdbcTemplate namedParameterJdbcTemplateNkk6(
			@Qualifier(ApplicationConst.DbType.NKK6) DataSource dataSourceNkk6) {
		return new NamedParameterJdbcTemplate(dataSourceNkk6);
	}

	/**
	 * NamedParameterJdbcTemplate （Convert）
	 * @return
	 */
	@Bean
	public NamedParameterJdbcTemplate namedParameterJdbcTemplateConvert(
			@Qualifier(ApplicationConst.DbType.CONVERT) DataSource dataSourceConvert) {
		return new NamedParameterJdbcTemplate(dataSourceConvert);
	}

	/**
	 * JdbcTemplate for NKK4
	 */
	@Bean
	public JdbcTemplate jdbcTemplateNkk4(
			final @Qualifier(ApplicationConst.DbType.NKK4) DataSource dataSource) {
		return new JdbcTemplate(dataSource);
	}

	/**
	 * JdbcTemplate for NKK5
	 */
	@Bean
	public JdbcTemplate jdbcTemplateNkk5(
			final @Qualifier(ApplicationConst.DbType.NKK5) DataSource dataSource) {
		return new JdbcTemplate(dataSource);
	}

	/**
	 * JdbcTemplate for NKK6
	 */
	@Bean
	public JdbcTemplate jdbcTemplateNkk6(
			final @Qualifier(ApplicationConst.DbType.NKK6) DataSource dataSource) {
		return new JdbcTemplate(dataSource);
	}

	/**
	 * JdbcTemplate for CONVERT
	 */
	@Bean
	public JdbcTemplate jdbcTemplateConvert(
			final @Qualifier(ApplicationConst.DbType.CONVERT) DataSource dataSource) {
		return new JdbcTemplate(dataSource);
	}
	// 各 DataSource の JdbcTemplate は、各所で new() するのではなく、Spring コンテナで管理する。--end
}