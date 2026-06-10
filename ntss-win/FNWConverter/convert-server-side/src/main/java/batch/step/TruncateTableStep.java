package batch.step;

import java.io.File;
import java.util.List;

import javax.sql.DataSource;

import batch.config.ConvertKeyConfig;
import batch.listener.JobStartEndLIstener;
import org.springframework.batch.core.Step;
import org.springframework.batch.core.StepContribution;
import org.springframework.batch.core.configuration.annotation.StepBuilderFactory;
import org.springframework.batch.core.scope.context.ChunkContext;
import org.springframework.batch.core.step.tasklet.Tasklet;
import org.springframework.batch.repeat.RepeatStatus;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationContext;
import org.springframework.context.annotation.Bean;
import org.springframework.core.env.Environment;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;
import utils.GlobalContext;
import batch.ApplicationConst;
import batch.listener.PromotionListener;
import batch.listener.StepStartEndListener;
import batch.part.PsqlCopyUtils;
import utils.Utils;
import web.config.EventLoggerUtil;
import web.logger.EventLogMessage;
import web.logger.LogLevel;

/**
 * FNWからコンバートDBに登録したテーブルデータを削除するTaskletStep
 */
@Component
public class TruncateTableStep extends StepStartEndListener implements Tasklet {

    public static final String STEP_NAME = "TruncateTableStep";

    @Autowired
    private ApplicationContext appContext;

    @Autowired
    private StepBuilderFactory stepBuilderFactory;

    /**
     * ロギング ツール クラスの導入
     */
    @Autowired
    private EventLoggerUtil eventLoggerUtil;

    @Autowired
    private Environment environment;

    // add 7853-差分コンバートで更新/削除ができない 楊 start
    @Autowired
    private ConvertKeyConfig convertKeyConfig;

