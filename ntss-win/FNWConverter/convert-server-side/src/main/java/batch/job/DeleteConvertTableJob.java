package batch.job;

import org.springframework.batch.core.Job;
import org.springframework.batch.core.Step;
import org.springframework.batch.core.configuration.annotation.EnableBatchProcessing;
import org.springframework.batch.core.configuration.annotation.JobBuilderFactory;
import org.springframework.batch.core.configuration.annotation.StepBuilderFactory;
import org.springframework.batch.core.launch.support.RunIdIncrementer;
import org.springframework.batch.item.ExecutionContext;
import org.springframework.batch.repeat.RepeatStatus;
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
@EnableBatchProcessing
public class DeleteConvertTableJob {
    private final String JOB_NAME = "DeleteConvertTableJob";

    @Autowired
    JobBuilderFactory jobBuilderFactory;

    @Autowired
    StepBuilderFactory stepBuilderFactory;

    @Autowired
    ProgressManagement progressManagement;
    
    @Autowired
    DeleteTableInConvertDbStep deleteTableInConvertDbStep;

    @Bean
    Step initialConvertStep(){
        return stepBuilderFactory.get("initialConvertStep")
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
        return stepBuilderFactory.get("getTargetConvertTableNamesStep")
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
        return stepBuilderFactory.get("updateBatchStatusStep")
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
        return jobBuilderFactory.get(JOB_NAME).incrementer(new RunIdIncrementer())
                .start(initialConvertStep())
                .next(getTargetConvertTableNamesStep())
                .next(deleteTableInConvertDbStep.step())
                .next(updateBatchStatusStep())
                .build();
    }
}