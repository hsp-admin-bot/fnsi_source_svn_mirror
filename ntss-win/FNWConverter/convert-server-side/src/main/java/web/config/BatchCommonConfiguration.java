package web.config;

import org.springframework.batch.core.configuration.JobRegistry;
import org.springframework.batch.core.explore.JobExplorer;
import org.springframework.batch.core.launch.JobLauncher;
import org.springframework.batch.core.launch.JobOperator;
import org.springframework.batch.core.launch.support.SimpleJobLauncher;
import org.springframework.batch.core.launch.support.SimpleJobOperator;
import org.springframework.batch.core.repository.JobRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.task.SimpleAsyncTaskExecutor;

/**
 * Webサーバ起動時のジョブ共通設定
 */
@Configuration
public class BatchCommonConfiguration {

	@Bean(name = "parallelJobLauncher")
	public JobLauncher parallelJobobLauncher(JobRepository jobRepository) throws Exception {
		SimpleJobLauncher jobLauncher = new SimpleJobLauncher();
		jobLauncher.setJobRepository(jobRepository);
		jobLauncher.setTaskExecutor(new SimpleAsyncTaskExecutor());
		jobLauncher.afterPropertiesSet();

		return jobLauncher;
	}

	/**
	 * 並列実行用job操作オブジェクト
	 * @param jobLauncher 実行用ランチャー
	 * @param jobExplorer Job検索オブジェクト
	 * @param jobRegistry Job登録オブジェクト
	 * @return 並列実行用job操作オブジェクト
	 * @throws Exception オブジェクト生成例外
	 */
	@Bean(name = "parallelJobOperator")
	public JobOperator parallelJobOperator(@Autowired @Qualifier("parallelJobLauncher") JobLauncher jobLauncher,
			@Autowired JobExplorer jobExplorer, @Autowired JobRegistry jobRegistry,
			@Autowired JobRepository jobRepository) throws Exception {
		SimpleJobOperator jobOperator = new SimpleJobOperator();
		jobOperator.setJobLauncher(jobLauncher);
		jobOperator.setJobExplorer(jobExplorer);
		jobOperator.setJobRegistry(jobRegistry);
		jobOperator.setJobRepository(jobRepository);
		jobOperator.afterPropertiesSet();
		return jobOperator;
	}
}
