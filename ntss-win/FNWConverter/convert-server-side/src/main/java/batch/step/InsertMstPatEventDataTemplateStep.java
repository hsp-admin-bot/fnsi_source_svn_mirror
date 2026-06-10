package batch.step;

import javax.sql.DataSource;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.batch.core.Step;
import org.springframework.batch.core.StepContribution;
import org.springframework.batch.core.configuration.annotation.StepBuilderFactory;
import org.springframework.batch.core.scope.context.ChunkContext;
import org.springframework.batch.core.step.tasklet.Tasklet;
import org.springframework.batch.repeat.RepeatStatus;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationContext;
import org.springframework.context.annotation.Bean;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;

import batch.ApplicationConst;
import batch.ApplicationConst.JobParameterKeys;
import batch.listener.StepStartEndListener;

/**
 * MstPatEventDataTemplateのデータを個別で登録するステップ
 */
@Component
public class InsertMstPatEventDataTemplateStep extends StepStartEndListener implements Tasklet {

    public static final String STEP_NAME = "InsertMstPatEventDataTemplateStep"; 

    private static final Logger logger = LoggerFactory.getLogger(InsertMstPatEventDataTemplateStep.class);

    @Autowired
    StepBuilderFactory stepBuilderFactory;

    @Autowired
    ApplicationContext appContext;
    
    @Override
    public RepeatStatus execute(StepContribution contribution, 
    ChunkContext chunkContext) throws Exception {
        // 処理対象の施設コードの取得
        String facilityCd = chunkContext.getStepContext().getJobParameters()
        .get(JobParameterKeys.FACILITY_CD).toString();

        // SQLインジェクション対策：パラメータ化クエリを使用替代字符串拼接
        String sql = "insert into mst_pat_event_data_template (facility_cd,template_name)"
        + " select t1.facility_cd,t1.template_name from "
        + " ("
        + " select ? as facility_cd,'VA' as template_name"
        + " union"
        + " select ? as facility_cd,'VA以外' as template_name"
        + " ) as t1"
        + " where not exists("
        + " select * from mst_pat_event_data_template m1"
        + " where m1.facility_cd=t1.facility_cd and m1.template_name=t1.template_name"
        + " )";
        // mod 2020-12-3 【ApplicationConst.DbType.NKK5】パラメータエラー  う start
        DataSource ds = (DataSource) appContext.getBean(ApplicationConst.DbType.CONVERT);
        // mod 2020-12-3 【ApplicationConst.DbType.NKK5】パラメータエラー  う end
        JdbcTemplate jdbcTemplate = new JdbcTemplate(ds);
        int recCnt = jdbcTemplate.update(sql, facilityCd, facilityCd);
        logger.info("mst_pat_event_data_template登録処理実行：");
        logger.info(" 施設コード："+ facilityCd);
        logger.info(" 処理件数：" + String.valueOf(recCnt) + "件"); 
        logger.info(" SQL：" + sql); 
        return RepeatStatus.FINISHED;
    }

    @Bean(name=STEP_NAME)
    public Step step() {
        return stepBuilderFactory.get(STEP_NAME)
            .tasklet(this)
            .build();
    }
}