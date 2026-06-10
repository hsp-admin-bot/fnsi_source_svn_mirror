package batch;

import java.time.LocalDateTime;

import org.springframework.batch.core.Job;
import org.springframework.batch.core.JobParameters;
import org.springframework.batch.core.JobParametersBuilder;
import org.springframework.batch.core.JobParametersInvalidException;
import org.springframework.batch.core.launch.JobLauncher;
import org.springframework.batch.core.repository.JobExecutionAlreadyRunningException;
import org.springframework.batch.core.repository.JobInstanceAlreadyCompleteException;
import org.springframework.batch.core.repository.JobRestartException;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.WebApplicationType;
import org.springframework.boot.autoconfigure.EnableAutoConfiguration;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.context.annotation.ComponentScan;

import batch.ApplicationConst.JobParameterKeys;

/**
 * Javaバッチとして起動する際のアプリケーションのエントリポイント
 */
@SpringBootApplication
@ComponentScan(basePackages = "batch")
@EnableAutoConfiguration
public class Application {

	public static void main(String[] args) throws JobExecutionAlreadyRunningException, JobRestartException,
			JobInstanceAlreadyCompleteException, JobParametersInvalidException {

        SpringApplication app = new SpringApplication(Application.class);
        app.setWebApplicationType(WebApplicationType.NONE);
        ConfigurableApplicationContext ctx = app.run(args);
        JobLauncher jobLauncher = ctx.getBean(JobLauncher.class);

        // 引数をJobParametersに設定する
        JobParametersBuilder  builder = new JobParametersBuilder();
        for (String arg : args) {
            String[] keyValue = arg.split("=");
            builder.addString(keyValue[0], keyValue[1]);
        }
        builder.addString(JobParameterKeys.TIME_STAMP, LocalDateTime.now().toString());
        JobParameters jobParameters = builder.toJobParameters();
        
        // ジョブの実行
        String target = jobParameters.getString(JobParameterKeys.JOB);
        Job job = ctx.getBean(target, Job.class);
        jobLauncher.run(job, jobParameters);
	}

}
