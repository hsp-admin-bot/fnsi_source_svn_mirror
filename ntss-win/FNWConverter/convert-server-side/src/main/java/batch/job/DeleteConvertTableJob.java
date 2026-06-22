package batch.job;

import org.springframework.batch.core.job.Job;
import org.springframework.batch.core.step.Step;
import org.springframework.batch.core.job.builder.JobBuilder;
import org.springframework.batch.core.repository.JobRepository;
import org.springframework.batch.core.step.builder.StepBuilder;
import org.springframework.batch.core.job.parameters.RunIdIncrementer;
import org.springframework.batch.infrastructure.item.ExecutionContext;
import org.springframework.batch.infrastructure.repeat.RepeatStatus;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import batch.ApplicationConst;
import batch.ApplicationConst.JobParameterKeys;
import batch.part.ProgressManagement;
import batch.step.DeleteTableInConvertDbStep;
/**
 * 開発時のテスト用、コンバートDBデータを削除するジョブ
 */
@Configuration
public class DeleteConvertTableJob {
    private final String JOB_NAME = "DeleteConvertTableJob";

    @Autowired
    private JobRepository jobRepository;

    @Autowired
    ProgressManagement progressManagement;
    
    @Autowired
    DeleteTableInConvertDbStep deleteTableInConvertDbStep;

    @Bean
    Step initialConvertStep(){
        return new StepBuilder("initialConvertStep", jobRepository)
        .tasklet((contribution, chunkContext) -> {
            // 削除対象の施設コードの取得
            String facilityCd = chunkContext.getStepContext().getJobParameters()
            .get(JobParameterKeys.FACILITY_CD).toString();
            // 進捗更新
            long jobInstanceId = chunkContext.getStepContext().getStepExecution().getJobExecution().getJobInstance().getInstanceId();
            progressManagement.insertBatchStatus(facilityCd, progressManagement.STARTED, jobInstanceId, JOB_NAME);
            
            // コンバート処理IDの取得
            int convertProcId = progressManagement.getConvertProcId(facilityCd);
            // コンバート処理IDをを取得し、コンテキストへ保存する
            ExecutionContext cxt = chunkContext.getStepContext().getStepExecution().getJobExecution().getExecutionContext();
            cxt.put(ApplicationConst.PromotionKeys.CONVERT_PROC_ID,convertProcId);
            return RepeatStatus.FINISHED;
        }).build();
    }

    @Bean
    public Step getTargetConvertTableNamesStep() {
        return new StepBuilder("getTargetConvertTableNamesStep", jobRepository)
        .tasklet((contribution, chunkContext) -> {
            // 削除対象の施設コードの取得
            String facilityCd = chunkContext.getStepContext().getJobParameters()
            .get(JobParameterKeys.FACILITY_CD).toString();

            // 進捗更新
            long jobInstanceId = chunkContext.getStepContext().getStepExecution().getJobExecution().getJobInstance().getInstanceId();
            progressManagement.insertBatchStatus(facilityCd, progressManagement.STARTED, jobInstanceId, JOB_NAME);
            return RepeatStatus.FINISHED;
        }).build();
    }

    @Bean
    public Step updateBatchStatusStep() {
        return new StepBuilder("updateBatchStatusStep", jobRepository)
            .tasklet((contribution, chunkContext) -> {
                // 削除対象の施設コードの取得
                String facilityCd = chunkContext.getStepContext().getJobParameters()
                        .get(JobParameterKeys.FACILITY_CD).toString();
                // 進捗更新
                long jobInstanceId = chunkContext.getStepContext().getStepExecution().getJobExecution().getJobInstance().getInstanceId();
                int convertProcId = progressManagement.getConvertProcId(facilityCd);
                progressManagement.updateBatchStatus(convertProcId,facilityCd, progressManagement.COMPLETED, jobInstanceId, JOB_NAME);
                return RepeatStatus.FINISHED;
            }).build();
    }

    /**
     * ジョブの作成
     * 
     * @throws Exception
     */
    @Bean(name = JOB_NAME)
    public Job job() throws Exception {
        return new JobBuilder(JOB_NAME, jobRepository).incrementer(new RunIdIncrementer())
                .start(initialConvertStep())
                .next(getTargetConvertTableNamesStep())
                .next(deleteTableInConvertDbStep.step())
                .next(updateBatchStatusStep())
                .build();
    }
}