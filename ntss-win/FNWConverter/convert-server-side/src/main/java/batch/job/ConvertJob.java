package batch.job;

import batch.decider.ProcessingSqlFileDecider;
import batch.listener.JobStartEndLIstener;
import batch.step.ConvertDbToProductionDbStep;
import batch.step.DeleteTableInConvertDbStep;
import batch.step.InOutVisitHistoryStep;
import batch.step.MakeSqlStep;
import batch.step.MstSelectorStep;
import batch.step.OrderMainDerivedDataProcessingStep;
import batch.step.PatIndApproveStep;
import batch.step.PatInsuranceStep;
import batch.step.ProductionDbToConvertDbStep;
import batch.step.ReadSqlFileWriteDbStep;
import batch.step.RestartStep;
import batch.step.TruncateTableStep;
import batch.validator.ConvertJobValidator;
import org.springframework.batch.core.job.Job;
import org.springframework.batch.core.configuration.annotation.EnableBatchProcessing;
import org.springframework.batch.core.job.builder.JobBuilder;
import org.springframework.batch.core.repository.JobRepository;
import org.springframework.batch.core.job.parameters.RunIdIncrementer;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
@EnableBatchProcessing
public class ConvertJob {

    private final String JOB_NAME = "ConvertJob";

    @Autowired
    private JobRepository jobRepository;

    @Autowired
    private ReadSqlFileWriteDbStep readSqlFileWriteDbStep;

    @Autowired
    private ConvertDbToProductionDbStep convertDbToProductionDbStep;

    @Autowired
    private PatInsuranceStep patInsuranceStep;

    @Autowired
    private ProductionDbToConvertDbStep productionDbToConvertDbStep;

    @Autowired
    private TruncateTableStep truncateTableStep;

    @Autowired
    private DeleteTableInConvertDbStep deleteTableInConvertDbStep;

    @Autowired
    private JobStartEndLIstener jobStartEndLIstener;

    @Autowired
    private ProcessingSqlFileDecider processingSqlFileDecider;

    // add #7339 AWS側アプリが起動しない途中から開始されない yangmj start
    @Autowired
    private MakeSqlStep makeSqlStep;

    @Autowired
    private RestartStep restartStep;
    // add #7339 AWS側アプリが起動しない途中から開始されない yangmj end
    @Autowired
    private MstSelectorStep mstSelectorStep;

    @Autowired
    private OrderMainDerivedDataProcessingStep orderMainDerivedDataProcessingStep;
    // add #11357 【たくしん会】患者の入外区分が「－」でコンバートされる houyulong start
    @Autowired
    private InOutVisitHistoryStep inOutVisitHistoryStep;

    @Autowired
    private PatIndApproveStep patIndApproveStep;

    // add #11357 【たくしん会】患者の入外区分が「－」でコンバートされる houyulong end
    /**
     * ジョブの作成
     *
     * @throws Exception
     */
    @Bean(name = JOB_NAME)
    public Job job() throws Exception {
        return new JobBuilder(JOB_NAME, jobRepository).incrementer(new RunIdIncrementer()).validator(new ConvertJobValidator())
                .listener(jobStartEndLIstener)
                .start(restartStep.step())
                .next(deleteTableInConvertDbStep.step())
                .next(processingSqlFileDecider)
                .on("CONTINUE")
                            .to(readSqlFileWriteDbStep.step())
                            .next(makeSqlStep.step())// add #7339 AWS側アプリが起動しない途中から開始されない 楊
                            .next(convertDbToProductionDbStep.step())
                            .next(truncateTableStep.step())
                            .next(productionDbToConvertDbStep.step())
                            .next(orderMainDerivedDataProcessingStep.step()) //ord_main派生データ処理
                            .next(processingSqlFileDecider)
                .on("COMPLETED")
                    .to(patInsuranceStep.step())
                .next(inOutVisitHistoryStep.step())
                .next(mstSelectorStep.step())
                .next(patIndApproveStep.step())//add #10759 pat_ind_approve
                .end().build();
    }

}