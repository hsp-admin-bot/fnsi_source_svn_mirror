package batch.step;

import batch.ApplicationConst;
import com.zaxxer.hikari.HikariDataSource;
import org.springframework.batch.core.step.Step;
import org.springframework.batch.core.step.StepContribution;
import org.springframework.batch.core.repository.JobRepository;
import org.springframework.batch.core.step.builder.StepBuilder;
import org.springframework.batch.core.scope.context.ChunkContext;
import org.springframework.batch.core.step.tasklet.Tasklet;
import org.springframework.batch.infrastructure.repeat.RepeatStatus;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationContext;
import org.springframework.context.annotation.Bean;

import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Component;
import utils.Utils;


/**
 * 保険情報処理クラス
 */
@Component
public class PatInsuranceStep implements Tasklet {

    public static final String STEP_NAME = "PatInsuranceStep";

    // add #10213 djy start
    @Autowired
    Utils utils;
    // add #10213 djy end

    @Autowired
    private JobRepository jobRepository;

    // add #9268 保険のセット情報がコンバートされていない zs start
    @Autowired
    private ApplicationContext appContext;
    // add #9268 保険のセット情報がコンバートされていない zs end

    @Override
    public RepeatStatus execute(StepContribution contribution, 
    ChunkContext chunkContext) throws Exception {
        String facilityCd = chunkContext.getStepContext().getJobParameters().get(ApplicationConst.JobParameterKeys.FACILITY_CD).toString();
        HikariDataSource ds6 = (HikariDataSource) appContext.getBean(ApplicationConst.DbType.NKK6);
        MapSqlParameterSource parameters = new MapSqlParameterSource()
                .addValue("facility_cd", facilityCd);
        NamedParameterJdbcTemplate machineJdbcTemplate = new NamedParameterJdbcTemplate(ds6);
        String sqlA = "UPDATE ntss.pat_insurance a SET insu_set_info = jsonb_set(a.insu_set_info, '{insu_cd}', concat(concat('\"',b.insurance_cd),'\"')::jsonb) from ntss.pat_insurance b where b.pat_id = a.pat_id and b.facility_cd = a.facility_cd and b.insu_class = 0 and b.is_disp = '1' and a.fn_ctl_no = '4' and a.facility_cd = :facility_cd";
        String sqlB = "UPDATE ntss.pat_insurance a SET insu_set_info = jsonb_set(a.insu_set_info, '{insu_pub1_cd}', concat(concat('\"',b.insurance_cd),'\"')::jsonb) from ntss.pat_insurance b where b.pat_id = a.pat_id and b.facility_cd = a.facility_cd and b.insu_class = 1 and b.is_disp = '1' and b.fn_ctl_no = '2' and a.fn_ctl_no = '4' and a.facility_cd = :facility_cd";
        String sqlC = "UPDATE ntss.pat_insurance a SET insu_set_info = jsonb_set(a.insu_set_info, '{insu_pub2_cd}', concat(concat('\"',b.insurance_cd),'\"')::jsonb) from ntss.pat_insurance b where b.pat_id = a.pat_id and b.facility_cd = a.facility_cd and b.insu_class = 1 and b.is_disp = '1' and b.fn_ctl_no = '3' and a.fn_ctl_no = '4' and a.facility_cd = :facility_cd";
        machineJdbcTemplate.update(sqlA, parameters);
        machineJdbcTemplate.update(sqlB, parameters);
        machineJdbcTemplate.update(sqlC, parameters);

        String sqlD=" UPDATE ntss.pat_insurance A " +
                "  SET is_selected ='0' " +
                "FROM" +
                "(select  pat_id,facility_cd  from  pat_insurance where   facility_cd=:facility_cd and  fn_ctl_no = '4'  and  is_disp = '1'  and  is_del = '0' and is_selected='1'  ) b " +
                "WHERE " +
                "b.pat_id = A.pat_id " +
                "AND b.facility_cd = A.facility_cd " +
                "AND A.is_disp = '1' " +
                "AND A.is_del = '0' " +
                "AND A.is_selected = '1' " +
                "AND (A.fn_ctl_no != '4' or fn_ctl_no is null ) " +
                "AND A.facility_cd = :facility_cd";
        machineJdbcTemplate.update(sqlD, parameters);


        return RepeatStatus.FINISHED;
    }

    @Bean(name=STEP_NAME)
    public Step step() {
        return new StepBuilder(STEP_NAME, jobRepository)
            .tasklet(this)
            .build();
    }
}