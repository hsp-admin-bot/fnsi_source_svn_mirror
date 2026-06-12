package web.config;

import org.springframework.batch.core.configuration.JobRegistry;
import org.springframework.batch.core.configuration.support.MapJobRegistry;
import org.springframework.batch.core.launch.JobLauncher;
import org.springframework.batch.core.launch.JobOperator;
import org.springframework.batch.core.launch.support.SimpleJobOperator;
import org.springframework.batch.core.launch.support.TaskExecutorJobLauncher;
import org.springframework.batch.core.repository.JobRepository;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.task.SimpleAsyncTaskExecutor;

/**
 * Webサーバ起動時のジョブ共通設定
 */
@Configuration
public class BatchCommonConfiguration {

	@Bean
	public JobRegistry jobRegistry() {
		return new MapJobRegistry();
	}

	@Bean(name = "parallelJobLauncher")
	public JobLauncher parallelJobobLauncher(JobRepository jobRepository) throws Exception {
		TaskExecutorJobLauncher jobLauncher = new TaskExecutorJobLauncher();
		jobLauncher.setJobRepository(jobRepository);
		jobLauncher.setTaskExecutor(new SimpleAsyncTaskExecutor());
		jobLauncher.afterPropertiesSet();

		return jobLauncher;
	}

	/**
	 * 並列実行用job操作オブジェクト
	 * @param jobRegistry Job登録オブジェクト
	 * @param jobRepository JobRepository
	 * @return 並列実行用job操作オブジェクト
	 * @throws Exception オブジェクト生成例外
	 */
	@Bean(name = "parallelJobOperator")
	public JobOperator parallelJobOperator(JobRegistry jobRegistry, JobRepository jobRepository) throws Exception {
		SimpleJobOperator jobOperator = new SimpleJobOperator();
		jobOperator.setJobRegistry(jobRegistry);
		jobOperator.setJobRepository(jobRepository);
		jobOperator.setTaskExecutor(new SimpleAsyncTaskExecutor());
		jobOperator.afterPropertiesSet();
		return jobOperator;
	}
}