    @Autowired
    Utils utils;
    // add 7853-差分コンバートで更新/削除ができない 楊 end
    @Override
    public RepeatStatus execute(StepContribution contribution, ChunkContext chunkContext) throws Exception {

        GlobalContext globalContext = JobStartEndLIstener.getGlobalContext();
        String facilityCd = chunkContext.getStepContext().getJobParameters()
                .get(ApplicationConst.JobParameterKeys.FACILITY_CD).toString();
        // add #10143 djy start
        if (globalContext.ErrorOrdNo != null) {
            globalContext.ErrorOrdNo = null;
        }
        // add #10143 djy end
        // 処理対象ファイル名からテーブル名の取得
        String nextProcessingFile = chunkContext.getStepContext().getJobExecutionContext().get(ApplicationConst.PromotionKeys.NEXT_PROCESSING_FILE).toString();
        int indexFile = nextProcessingFile.indexOf("indicatorShoe");
        //add  #6886 2022-05-10   判断条件の修正  鄭  start
        int patmongo = nextProcessingFile.indexOf("pat(mongo)");
        //add  #68862022-05-10   判断条件の修正  鄭  start
        if(indexFile != -1){
            return RepeatStatus.FINISHED;
        }
        //add  #6886 2022-05-10   判断条件の修正  鄭  start
        else if(patmongo != -1){
            return RepeatStatus.FINISHED;
        }
        //add  #68862022-05-10   判断条件の修正  鄭  start
        else {
            String tableName = PsqlCopyUtils.getTableName(nextProcessingFile);
            // mod 10378-24-4 PatTreatmentPattern再構築対応 zkm start
            if(utils.DiffNotCopyDbToConvert.contains(tableName)){
                return RepeatStatus.FINISHED;
            }
            // mod 10378-24-4 PatTreatmentPattern再構築対応 zkm end

            DataSource ds = (DataSource) appContext.getBean(ApplicationConst.DbType.CONVERT);
            JdbcTemplate jdbcTemplate = new JdbcTemplate(ds);
            String db_table_prefix = environment.getProperty(ApplicationConst.DbType.CONVERT + "_prefix");
            db_table_prefix = db_table_prefix == null ? "" : db_table_prefix;
            // 施設コードより、コンバート後データが削除
            String sql = "";
            // convertKeyから、fn keyを取得
            String cols = convertKeyConfig.getConvertKey(tableName);

            if (cols == null || cols.trim().isEmpty()){
                cols = convertKeyConfig.getConvertbKey(tableName);
            }
            // 施設コードを保持しているテーブルを削除する
            String[] names = cols.split(",");
            // キーが「"facility_cd"」の場合、削除しない。
            // 差分コンバート場合、更新レコード削除しない。
            // 初回コンバートの場合
            if (!nextProcessingFile.contains("[diff]")) {
                String inputPath = chunkContext.getStepContext().getJobParameters().get(ApplicationConst.JobParameterKeys.INPUT_FILE_PATH)
                        .toString();
                // sqlファイルから、コピーsqlを取得する
                File fileTruncateTableStep = new File(inputPath + "/TruncateTableStep.txt");
                // コンバートDBから本番DBにテーブルデータを登録ファイル 一行目：sqlCommand
                if (fileTruncateTableStep.exists() && 0 != fileTruncateTableStep.length())
                {
                    // mod 8309 【デグレ】FNWデモ環境からコンバートするツールがエラーで停止する 楊 start
                    if (names != null && names.length > 0 && (!names[0].isEmpty()) && "facility_cd".equals(names[1].trim()))
                    // mod 8309 【デグレ】FNWデモ環境からコンバートするツールがエラーで停止する 楊 end
                    {
                        // キーが「"facility_cd"」の場合、削除しない。
                        return RepeatStatus.FINISHED;
                    }
                    // 一行目：sqlCommand
                    List<String> sqlTruncateTableStep = utils.readFile(fileTruncateTableStep);
                    sql = sqlTruncateTableStep.get(0);
                    jdbcTemplate.execute(sql);
                    fileTruncateTableStep.delete();
                }
                else
                {
                    return RepeatStatus.FINISHED;
                }
            }
            // 差分コンバート場合
            else
            {
                // del 10378-24-4 PatTreatmentPattern再構築対応 zkm start
                //add 9688 start
                //12229 start
                if(utils.ConvertNotData.contains(tableName)){
                    sql = "delete from " + db_table_prefix + tableName + " where  facility_cd =? ";
                    jdbcTemplate.update(sql, facilityCd);
                    EventLogMessage eventLogMessage = eventLoggerUtil.getEventLogMessage("コンバートDB→本番DB登録後テーブルデータ削除実行：" + sql,
                            facilityCd, "TruncateTableStep.execute(StepContribution contribution, ChunkContext chunkContext)");
                    eventLoggerUtil.recordLog(facilityCd, eventLogMessage, LogLevel.INFO);
                    return RepeatStatus.FINISHED;
                }
                //12229 end
                //add 9688 end
                // del 10378-24-4 PatTreatmentPattern再構築対応 zkm end
                if (!globalContext.sqlNewKeys.isEmpty()  && !utils.allDeleteAllInsertList.contains(tableName))
                {
                    String key = "";
                    if ("B".equals(globalContext.plan))
                    {
                        key = names[1];
                    }
                    else
                    {
                        key = globalContext.insFnKey;
                    }
                    // 新規レコードを削除
                    sql = "delete from " + db_table_prefix + tableName + " where " + key + " in (" + globalContext.sqlNewKeys + ")  and facility_cd=?";
                    //10378 add start
                    if("pat_coop_detail".equals(tableName)){
                        sql = "delete from " + db_table_prefix + "pat_coop_detail where coop_save_no is null and facility_cd=?"; // #11998 add
                    }
                    jdbcTemplate.update(sql, facilityCd);
                }
                // add zl start ord_main差分
                if (!globalContext.sqlDisNoKeys.isEmpty() && tableName.equals("ord_main")) {
                    // 新規レコードを削除
                    sql = "delete from " + db_table_prefix + tableName + " where " + globalContext.insFnDisKey + " in (" + globalContext.sqlDisNoKeys + ")  and facility_cd = ? ";
                    jdbcTemplate.update(sql, facilityCd);
                }
                // add zl end ord_main差分

                // mod zl start
                // 更新レコードを削除
                if (!globalContext.sqlKeys.isEmpty() && !utils.allDeleteAllInsertList.contains(tableName))
                {
                    // mod zl end
                    // 関連テーブル利用のみ
                    if("B".equals(globalContext.plan) )
                    {
                        // 更新レコードを削除
                        sql = "delete from " + db_table_prefix + tableName + " where " + names[1] + " in (" + globalContext.sqlKeys + ")  and facility_cd=?";
                        jdbcTemplate.update(sql, facilityCd);
                    } else {
                        // 自分テープル差分の場合、削除しない
                        return RepeatStatus.FINISHED;
                    }
                }

                // add zl start
                if (utils.allDeleteAllInsertList.contains(tableName)){
                    String tableKey = convertKeyConfig.getTableKey(tableName);
                    String condSql = tableKey + " is null ";
                    sql = "delete from " + db_table_prefix + tableName + " where " + condSql + " and facility_cd=?";
                    jdbcTemplate.update(sql, facilityCd);
                }

                // add zl end
            }
            // mod 7853-差分コンバートで更新/削除ができない 楊 end
            //ログ
            EventLogMessage eventLogMessage = eventLoggerUtil.getEventLogMessage("コンバートDB→本番DB登録後テーブルデータ削除実行：" + sql,
                    facilityCd, "TruncateTableStep.execute(StepContribution contribution, ChunkContext chunkContext)");
            eventLoggerUtil.recordLog(facilityCd, eventLogMessage, LogLevel.INFO);
            return RepeatStatus.FINISHED;
        }
    }

    @Bean(name=STEP_NAME)
    public Step step() {
        return stepBuilderFactory.get(STEP_NAME)
            .tasklet(this)
            .listener(new PromotionListener())
            .build();
    }

}