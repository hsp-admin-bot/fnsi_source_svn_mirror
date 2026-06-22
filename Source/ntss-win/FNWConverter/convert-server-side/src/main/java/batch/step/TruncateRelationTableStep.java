package batch.step;

import batch.ApplicationConst;
import batch.config.ConvertPriorityConfig;
import batch.listener.PromotionListener;
import batch.listener.StepStartEndListener;
import batch.part.PsqlCopyUtils;
import batch.part.InfomationSchemaControl;
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
import org.springframework.core.env.Environment;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;
import web.config.EventLoggerUtil;
import web.logger.EventLogMessage;
import web.logger.LogLevel;

import javax.sql.DataSource;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * 本番DBからコンバートDBに取得したコード変換用テーブルデータを削除するTaskletStep
 */
@Component
public class TruncateRelationTableStep extends StepStartEndListener implements Tasklet {

    public static final String STEP_NAME = "TruncateRelationTableStep";

    @Autowired
    private ApplicationContext appContext;

    @Autowired
    private JobRepository jobRepository;

    @Autowired
    ConvertPriorityConfig convertPriorityConfig;

    /**
     * ロギング ツール クラスの導入
     */
    @Autowired
    private EventLoggerUtil eventLoggerUtil;

    @Autowired
    private Environment environment;

    // add 優先度で並び替え 李 start
    private static class TableNamePriority{
        String tableName;
        int priority;
    }
    // add 優先度で並び替え 李 end

    @Override
    public RepeatStatus execute(StepContribution contribution, 
    ChunkContext chunkContext) throws Exception {
        Map<String, Object> jec = chunkContext.getStepContext().getJobExecutionContext();
        Map<String,String> copiedTableNameMap = PsqlCopyUtils.cast(jec.get(ApplicationConst.PromotionKeys.COPIED_TABLE_NAMES));
        String facilityCd = chunkContext.getStepContext().getJobParameters()
                .get(ApplicationConst.JobParameterKeys.FACILITY_CD).toString();
        if (copiedTableNameMap == null)
        {
            return RepeatStatus.FINISHED;
        }
        DataSource ds = (DataSource) appContext.getBean(ApplicationConst.DbType.CONVERT);
        JdbcTemplate jdbcTemplate = new JdbcTemplate(ds);

        List<String> copiedTableList = new ArrayList<String>(copiedTableNameMap.keySet());
        // add 優先度で並び替え 李 start
        List<TableNamePriority> tableNameList = new ArrayList<TableNamePriority>();
        for(String tableName:copiedTableList){
            int priority = convertPriorityConfig.getPriority(tableName);
            TableNamePriority tableNamePriority = new TableNamePriority();
            tableNamePriority.priority = priority;
            tableNamePriority.tableName = tableName;
            tableNameList.add(tableNamePriority);
        }
        copiedTableList = tableNameList
                .stream()
                .sorted((a,b) -> b.priority - a.priority)
                .map(dto -> dto.tableName)
                .collect(Collectors.toList());
        // add 優先度で並び替え 李 end
        for(String truncateTableName : copiedTableList){
            // SQLインジェクション対策：テーブル名が安全な文字のみを含むことを検証
            if (!truncateTableName.matches("^[a-zA-Z0-9_]+$")) {
                throw new IllegalArgumentException("安全でないテーブル名: " + truncateTableName);
            }

            String db_table_prefix = environment.getProperty(ApplicationConst.DbType.CONVERT + "_prefix");
            db_table_prefix = db_table_prefix == null ? "" : db_table_prefix;
            InfomationSchemaControl isc = new InfomationSchemaControl(appContext);
            String sql;
            if(isc.hasFacilityCd(truncateTableName)){
                // 施設コードを保持しているテーブルを削除する
                // 注意：テーブル名は?でパラメータ化できないため連結が必要だが、安全性は検証済み
                sql = "delete from " + db_table_prefix + truncateTableName
                        + " where facility_cd = ?";
                // mod FNSI_複数施設修正 楊 end
                jdbcTemplate.update(sql, facilityCd);
            }else{
                // Truncateは実施しない方針
                // 注意：テーブル名は?でパラメータ化できないため連結が必要だが、安全性は検証済み
                sql = "truncate table " + db_table_prefix + truncateTableName + " cascade";
                // mod FNSI_複数施設修正 楊 end
                jdbcTemplate.execute(sql);
            }
            //ログ
            EventLogMessage eventLogMessage11 = eventLoggerUtil.getEventLogMessage("コード変換用テーブルデータ削除実行：" + sql,
                    facilityCd, "TruncateRelationTableStep.execute(StepContribution contribution, ChunkContext chunkContext)");
            eventLoggerUtil.recordLog(facilityCd, eventLogMessage11, LogLevel.INFO);
        }
        return RepeatStatus.FINISHED;
    }

    @Bean(name=STEP_NAME)
    public Step step() {
        return new StepBuilder(STEP_NAME, jobRepository)
            .tasklet(this)
            .listener(new PromotionListener())
            .build();
    }

}