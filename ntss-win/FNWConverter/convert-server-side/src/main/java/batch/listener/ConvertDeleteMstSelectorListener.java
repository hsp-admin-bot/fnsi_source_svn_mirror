package batch.listener;

import batch.ApplicationConst;
import org.springframework.batch.core.ExitStatus;
import org.springframework.batch.core.JobParameters;
import org.springframework.batch.core.StepExecution;
import org.springframework.batch.core.StepExecutionListener;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationContext;
import org.springframework.core.env.Environment;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcOperations;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Component;

import javax.sql.DataSource;

/**
 * ConvertDBのmst _selectorデータ
 */
@Component
public class ConvertDeleteMstSelectorListener implements StepExecutionListener {

    public static final String TABLENAME = "mst_selector";

    @Autowired
    private Environment environment;

    @Autowired
    private ApplicationContext appContext;

    @Autowired
    private NamedParameterJdbcOperations machineJdbcTemplateConvert;

    @Override
    public void beforeStep(StepExecution stepExecution) {
        //施設コード取得
        JobParameters jobParameters = stepExecution.getJobParameters();
        String facility_cd = jobParameters.getString(ApplicationConst.JobParameterKeys.FACILITY_CD);
        //差分の場合はconvert _db元のmst _selectorのデータ（初回であれば自身のconvert _ dbのmst _ selectorは空なので削除しても影響ありません）
        String convert_db_table_prefix = environment.getProperty("datasource." + ApplicationConst.DbType.CONVERT + ".table_prefix");
        DataSource convertDb = (DataSource) appContext.getBean(ApplicationConst.DbType.CONVERT);
        machineJdbcTemplateConvert = new NamedParameterJdbcTemplate(convertDb);
        // mod #10418 SQL注入対策：パラメータバインディングを使用 start
        String convertsql = "DELETE FROM " + convert_db_table_prefix + TABLENAME + " WHERE facility_cd = :facilityCd";
        org.springframework.jdbc.core.namedparam.MapSqlParameterSource params =
            new org.springframework.jdbc.core.namedparam.MapSqlParameterSource();
        params.addValue("facilityCd", facility_cd);
        machineJdbcTemplateConvert.update(convertsql, params);
        // mod #10418 SQL注入対策：パラメータバインディングを使用 end
    }

    @Override
    public ExitStatus afterStep(StepExecution stepExecution) {
        return null;
    }
}
